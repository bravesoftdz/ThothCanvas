unit ThLayout;

interface

uses
  System.Classes, System.SysUtils, System.Types, System.UITypes, FMX.Types, ThTypes;

type
  TThContent = class(TControl)
    // Layout - ClipRect
    // OffSet - Point(Position)
  private
    FTrackingPos: TPointF;

  protected
    function GetClipRect: TRectF; override;
    procedure PaintChildren; override;

    procedure AddTrackingPos(const Value: TPointF);
  end;

  TThContainer = class(TStyledControl)
  private
    FMouseTracking: Boolean;

    function GetContentBounds: TRectF; virtual;
    procedure RealignContent(R: TRectF); virtual;
    function GetOffsetPos: TPointF;
  protected
    FContent: TThContent;
    FContentScale: Single;
    FDownPos,
    FCurrentPos: TPointF;

    procedure Paint; override;
    procedure BlankClick; virtual;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure AddObject(AObject: TFmxObject); override;

    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Single); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Single); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Single); override;
    procedure MouseWheel(Shift: TShiftState; WheelDelta: Integer; var Handled: Boolean); override;

    property MouseTracking: Boolean read FMouseTracking write FMouseTracking default False;
    property OffsetPos: TPointF read GetOffsetPos;

    procedure Realign; override;
    procedure Center;

    function ZoomIn: Single;
    function ZoomOut: Single;
  end;

var
  MV: Single = 0;

implementation

{ TThContent }

function TThContent.GetClipRect: TRectF;
begin
  Result :=  TControl(Parent).ClipRect;
  OffsetRect(Result, -Position.X, -Position.Y);

//  Result.Left := Result.Left / Scale.X;
  Result.Right := Result.Right / Scale.X;
  Result.Bottom := Result.Bottom / Scale.Y;

//  Debug('%f %f %f %f', [Result.Left, Result.Top, Result.Right, Result.Bottom]);
//  Debug('UpdateRect %f %f %f %f', [UpdateRect.Left, UpdateRect.Top, UpdateRect.Right, UpdateRect.Bottom]);
end;

procedure TThContent.PaintChildren;
var
  I, j, K: Integer;
  R: TRectF;
  State: TCanvasSaveState;
  AllowPaint: Boolean;

  M: TMatrix;

  CanvasAbsP: TPointF;          // Form�� Canvas ���� ��ǥ
  ContentX, ContentY: Single;   // Content �̵��Ÿ�
begin
  if FScene = nil then
    Exit;
  if FChildren <> nil then
  begin
    for I := 0 to FChildren.Count - 1 do
      if (Children[I] is TControl) and
        ((TControl(FChildren[I]).Visible) or (not TControl(FChildren[I]).Visible and (csDesigning in ComponentState) and not TControl(FChildren[I]).Locked)) then
        with TControl(FChildren[I]) do
        begin
          if (csDesigning in ComponentState) then
            Continue;
          if not FInPaintTo and ((RectWidth(UpdateRect) = 0) or (RectHeight(UpdateRect) = 0)) then
            Continue;
          if Self.ClipChildren and not IntersectRect(Self.UpdateRect, UpdateRect) then
            Continue;
          // Check visibility
          AllowPaint := False;
          if (csDesigning in ComponentState) or FInPaintTo then
            AllowPaint := True;
          if not AllowPaint then
          begin
            R := UnionRect(GetChildrenRect, UpdateRect);
            for j := 0 to FScene.GetUpdateRectsCount - 1 do
              if IntersectRect(FScene.GetUpdateRect(j), R) then
              begin
                AllowPaint := True;
                Break;
              end;
          end;
          // Paint
          if AllowPaint then
          begin
            State := nil;
            try
              // Frame �ȿ��� �׸��� ���� FClipChildren ����
              if {Self.FClipChildren and }CanClip then
              begin
                State := Canvas.SaveState;

                M := Self.AbsoluteMatrix;
                R := Self.ClipRect;

                Debug('@ m31 %f m32 %f Pos %f %f R (%f, %f = %f)', [M.m31, M.m32, Position.X, Position.Y, R.Left, R.Right, R.Right - R.Left]);
                ////////////////////////////////////////////////////////////////
                // Tracking �ϸ� Container �¿����� ǥ�õ��� �ʴ� �κ� ����
                //  - M.m31 : ���� ����(Canvas ��ǥ�� Container ����������)
                //  - R.Right : ���� ����

                // @@@@@@@@@@@@@@@@@@@@@@@
                // Ȯ�����, Ʈ��ŷ, �̵� �� ���������� ���� ����(�߻����� �ν� �ȵ�)
                // @@@@@@@@@@@@@@@@@@@@@@@

                CanvasAbsP  := TControl(Self.Parent).LocalToAbsolute(PointF(0, 0));
                ContentX    := -Self.Position.X;
                ContentY    := -Self.Position.Y;

                // m31 := Paernt�� ���� ��ǥ + Content �̵��Ÿ�
                M.m31 := CanvasAbsP.X + (ContentX * (1-Self.Scale.X));
//                R.Left := R.Left - (ContentX / Self.Scale.X);
                R.Left := R.Left - (ContentX / Self.Scale.X);
                R.Right := R.Left + (Self.Width / Self.Scale.X);


                M.m32 := CanvasAbsP.Y + (ContentY * (1-Self.Scale.Y));
                R.Top := R.Top - (ContentY / Self.Scale.X);
                R.Bottom := R.Top + (Self.Height / Self.Scale.X);

                Debug('@@ M %f S.PX %f, R.L %f R.R %f', [M.m31, Self.Position.X, R.Left, R.Right]);
                Canvas.SetMatrix(M);
                Canvas.IntersectClipRect(R);
                //
                ////////////////////////////////////////////////////////////////
              end;
              if HasEffect and not HasAfterPaintEffect then
                ApplyEffect;
              Painting;
              DoPaint;
              AfterPaint;
            finally
              if State <> nil then
                Canvas.RestoreState(State);
            end;
            if HasAfterPaintEffect then
              ApplyEffect;
          end;
        end;
  end;
end;

procedure TThContent.AddTrackingPos(const Value: TPointF);
begin
  FTrackingPos := Value;

  Position.X := Position.X + Value.X;
  Position.Y := Position.Y + Value.Y;
end;

{ TThContainer }

procedure TThContainer.Center;
begin
  FContent.Position.Point := PointF(0, 0);
end;

constructor TThContainer.Create(AOwner: TComponent);
begin
  inherited;

  FContentScale := 1;
  FMouseTracking := True;

  AutoCapture := True;

  FContent := TThContent.Create(Self);
  FContent.Parent := Self;
  FContent.Stored := False;
  FContent.Locked := True;
  FContent.HitTest := False;
end;

destructor TThContainer.Destroy;
begin
  FContent.Free;
  FContent := nil;

  inherited;
end;

function TThContainer.GetContentBounds: TRectF;
var
  I: Integer;
  R, LocalR: TRectF;
  C: TControl;
begin
  Result := RectF(0, 0, Width, Height);
  if (FContent <> nil) then
  begin
    R := ClipRect;
    for I := 0 to FContent.ChildrenCount - 1 do
      if FContent.Children[I] is TControl then
        if (TControl(FContent.Children[I]).Visible) then
        begin
          if (csDesigning in ComponentState) and not (csDesigning in FContent.Children[I].ComponentState) then Continue;
          // Scale���� ũ��� ���õ� �׸� ó��
//          LocalR := TControl(FContent.Children[I]).ParentedRect;
          C := TControl(FContent.Children[I]);
          LocalR := RectF(0, 0, C.Width * C.Scale.X, C.Height * C.Scale.Y);
          R := UnionRect(R, LocalR);
        end;
    Result := R;

    Debug('ContentBound L T :%f, %f', [R.Left, R.Top]);
  end;
end;

function TThContainer.GetOffsetPos: TPointF;
begin
  Result := FContent.Position.Point;
end;

procedure TThContainer.MouseDown(Button: TMouseButton; Shift: TShiftState; X,
  Y: Single);
begin
  inherited;

  if (FPressed) and FMouseTracking then
  begin
    FDownPos := PointF(X, Y);
    FCurrentPos := PointF(X, Y);
//    FCurrentPos := ScalePoint(PointF(X, Y), FContentScale, FContentScale);
  end;
end;

procedure TThContainer.MouseMove(Shift: TShiftState; X, Y: Single);
var
  TP: TPointF;
begin
  if FPressed and FMouseTracking then
  begin
    TP := PointF(X - FCurrentPos.X, Y - FCurrentPos.Y);

    FContent.AddTrackingPos(TP);

    FCurrentPos := PointF(X, Y);
  end;
end;

procedure TThContainer.MouseUp(Button: TMouseButton; Shift: TShiftState; X,
  Y: Single);
var
  R: TRectF;
begin
  inherited;
{// ���� ������ �������� �ʾƵ� �ɵ�
  // ������ ������ ���� �̵���? �ð��� �߰�?
  R.TopLeft := FDownPos.Subtract(PointF(3, 3));
  R.BottomRight := FDownPos.Add(PointF(3, 3));

  if PtInRect(R, PointF(X, Y)) then
}
  if FDownPos = PointF(X, Y) then
    BlankClick;
end;

procedure TThContainer.BlankClick;
begin

end;

procedure TThContainer.MouseWheel(Shift: TShiftState; WheelDelta: Integer;
  var Handled: Boolean);
begin
  inherited;

  if WheelDelta < 0 then
    ZoomOut
  else
    ZoomIn
  ;
end;

procedure TThContainer.Paint;
begin
  // (Test) Background color
  Canvas.Fill.Color := claGreen;
  Canvas.FillRect(ClipRect, 0, 0, AllCorners, 1);

  inherited;
end;

procedure TThContainer.Realign;

  procedure IntAlign;
  var
    R: TRectF;
  begin
    R := GetContentBounds;
    OffsetRect(R, FContent.Position.X, FContent.Position.Y);

    RealignContent(R);
  end;
begin
  if csDestroying in ComponentState then
    Exit;
  inherited;
  if csLoading in ComponentState then
    Exit;

  if FDisableAlign then
    Exit;
  if FUpdating > 0 then
    Exit;
  FDisableAlign := True;
  try
    IntAlign;
  finally
    FDisableAlign := False;
  end;
end;

procedure TThContainer.RealignContent(R: TRectF);
begin
  if (FContent <> nil) then
  begin
    FContent.SetBounds(R.Left, R.Top, RectWidth(R), RectHeight(R));
    FContent.FRecalcUpdateRect := True; // need to recalc
  end;
end;

function TThContainer.ZoomIn: Single;
begin
  FContentScale := FContentScale * 1.1;

  FContent.Scale.X := FContentScale;
  FContent.Scale.Y := FContentScale;

  Result := FContent.Scale.X;
  
// ������ ���� �̵��ϴ� ��� �߰� �ʿ�(���콺�� �ִ� ��ǥ�� Ȯ��/��� �Ŀ��� ���콺 ��ġ�� �ֵ���)
end;

function TThContainer.ZoomOut: Single;
begin
  FContentScale := FContentScale * 0.9;

  FContent.Scale.X := FContentScale;
  FContent.Scale.Y := FContentScale;

  Result := FContent.Scale.X;
end;

procedure TThContainer.AddObject(AObject: TFmxObject);
begin
  if Assigned(FContent) and (AObject <> FContent) and
    not (AObject is TEffect) and not (AObject is TAnimation) then
  begin
    FContent.AddObject(AObject);
  end
  else
    inherited;
end;

end.

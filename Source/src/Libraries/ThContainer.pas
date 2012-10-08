unit ThContainer;

interface

uses
  System.Classes, System.SysUtils, ThItem,
  System.Types, System.UITypes, System.UIConsts, FMX.Types;

type
  TThContents = class(TControl)
  private
    FTrackingPos: TPointF;
  protected
    function GetClipRect: TRectF; override;
    function GetUpdateRect: TRectF; override;
    procedure Paint; override;
  public
    procedure AddTrackingPos(const Value: TPointF);
  end;

  TThContainer = class(TControl)
  private
    FUseMouseTracking: Boolean;
    FSelecteditem: TThItem;

    procedure ItemSelect(Sender: TObject);
    procedure ItemUnselect(Sender: TObject);
  protected
    FContents: TThContents;
    FMouseDownPos,          // MouseDown �� ��ǥ
    FMouseCurrPos: TPointF; // MouseMove �� ��ǥ

    procedure Paint; override;
//    procedure PaintChildren; override;

    procedure DoAddObject(AObject: TFmxObject); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Single); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Single); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Single); override;

    function InsertItem(const ItemID: Integer): TThItem;
    procedure ClearSelection;

    property SelectedItem: TThItem read FSelectedItem;
  end;

implementation

uses
  ThItemFactory, CommonUtils;

{ TThContent }

procedure TThContents.AddTrackingPos(const Value: TPointF);
begin
  FTrackingPos := Value;

  Position.X := Position.X + Value.X;
  Position.Y := Position.Y + Value.Y;
end;

function TThContents.GetClipRect: TRectF;
begin
  Result :=  TControl(Parent).ClipRect;
  OffsetRect(Result, -Position.X, -Position.Y);
end;

function TThContents.GetUpdateRect: TRectF;
begin
  if not Assigned(Parent) then
    Exit;

{   ClipClildren := True ���� �� Canvas ������ ���������� Contents ǥ�� ����
      TControl.GetUpdateRect 11 line
          if TControl(P).ClipChildren or TControl(P).SmallSizeControl then
            IntersectRect(FUpdateRect, FUpdateRect, TControl(P).UpdateRect);}

  TControl(Parent).ClipChildren := False;
  try
    Result := inherited GetUpdateRect;
  finally
    TControl(Parent).ClipChildren := True;
  end;
end;

procedure TThContents.Paint;
begin
  inherited;

{$IFDEF DEBUG}
  Canvas.Fill.Color := claNull;
  Canvas.Stroke.Color := claBlack;

  Canvas.DrawRect(TControl(Parent).ClipRect, 0, 0, AllCorners, 1);
{$ENDIF}
end;

{ TThContainer }

constructor TThContainer.Create(AOwner: TComponent);
begin
  inherited;

  ClipChildren := True; // ��Ʈ���� �����ۿ� ǥ�õ��� �ʵ��� ó��
  AutoCapture := True;  // ���������� ������ ��Ʈ�� �ǵ��� ó��

  FUseMouseTracking := True;

  FContents := TThContents.Create(Self);
  FContents.Parent := Self;
  FContents.HitTest := False;
  FContents.Stored := False;
  FContents.Locked := True;
end;

destructor TThContainer.Destroy;
begin
  FContents.Free;

  inherited;
end;

procedure TThContainer.DoAddObject(AObject: TFmxObject);
begin
  if Assigned(FContents) and (AObject <> FContents) then
    FContents.AddObject(AObject)
  else
    inherited;
end;

procedure TThContainer.MouseDown(Button: TMouseButton; Shift: TShiftState; X,
  Y: Single);
begin
  inherited;

  if FPressed and FUseMouseTracking then
  begin
    FMouseDownPos := PointF(X, Y);
    FMouseCurrPos := PointF(X, Y);
  end;
end;

procedure TThContainer.MouseMove(Shift: TShiftState; X, Y: Single);
var
  TrackingPos: TPointF;
begin
  if FPressed and FUseMouseTracking then
  begin
    TrackingPos := PointF(X - FMouseCurrPos.X, Y - FMouseCurrPos.Y);
    FMouseCurrPos := PointF(X, Y);

    FContents.AddTrackingPos(TrackingPos);
  end;
end;

procedure TThContainer.MouseUp(Button: TMouseButton; Shift: TShiftState; X,
  Y: Single);
begin
  inherited;

  if FMouseDownPos = PointF(X, Y) then
    ClearSelection;
end;

procedure TThContainer.Paint;
begin
  inherited;

{$IFDEF DEBUG}
  Canvas.Fill.Color := $FFDDDDDD;
  Canvas.FillRect(ClipRect, 0, 0, AllCorners, 1);
{$ELSE}
  Canvas.Fill.Color := $FFDDDDDD;
  Canvas.FillRect(ClipRect, 0, 0, AllCorners, 1);
{$ENDIF}
end;

function TThContainer.InsertItem(const ItemID: Integer): TThItem;
begin
  Result := ItemFactory.Get(ItemID);
  if Assigned(Result) then
  begin
    Result.Parent := Self;
    Result.OnSelected := ItemSelect;
    Result.OnUnselected := ItemUnselect;
  end;
end;

procedure TThContainer.ItemSelect(Sender: TObject);
begin
  // Listó�� �ʿ�
  if Assigned(FSelectedItem) then
    FSelectedItem.Selected := False;

  FSelectedItem := TThItem(Sender);
end;

procedure TThContainer.ItemUnselect(Sender: TObject);
begin
  FSelectedItem := nil;
  // Listó�� �ʿ�
end;

procedure TThContainer.ClearSelection;
begin
  if Assigned(FSelectedItem) then
    FSelectedItem.Selected := False;
  FSelectedItem := nil;
end;

end.

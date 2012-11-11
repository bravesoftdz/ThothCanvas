unit ThZoomAnimation;

interface

uses
  System.Classes, System.Types,
  FMX.Types, FMX.Ani;

type
  TZoomAni = class(TControl)
  private
    FZoomAni: TFloatAnimation;
    FDiffuse: Single;

    procedure SetDiffuse(const Value: Single);
    procedure FinishAni(Sender: TObject);
  protected
    procedure Paint; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure ZoomIn(ACenterPos: TPointF);
    procedure ZoomOut(ACenterPos: TPointF);

    property Diffuse: Single read FDiffuse write SetDiffuse;
  end;

  TZoomCircleAni = class(TZoomAni)
  protected
    procedure Paint; override;
  end;

implementation

uses
  System.UIConsts;

{ TZoomAni }

constructor TZoomAni.Create(AOwner: TComponent);
begin
  inherited;

  HitTest := False;

  FZoomAni := TFloatAnimation.Create(Self);
  FZoomAni.Parent := Self;
  FZoomAni.AnimationType := TAnimationType.atOut;
  FZoomAni.Interpolation := TInterpolationType.itQuadratic;
  FZoomAni.PropertyName := 'Diffuse';
  FZoomAni.StartFromCurrent := False;
  FZoomAni.Delay := 0;
  FZoomAni.Duration := 0.5;
  FZoomAni.OnFinish := FinishAni;

  FWidth := 100;
  FHeight := 100;

  Visible := False;
end;

destructor TZoomAni.Destroy;
begin
  FZoomAni.Free;

  inherited;
end;

procedure TZoomAni.FinishAni(Sender: TObject);
begin
  Visible := False;
end;

procedure TZoomAni.Paint;
begin
  inherited;

end;

procedure TZoomAni.SetDiffuse(const Value: Single);
begin
  FDiffuse := Value;

  Repaint;
end;

procedure TZoomAni.ZoomIn(ACenterPos: TPointF);
begin
  Position.Point := ACenterPos.Subtract(PointF(Width / 2, Height / 2));

  Visible := True;
  FZoomAni.StartValue := 100;
  FZoomAni.StopValue := 10;

  if FZoomAni.Running then
    FZoomAni.Stop;
  FZoomAni.Start;
end;

procedure TZoomAni.ZoomOut(ACenterPos: TPointF);
begin
  Position.Point := ACenterPos.Subtract(PointF(Width / 2, Height / 2));

  Visible := True;
  FZoomAni.StartValue := 10;
  FZoomAni.StopValue := 100;

  if FZoomAni.Running then
    FZoomAni.Stop;
  FZoomAni.Start;
end;

{ TZoomCircleAni }

procedure TZoomCircleAni.Paint;
var
  Radius: Single;
  R, R2: TRectF;
  P: TPointF;
begin
  inherited;

  Radius := (Width / 2) * (FDiffuse / 100);
  P := ClipRect.CenterPoint;
  R := RectF(P.X, P.Y, P.X, P.Y);
  R2 := RectF(P.X, P.Y, P.X, P.Y);

  InflateRect(R, Radius, Radius);

  Canvas.StrokeThickness := 3;
  Canvas.StrokeDash := TStrokeDash.sdDot;
  Canvas.Stroke.Color := claDarkGray;
  Canvas.DrawEllipse(R, 1);

  // ���� ũ�� ���� �� ǥ��
  if Radius > (Width / 4) then
  begin
    InflateRect(R2, Radius / 2, Radius / 2);
    Canvas.DrawEllipse(R2, 1);
  end;
end;

end.
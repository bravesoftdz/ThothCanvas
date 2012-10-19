unit ThItemResizer;

interface

uses
  ThItemResizerIF, System.Classes, System.Types, FMX.Types, System.UITypes,
  System.Generics.Collections, ThConsts;

type
  TSpotCorner = (
                              scUnknown      = 0,
                              scTop          = 1,
                              scLeft         = 2,
                              scRight        = 4,
                              scBottom       = 8,
                              scTopLeft      = 3{rsdTop or rsdLeft},
                              scTopRight     = 5{rsdTop or rsdRight},
                              scBottomLeft   = 10{rsdBottom or rsdLeft},
                              scBottomRight  = 12{rsdBottom or rsdRight}{, spCustom});
  TExchangeSpotCorner = (
    escNone, escHorizon, escVertical, escBoth
  );

const
  HORIZON_CORNERS   = TSpotCorner(Ord(scLeft) or Ord(scRight));
  VERTICAL_CORNERS  = TSpotCorner(Ord(scTop) or Ord(scBottom));

//function AndSpotCorner(D1, D2: TSpotCorner): TSpotCorner;
function IfThenSpotCorner(AValue: Boolean; const ATrue: TSpotCorner; const AFalse: TSpotCorner): TSpotCorner;

function ContainSpotCorner(Source, SC: TSpotCorner): Boolean;
function SetHorizonSpotCorner(Source, SC: TSpotCorner): TSpotCorner;
function SetVerticalSpotCorner(Source, SC: TSpotCorner): TSpotCorner;

function ChangeHorizonSpotCorner(D1, D2: TSpotCorner): Boolean;
function ChangeVerticalSpotCorner(D1, D2: TSpotCorner): Boolean;
function SupportedHorizonSpotCorner(SC: TSpotCorner): Boolean;
function SupportedVerticalSpotCorner(SC: TSpotCorner): Boolean;

function HorizonSpotCornerExchange(D: TSpotCorner): TSpotCorner;
function VerticalSpotCornerExchange(D: TSpotCorner): TSpotCorner;
function SpotCornerExchange(D: TSpotCorner): TSpotCorner;

type
//  TItemResizeSpot = class;
//  TResizeSpotTrackEvent = procedure(Spot: TItemResizeSpot) of object;
  TAbstractItemResizeSpot = class(TControl, IItemResizeSpot)
  private
    FSpotCorner: TSpotCorner;
    FOnTracking: TTrackEvent;
    procedure SetSpotCorner(const Value: TSpotCorner);
  protected
    procedure DoMatrixChanged(Sender: TObject); override;
    procedure DoRepositioning; virtual;
  public
    constructor Create(AOwner: TComponent; ASpotCorner: TSpotCorner); reintroduce; virtual;

    property SpotCorner: TSpotCorner read FSpotCorner write SetSpotCorner;
    property OnTrack: TTrackEvent read FOnTracking write FOnTracking;

    class function InflateSize: Integer;
  end;

  TResizeSpotClass = class of TAbstractItemResizeSpot;
  TAbstractItemResizer = class(TInterfacedObject, IItemResizer)
  private
    FList: TList;
    FOnTracking: TTrackEvent;
    function GetSpots(Index: Integer): IItemResizeSpot;
    function GetCount: Integer;
  protected
    FParent: IItemResizerObject;
    FSpotClass: TResizeSpotClass;
    function GetResizerRect: TRectF; virtual; abstract;
    procedure DoResizeSpotTrack(Sender: TObject; X, Y: Single);
  public
    constructor Create(AParent: IItemResizerObject);
    destructor Destroy; override;

    procedure SetSpotClass(ASpotClass: TResizeSpotClass);
    procedure SetResizeSpots(Spots: array of TSpotCorner);

    function GetSpot(SpotCorner: TSpotCorner): TAbstractItemResizeSpot;

    procedure ShowSpots;
    procedure HideSpots;

    property Spots[Index: Integer] : IItemResizeSpot read GetSpots; default;
    property Count: Integer read GetCount;
    property OnTrack: TTrackEvent read FOnTracking write FOnTracking;
  end;

  TThItemCircleResizeSpot = class(TAbstractItemResizeSpot)
  private
    FMouseDownPos: TPointF;
  protected

    procedure Paint; override;
    function GetUpdateRect: TRectF; override;
//    function GetClipRect: TRectF; override;
    procedure DoMouseEnter; override;
    procedure DoMouseLeave; override;

    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Single); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Single); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Single); override;
  public
    constructor Create(AOwner: TComponent; ADirection: TSpotCorner); override;
    function PointInObject(X, Y: Single): Boolean; override;
  end;

  TThItemFillResizer = class(TAbstractItemResizer)
  protected
    function GetResizerRect: TRectF; override;
  public
    property OnTrack;
  end;

implementation

uses
  System.UIConsts, CommonUtils;

function AndSpotCorner(D1, D2: TSpotCorner): TSpotCorner;
begin
  Result := TSpotCorner(Ord(D1) and Ord(D2))
end;

function OrSpotCorner(D1, D2: TSpotCorner): TSpotCorner;
begin
  Result := TSpotCorner(Ord(D1) or Ord(D2))
end;

function IfThenSpotCorner(AValue: Boolean; const ATrue: TSpotCorner; const AFalse: TSpotCorner): TSpotCorner;
begin
  if AValue then
    Result := ATrue
  else
    Result := AFalse;
end;

function ContainSpotCorner(Source, SC: TSpotCorner): Boolean;
begin
  Result := AndSpotCorner(Source, SC) = SC;
end;

function SetHorizonSpotCorner(Source, SC: TSpotCorner): TSpotCorner;
begin
  Result := AndSpotCorner(Source, VERTICAL_CORNERS);  // Horizon ����
  Result := OrSpotCorner(Source, SC);
end;

function SetVerticalSpotCorner(Source, SC: TSpotCorner): TSpotCorner;
begin
  Result := AndSpotCorner(Source, HORIZON_CORNERS);
  Result := OrSpotCorner(Source, SC);
end;

function ChangeHorizonSpotCorner(D1, D2: TSpotCorner): Boolean;
begin
  Result := AndSpotCorner(D1, HORIZON_CORNERS) <> AndSpotCorner(D2, HORIZON_CORNERS);
end;

function ChangeVerticalSpotCorner(D1, D2: TSpotCorner): Boolean;
begin
  Result := AndSpotCorner(D1, VERTICAL_CORNERS) <> AndSpotCorner(D2, VERTICAL_CORNERS);
end;

function SupportedHorizonSpotCorner(SC: TSpotCorner): Boolean;
begin
  Result := AndSpotCorner(SC, HORIZON_CORNERS) <> scUnknown;
end;

function SupportedVerticalSpotCorner(SC: TSpotCorner): Boolean;
begin
  Result := AndSpotCorner(SC, VERTICAL_CORNERS) <> scUnknown;
end;

function HorizonSpotCornerExchange(D: TSpotCorner): TSpotCorner;
begin
  Result := D;
  if AndSpotCorner(Result, HORIZON_CORNERS) <> scUnknown then
    Result := TSpotCorner(Ord(Result) xor Ord(HORIZON_CORNERS))
end;

function VerticalSpotCornerExchange(D: TSpotCorner): TSpotCorner;
begin
  Result := D;
  if AndSpotCorner(Result, VERTICAL_CORNERS) <> scUnknown then
  Result := TSpotCorner(Ord(D) xor Ord(VERTICAL_CORNERS))
end;

function SpotCornerExchange(D: TSpotCorner): TSpotCorner;
begin
  Result := D;
  Result := HorizonSpotCornerExchange(Result);
  Result := VerticalSpotCornerExchange(Result);
end;

{ TItemResizeSpot }

constructor TAbstractItemResizeSpot.Create(AOwner: TComponent;
  ASpotCorner: TSpotCorner);
begin
  inherited Create(AOwner);

  Opacity := 1;
  FSpotCorner := ASpotCorner;
end;

procedure TAbstractItemResizeSpot.DoMatrixChanged(Sender: TObject);
begin
  inherited;

  DoRepositioning;
end;

procedure TAbstractItemResizeSpot.DoRepositioning;
begin
end;

class function TAbstractItemResizeSpot.InflateSize: Integer;
begin
  Result := ItemResizeSpotRadius;
end;

procedure TAbstractItemResizeSpot.SetSpotCorner(const Value: TSpotCorner);
begin
  FSpotCorner := Value;
end;

{ TItemResizer }

constructor TAbstractItemResizer.Create(AParent: IItemResizerObject);
begin
  FParent := AParent;
  FList := TList.Create;
end;

destructor TAbstractItemResizer.Destroy;
var
  I: Integer;
begin
  for I := FList.Count - 1 downto 0 do
    TControl(FList[I]).Free;

  inherited;
end;

procedure TAbstractItemResizer.DoResizeSpotTrack(Sender: TObject; X, Y: Single);
begin
  if Assigned(OnTrack) then
    OnTrack(Sender, X, Y);
end;

function TAbstractItemResizer.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TAbstractItemResizer.GetSpot(
  SpotCorner: TSpotCorner): TAbstractItemResizeSpot;
var
  I: Integer;
begin
  for I := 0 to FList.Count - 1 do
  begin
    Result := FList[I];
    if Result.SpotCorner = SpotCorner then
      Exit;
  end;

  Result := nil;
end;

function TAbstractItemResizer.GetSpots(Index: Integer): IItemResizeSpot;
begin
  if FList.Count > Index then
    Result := IItemResizeSpot(TAbstractItemResizeSpot(FList[Index]));
end;

procedure TAbstractItemResizer.ShowSpots;
var
  I: Integer;
begin
  for I := 0 to FList.Count - 1 do
    TControl(FList[I]).Visible := True;
  FParent.RealignSpot;
end;

procedure TAbstractItemResizer.HideSpots;
var
  I: Integer;
begin
  for I := 0 to FList.Count - 1 do
    TControl(FList[I]).Visible := False;
end;

procedure TAbstractItemResizer.SetResizeSpots(
  Spots: array of TSpotCorner);
var
  I: Integer;
  Spot: TAbstractItemResizeSpot;
begin
  for I := FList.Count - 1 downto 0 do
    TControl(FList[I]).Free;
  FList.Clear;
  Assert(Assigned(FSpotClass), 'Not assigned items Spot class');

  for I := 0 to Length(Spots) - 1 do
  begin
    Spot := FSpotClass.Create(TControl(FParent), Spots[I]);
    Spot.Parent := TControl(FParent);
    Spot.OnTrack := DoResizeSpotTrack;
    Spot.Visible := False;
    FList.Add(Spot);
  end;
end;

procedure TAbstractItemResizer.SetSpotClass(ASpotClass: TResizeSpotClass);
begin
  FSpotClass := ASpotClass;
end;

{ TThItemCircleResizeSpot }

constructor TThItemCircleResizeSpot.Create(AOwner: TComponent; ADirection: TSpotCorner);
begin
  inherited;

  AutoCapture := True;

  Width := ItemResizeSpotRadius * 2;
  Height := ItemResizeSpotRadius * 2;
end;

procedure TThItemCircleResizeSpot.DoMouseEnter;
begin
  inherited;

  Repaint;
end;

procedure TThItemCircleResizeSpot.DoMouseLeave;
begin
  inherited;

  Repaint;
end;

function TThItemCircleResizeSpot.GetUpdateRect: TRectF;
begin
  Result := inherited GetUpdateRect;
  InflateRect(Result,
    ItemResizeSpotRadius + Canvas.StrokeThickness,
    ItemResizeSpotRadius + Canvas.StrokeThickness);
end;

procedure TThItemCircleResizeSpot.Paint;
var
  R: TRectF;
begin
  inherited;

  Canvas.StrokeThickness := 1;
  Canvas.Stroke.Color := $FF222222;
  if IsMouseOver then
    Canvas.Fill.Color := ItemResizeSpotOverColor
  else
    Canvas.Fill.Color := ItemResizeSpotOutColor;

  R := R.Empty;
  InflateRect(R, ItemResizeSpotRadius, ItemResizeSpotRadius);
  Canvas.FillEllipse(R, 1);
  Canvas.DrawEllipse(R, 1);
end;

procedure TThItemCircleResizeSpot.MouseDown(Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
begin
  inherited;

  if FPressed then
  begin
    FMouseDownPos := PointF(X, Y);
  end;
end;

procedure TThItemCircleResizeSpot.MouseMove(Shift: TShiftState; X,
  Y: Single);
var
  Gap: TPointF;
begin
  inherited;

  if FPressed then
  begin
    Gap := PointF(X, Y).Subtract(FMouseDownPos);  // Down and Move Gap
    Position.Point := Position.Point.Add(Gap);

    if Assigned(OnTrack) then
      OnTrack(Self, Gap.X, Gap.Y);
  end;
end;

procedure TThItemCircleResizeSpot.MouseUp(Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
begin
  inherited;

end;

{ TItemFillResizer }

function TThItemFillResizer.GetResizerRect: TRectF;
begin
  Result := TControl(FParent).ClipRect;
  InflateRect(Result, FSpotClass.InflateSize + 1, FSpotClass.InflateSize + 1);
end;

function TThItemCircleResizeSpot.PointInObject(X, Y: Single): Boolean;
var
  P: TPointF;
begin
  Result := False;
  P := AbsoluteToLocal(PointF(X, Y));
  if (Abs(P.X) < ItemResizeSpotRadius) and (Abs(P.Y) < ItemResizeSpotRadius) then
    Result := True;
end;

end.

unit ThCanvasEditor;

interface

uses
  System.UITypes, System.Classes, System.Types, System.SysUtils,
  ThContainer, ThItem;

type
  TThCanvasEditor = class(TThContainer)
  private
    FDrawItem: TThItem;
    FItemID: Integer;
    FSelecteditem: TThItem;

    procedure SelectItem(Sender: TObject);
  public
    constructor Create(AOwner: TComponent);

    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Single); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Single); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Single); override;

    property ItemID: Integer read FItemID write FItemID;

    property SelectedItem: TThItem read FSelectedItem;
  end;

implementation

uses
  ThItemFactory, CommonUtils;

{ TThCanvasEditor }

constructor TThCanvasEditor.Create(AOwner: TComponent);
begin
  inherited;

  FItemID := -1;
end;

procedure TThCanvasEditor.MouseDown(Button: TMouseButton; Shift: TShiftState; X,
  Y: Single);
begin
  inherited;

  if FItemID <> -1 then
  begin
    FSelectedItem := nil;
    FDrawItem := ItemFactory.Get(FItemID);
    if Assigned(FDrawItem) then
    begin
      FDrawItem.Parent := Self;
      FDrawItem.Position.Point := PointF(X, Y).Subtract(FContents.Position.Point);
      FDrawItem.OnSelected := SelectItem;
    end;
  end;
end;

procedure TThCanvasEditor.MouseMove(Shift: TShiftState; X, Y: Single);
var
  R: TRectF;
begin
  if (FItemID <> -1) and Assigned(FDrawItem) then
  begin
    R := RectF(FDownPos.X, FDownPos.Y, X, Y);
    R.Offset(-FContents.Position.X, -FContents.Position.Y);
    R.NormalizeRect;
    FDrawItem.BoundsRect := R;
  end
  else
    inherited;
end;

procedure TThCanvasEditor.MouseUp(Button: TMouseButton; Shift: TShiftState; X,
  Y: Single);
begin
  inherited;

  FDrawItem := nil;
  FItemID := -1;
end;

procedure TThCanvasEditor.SelectItem(Sender: TObject);
begin
  FSelectedItem := TThItem(Sender);
//  Repaint;
end;

end.

unit BaseTestUnit;

interface

uses
  TestFramework, ThCanvasEditor,
  System.Types, FMX.Types, FMX.Forms;

type
  // Test methods for class TThCanvasEditor

  TBaseTestUnit = class(TTestCase)
  protected
    FClosing: Boolean;
    FForm: TForm;
    FCanvas: TThCanvasEditor;
    function GetInitialPoint: TPointF;
    procedure SetTestControl(var FormRect, CanvasRect: TRectF); virtual;
  public
    procedure SetUp; override;
    procedure TearDown; override;

    procedure DebugShowForm;

    procedure DrawRectangle(Left, Top, Right, Bottom: Single); overload;
    procedure DrawRectangle(R: TRectF); overload;
  end;

implementation

uses
  UnitTestForm, FMX.Platform, FMX.TestLib;

{ TBastTestUnit }

function TBaseTestUnit.GetInitialPoint: TPointF;
begin
  Result := IControl(FCanvas).LocalToScreen(PointF(0, 0));
end;

procedure TBaseTestUnit.SetTestControl(var FormRect, CanvasRect: TRectF);
begin
  FormRect.Top := 300;
  FormRect.Left := 300;
  FormRect.Width := 600;
  FormRect.Height := 600;

  CanvasRect := RectF(50, 50, 350, 350);
end;

procedure TBaseTestUnit.SetUp;
var
  FormRect, CanvasRect: TRectF;
begin
  FClosing := True;

  SetTestControl(FormRect, CanvasRect);

  FForm := TfrmUnitTest.Create(nil);
  FForm.Top     := Round(FormRect.Top);
  FForm.Left    := Round(FormRect.Left);
  FForm.Width   := Round(FormRect.Width);
  FForm.Height  := Round(FormRect.Height);
  FForm.Show;

  FCanvas := TThCanvasEditor.Create(FForm);
  FCanvas.Parent := FForm;
  FCanvas.Position.Point  := CanvasRect.TopLeft;
  FCanvas.Width           := CanvasRect.Width;
  FCanvas.Height          := CanvasRect.Height;

  TestLib.SetInitialMousePoint(GetInitialPoint);
  Application.ProcessMessages;
end;

procedure TBaseTestUnit.TearDown;
begin
  if not FClosing then
    Exit;

  FCanvas.Free;
  FForm.Free;
end;

procedure TBaseTestUnit.DrawRectangle(Left, Top, Right, Bottom: Single);
begin
  DrawRectangle(RectF(Left, Top, Right, Bottom));
end;

procedure TBaseTestUnit.DebugShowForm;
begin
  FClosing := False;
end;

procedure TBaseTestUnit.DrawRectangle(R: TRectF);
begin
  FCanvas.DrawItemID := 1100;   // 1100 is Rectangles ID
  MousePath.New
  .Add(R.TopLeft)
  .Add(R.CenterPoint)
  .Add(R.BottomRight);
  TestLib.RunMousePath(MousePath.Path);
end;

end.

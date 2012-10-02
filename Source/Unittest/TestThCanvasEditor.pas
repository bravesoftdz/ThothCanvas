unit TestThCanvasEditor;
{

  Delphi DUnit Test Case
  ----------------------
  This unit contains a skeleton test case class generated by the Test Case Wizard.
  Modify the generated code to correctly setup and call the methods from the unit
  being tested.

}

interface

uses
  TestFramework, ThContainer, ThCanvasEditor,
  System.Types, System.Classes, System.SysUtils, System.UITypes, FMX.Forms,
  FMX.Types;

type
  // Test methods for class TThCanvasEditor

  TestTThCanvasEditor = class(TTestCase)
  strict private
    FForm: TForm;
    FCanvas: TThCanvasEditor;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    // #50 드래그하여 캔버스를 이동할 수 있어야 한다.
    procedure TestTracking50To200;

    // #44 음수영역의 좌표로도 이동가능해야 한다.
    procedure TestTracking150To0;

    // #51 영역밖으로 드래그 시 캔버스 이동이 계속 되어야 한다.
    procedure TestTracking50To_300;
  end;

implementation

uses
  UnitTestForm, FMX.TestLib;

procedure TestTThCanvasEditor.SetUp;
begin
  FForm := TfrmUnitTest.Create(nil);
  FForm.Width := 600;
  FForm.Height := 600;
  FForm.Top := 300;
  FForm.Left := 300;
  FForm.Show;

  FCanvas := TThCanvasEditor.Create(FForm);
  FCanvas.Parent := FForm;
  FCanvas.Width := 300;
  FCanvas.Height := 300;
  FCanvas.Position.Point := PointF(50, 50);

  Application.ProcessMessages;
end;

procedure TestTThCanvasEditor.TearDown;
begin
  FCanvas.Free;
  FForm.Free;
end;

procedure TestTThCanvasEditor.TestTracking50To200;
var
  P: TPointF;
  Path: array of TPointF;
begin
  SetLength(Path, 5);

  P := IControl(FCanvas).LocalToScreen(PointF(0, 0));

  Path[0] := P.Add(PointF(50, 50));
  Path[1] := P.Add(PointF(100, 100));
  Path[2] := P.Add(PointF(100, 150));
  Path[3] := P.Add(PointF(150, 150));
  Path[4] := P.Add(PointF(200, 200));

  TestLib.MousePath(Path);

  Check(
    (FCanvas.ContentPos.X = (Path[High(Path)].X - Path[Low(Path)].X)) and (FCanvas.ContentPos.X = (Path[High(Path)].Y - Path[Low(Path)].Y))
    , Format('FCanvas.Postion : %f, %f', [FCanvas.ContentPos.X, FCanvas.ContentPos.X])
  );
end;

procedure TestTThCanvasEditor.TestTracking150To0;
var
  P: TPointF;
  Path: array of TPointF;
begin
  SetLength(Path, 5);

  P := IControl(FCanvas).LocalToScreen(PointF(0, 0));

  Path[0] := P.Add(PointF(150, 150));
  Path[1] := P.Add(PointF(100, 100));
  Path[2] := P.Add(PointF(100, 150));
  Path[3] := P.Add(PointF(150, 150));
  Path[4] := P.Add(PointF(0, 0));

  TestLib.MousePath(Path);

  Check(
    (FCanvas.ContentPos.X = -150) and (FCanvas.ContentPos.X = -150)
    , Format('FCanvas.Postion : %f, %f', [FCanvas.ContentPos.X, FCanvas.ContentPos.X])
  );
end;

procedure TestTThCanvasEditor.TestTracking50To_300;
var
  P: TPointF;
  Path: array of TPointF;
begin
  SetLength(Path, 3);

  P := IControl(FCanvas).LocalToScreen(PointF(0, 0));

  Path[0] := P.Add(PointF(50, 50));
  Path[1] := P.Add(PointF(0, 50));
  Path[2] := P.Add(PointF(-200, 50));

  TestLib.MousePath(Path);

  Check(
    (FCanvas.ContentPos.X = -250)
    , Format('FCanvas.Postion : %f, %f', [FCanvas.ContentPos.X, FCanvas.ContentPos.X])
  );
end;

initialization
  // Register any test cases with the test runner
  RegisterTest(TestTThCanvasEditor.Suite);
end.


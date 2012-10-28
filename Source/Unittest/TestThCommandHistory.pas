unit TestThCommandHistory;

interface

uses
  TestFramework, BaseTestUnit,
  System.Types, System.SysUtils, FMX.Types, FMX.Objects, System.UIConsts;

type
  // #23 Undo/Redo����� �̿��Ͽ� ����� �ǵ�����.
  TestTThCommandHistory = class(TBaseCommandTestUnit)
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    // #123 �簢���� �߰��ϰ� Undo����ϸ� ������ ���õ��� �ʾƾ� �Ѵ�.
    procedure TestCommandHistoryAddUndo;

    // #138 �簢�� �߰� �� Undo > Redo �� �簢���� �߰��Ǿ� �־�� �Ѵ�.
    procedure TestCommandHistoryAddRedo;

    // #154 �Ʒ���ġ�� �������� ���� > ���� �� �״�� �Ʒ��� ��ġ�ؾ��Ѵ�.
    procedure TestCommandHistoryDelete;


    procedure TestCommandHistoryMove;
    procedure TestCommandHistoryResize;
  end;

implementation

uses
  UnitTestForm, FMX.TestLib, ThCanvas, ThCanvasEditor,
  ThItem, ThShape, ThItemFactory;

{ TestTThCommandHistory }

procedure TestTThCommandHistory.SetUp;
begin
  inherited;

end;

procedure TestTThCommandHistory.TearDown;
begin
  inherited;

end;

procedure TestTThCommandHistory.TestCommandHistoryAddUndo;
begin
  DrawRectangle(10, 10, 100, 100);

  FThothController.Undo;

  TestLib.RunMouseClick(50, 50);
  CheckNull(FCanvas.SelectedItem, 'Undo');
end;

procedure TestTThCommandHistory.TestCommandHistoryAddRedo;
begin
  DrawRectangle(10, 10, 100, 100);

  FThothController.Undo;

  TestLib.RunMouseClick(50, 50);
  CheckNull(FCanvas.SelectedItem, 'Undo');

  FThothController.Redo;
  TestLib.RunMouseClick(50, 50);
  CheckNotNull(FCanvas.SelectedItem, 'Redo');
  Check(FCanvas.SelectedItem.Position.Point = PointF(10, 10),
      Format('Position (%f, %f)', [FCanvas.SelectedItem.Position.X, FCanvas.SelectedItem.Position.Y]));
end;

procedure TestTThCommandHistory.TestCommandHistoryDelete;
begin
  DrawRectangle(10, 10, 100, 100);

  TestLib.RunMouseClick(50, 50);

  FCanvas.DeleteSelection;

  TestLib.RunMouseClick(50, 50);
  CheckNull(FCanvas.SelectedItem, 'Delete');

  FThothController.Undo;

  TestLib.RunMouseClick(50, 50);
  CheckNotNull(FCanvas.SelectedItem, 'Undo');

  FThothController.Redo;
  // Redo �� �����ǿ��� ���ŵ��� ����
    // Selected ���� �� Selection ó�� �ʿ�

  TestLib.RunMouseClick(50, 50);
  CheckNull(FCanvas.SelectedItem, 'Redo');
end;

procedure TestTThCommandHistory.TestCommandHistoryMove;
var
  P: TPointF;
begin
//  ShowForm;

  DrawRectangle(10, 10, 100, 100);

  MousePath.New
  .Add(50, 50)
  .Add(80, 100)
  .Add(100, 100);
  TestLib.RunMousePath(MousePath.Path);

  CheckNotNull(FCanvas.SelectedItem);
  P := FCanvas.SelectedItem.Position.Point;
  Check(P = PointF(60, 60), Format('Org(60,60) X: %f, Y: %f', [P.X, P.Y]));

  FThothController.Undo;
  P := FCanvas.SelectedItem.Position.Point;
  Check(P = PointF(10, 10), Format('Undo(10,10) X: %f, Y: %f', [P.X, P.Y]));

  FThothController.Redo;
  P := FCanvas.SelectedItem.Position.Point;
  Check(P = PointF(60, 60), Format('Redo(60,60) X: %f, Y: %f', [P.X, P.Y]));
end;

procedure TestTThCommandHistory.TestCommandHistoryResize;
begin

end;

initialization
  RegisterTest(TestTThCommandHistory.Suite);

end.


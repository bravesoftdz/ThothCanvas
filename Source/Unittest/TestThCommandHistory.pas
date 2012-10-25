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
  ShowForm;

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
begin

end;

procedure TestTThCommandHistory.TestCommandHistoryResize;
begin

end;

initialization
  RegisterTest(TestTThCommandHistory.Suite);

end.


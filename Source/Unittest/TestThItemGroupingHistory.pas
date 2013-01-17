unit TestThItemGroupingHistory;

interface

uses
  TestFramework, BaseTestUnit, FMX.Types, FMX.Forms,
  System.UITypes, System.Types, System.SysUtils, FMX.Controls, System.UIConsts;

type
  // #260 �ߺ� �׷����� ó���Ǿ� �Ѵ�.
  // #256 �׷��� ���� �� ��Ÿ
  TestTThItemGrouppingHistory = class(TBaseCommandHistoryTestUnit)
  published
    // #277 P1�� C1�� �ø��� Undo / Redo �� C1�� �θ�� ��ġ Ȯ��
    procedure TestMoveChild;

    // #276 C1�� P1���� ���� Undo / Redo �� C1�� �θ�� ��ġ Ȯ��
    procedure TestMoveParent;

    // #279 P1�� C1�� �߰��ϰ� Undo / Redo �� C1�� �θ� Ȯ��
    procedure TestAdd;

    // #280 P1���� C1�� �����ϰ� Undo / Redo �� C1�� �θ� Ȯ��
    procedure TestDeleteChild;

    // #281 C1�� ũ�⸦ P1�� ����� Undo/Redo �� C1�� �θ� Ȯ��
    procedure TestResizeChild;

    // #282 P1�� ũ�⸦ ���̰� Undo/Redo �� C1�� �θ� Ȯ��
    procedure TestResizeParent;

    // #249 Undo / Redo �� ItemIndex�� ������� ���ƿ;� �Ѵ�.
    procedure TestRecoveryIndexMove;
  end;

implementation

uses
  FMX.TestLib, ThItem, ThShapeItem, ThItemFactory, ThConsts, System.Math, DebugUtils;

{ TestTThItemGrouppingMulti }

procedure TestTThItemGrouppingHistory.TestMoveChild;
var
  P1, C1: TThItem;
  C1P_O, C1p_N: TPointF;
begin
  P1 := DrawRectangle(10, 10, 150, 150, 'P1');
  C1 := DrawRectangle(160, 160, 210, 210, 'C1');
  C1P_O := C1.Position.Point;

  TestLib.RunMousePath(MousePath.New
  .Add(180, 180)
  .Add(100, 30)
  .Add(30, 30).Path);

  Check(C1.Parent = P1, 'Contain');
  C1P_N := C1.Position.Point;

  FThothController.Undo;

  Check(C1.Parent <> P1, Format('Undo: %s', [C1.Parent.Name]));
  CheckEquals(C1.Position.Point.X, C1P_O.X, 'C1P_O');
//  Check(C1.Position.Point = C1P_O, Format('C1P_O(%f,%f)', [C1P_O.X, C1P_O.Y]));

  FThothController.Redo;

  Check(C1.Parent = P1, Format('Redo: %s', [C1.Parent.Name]));
  Check(C1.Position.Point = C1P_N, 'C1P_N');
end;

procedure TestTThItemGrouppingHistory.TestMoveParent;
var
  P1, C1, C2: TThItem;
begin
  // C2�� �ö� P1���� C1�� ������ �̵��Ѵ�.
  // Undo �� P1�� C2�� �����Ͽ� ���ڸ��� ����
  // C1�� �״�� ��ġ�ϴ��� Ȯ���Ѵ�.
  P1 := DrawRectangle(10, 10, 150, 150, 'P1');
  C2 := DrawRectangle(20, 50, 50, 50, 'C2');
  TThRectangle(C2).BgColor := claBlue;

  C1 := DrawRectangle(130, 130, 180, 180, 'C1');
  TThRectangle(C1).BgColor := claRed;

  // P1���� C1 ����
  TestLib.RunMouseClick(20, 20);
  TestLib.RunMousePath(MousePath.New
  .Add(50, 50)
  .Add(100, 100)
  .Add(140, 140).Path);

  Check(C1.Parent = P1, 'Contain');

  FThothController.Undo;

  // C1�� ��ġ, �θ� Ȯ��
  TestLib.RunMouseClick(150, 150);
  Check(FCanvas.SelectedItem = C1, 'Not selected C1');
  Check(C1.Parent <> P1, Format('C1.Parent is %s(Not Parent <> P1)', [C1.Parent.Name]));
  Check(C2.Parent = P1, 'C2.Parent is P1');

  FThothController.Redo;

  Check(C1.Parent = P1, Format('Redo: %s', [C1.Parent.Name]));
end;

procedure TestTThItemGrouppingHistory.TestAdd;
var
  P1, C1: TThItem;
begin
  P1 := DrawRectangle(10, 10, 150, 150, 'P1');
  C1 := DrawRectangle(30, 30, 130, 130, 'C1');

  Check(C1.Parent = P1, 'Contain');

  FThothController.Undo;

  Check(not Assigned(C1.Parent), Format('Undo: %s', ['C1.Parent is not null']));

  FThothController.Redo;

  Check(C1.Parent = P1, Format('Redo: %s', [C1.Parent.Name]));
end;

procedure TestTThItemGrouppingHistory.TestDeleteChild;
var
  P1, C1: TThItem;
begin
  P1 := DrawRectangle(10, 10, 150, 150, 'P1');
  C1 := DrawRectangle(30, 30, 130, 130, 'C1');

  Check(C1.Parent = P1, 'Contain');

  TestLib.RunMouseClick(100, 100);
  FCanvas.DeleteSelection;

  Check(not Assigned(C1.Parent), Format('Delete: %s', ['C1.Parent is not null']));

  FThothController.Undo;

  Check(C1.Parent = P1, Format('Undo: %s', [C1.Parent.Name]));

  FThothController.Redo;

  CheckEquals(P1.ItemCount, 0, Format('ItemCount: %d', [P1.ItemCount]));
end;

procedure TestTThItemGrouppingHistory.TestResizeChild;
var
  P1, C1: TThItem;
begin
  P1 := DrawRectangle(110, 110, 250, 250, 'P1');
  C1 := DrawRectangle(130, 130, 290, 290, 'C1');

  Check(C1.Parent <> P1, 'Not contain');
  CheckEquals(C1.Position.X, -200, Format('C1.Position.X : %f', [C1.Position.X]));

  TestLib.RunMouseClick(200, 200);
  TestLib.RunMousePath(MousePath.New
  .Add(290, 290)
  .Add(200, 200)
  .Add(230, 230).Path);

  Check(C1.Parent = P1, 'Contain');

  FThothController.Undo;
  Application.ProcessMessages;

  Check(C1.Parent <> P1, 'Undo> Not contain');
  CheckEquals(C1.Position.X, -200, Format('Undo> C1.Position.X : %f', [C1.Position.X]));

  FThothController.Redo;
  Application.ProcessMessages;

  Check(C1.Parent = P1, 'Contain');
end;

procedure TestTThItemGrouppingHistory.TestResizeParent;
var
  P1, C1: TThItem;
begin
  P1 := DrawRectangle(110, 110, 250, 250, 'P1');
  C1 := DrawRectangle(130, 130, 240, 240, 'C1');

  Check(C1.Parent = P1, 'Contain');
  CheckEquals(C1.Position.X, 200, Format('C1.Position.X : %f', [C1.Position.X]));

  TestLib.RunMouseClick(120, 120);
  TestLib.RunMousePath(MousePath.New
  .Add(250, 250)
  .Add(200, 200)
  .Add(230, 230).Path);

  Check(C1.Parent <> P1, 'Not contain');

  FThothController.Undo;

  Check(C1.Parent = P1, 'Undo> Contain');
  CheckEquals(C1.Position.X, 200, Format('Undo> C1.Position.X : %f', [C1.Position.X]));

  FThothController.Redo;

  Check(C1.Parent <> P1, 'Redo> Not contain');
end;

procedure TestTThItemGrouppingHistory.TestRecoveryIndexMove;
var
  P1, P2, C1: TThItem;
  C1P: TPointF;
begin
  // C1���� P2�� ��ġ�� �׸���
  // C1�� P1�� �ø� �� Undo �� C1�� �״�� P2�Ʒ��� �־�� �Ѵ�.

  P1 := DrawRectangle(10, 10, 130, 130, 'P1');
  C1 := DrawRectangle(150, 150, 200, 200, 'C1');
  P2 := DrawRectangle(170, 170, 250, 250, 'P2');

  C1P := C1.Position.Point;

  TestLib.RunMouseClick(180, 180);
  Check(FCanvas.SelectedItem = P2);

  TestLib.RunMouseClick(155, 155);
  TestLib.RunMousePath(MousePath.New
  .Add(160, 160)
  .Add(100, 100)
  .Add(30, 30).Path);
  Check(C1.Parent = P1, Format('C1.Parent = %s', [C1.Name]));

  FThothController.Undo;

  TestLib.RunMouseClick(180, 180);
  Check(FCanvas.SelectedItem = P2, Format('Selection Item = %s(Not P2)', [FCanvas.SelectedItem.Name]));
  Check(C1.Position.Point = C1P, Format('C1.Position.Point: %f.%f', [C1.Position.Point.X, C1.Position.Point.Y]));
end;

initialization
  RegisterTest(TestTThItemGrouppingHistory.Suite);

end.
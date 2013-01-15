unit TestThItemGroupingMulti;

interface

uses
  TestFramework, BaseTestUnit, FMX.Types, FMX.Forms,
  System.UITypes, System.Types, System.SysUtils, FMX.Controls, System.UIConsts;

type
  // #260 �ߺ� �׷����� ó���Ǿ� �Ѵ�.
  // #256 �׷��� ���� �� ��Ÿ
  TestTThItemGrouppingMulti = class(TBaseCommandHistoryTestUnit)
  published
    // #259 P1���� P2�� C1�� �ø��� P1>P2>C1���� �׷��� �ȴ�.
    procedure TestOverlapItem;

    // #251 P1�� C1�� �ö� ���¼� P2�� C1���� ũ�� P1�� �ø��� P1>P2>C1���� �׷��εȴ�.
    procedure TestMoveGroupingAndContain;

    // #265 Undo/Redo �� �θ� ���� �Ǿ�� �Ѵ�.
    procedure TestCmdHistoryRecoveryParent_Move;
    procedure TestCmdHistoryRecoveryParent_Add;
    procedure TestCmdHistoryRecoveryParent_Delete;
    procedure TestCmdHistoryRecoveryParent_Resize;
  end;

implementation

uses
  FMX.TestLib, ThItem, ThShapeItem, ThItemFactory, ThConsts, System.Math, DebugUtils;

{ TestTThItemGrouppingMulti }

procedure TestTThItemGrouppingMulti.TestOverlapItem;
var
  P1, P2, C1: TThItem;
begin
  P1 := DrawRectangle(10, 10, 200, 200, 'P1');
  P2 := DrawCircle(30, 30, 180, 180, 'P2');
  C1 := DrawRectangle(70, 70, 120, 120, 'C1');

  Check(P2.Parent = P1, Format('P2 parent is %s(not P1)', [P2.Parent.Name]));
  Check(C1.Parent = P2, Format('C1 parent is %s(not P2)', [C1.Parent.Name]));
  CheckEquals(C1.Position.X, 400, Format('C1.Position.X = %f', [C1.Position.X]));
end;

procedure TestTThItemGrouppingMulti.TestMoveGroupingAndContain;
var
  P1, P2, C1: TThItem;
begin
  P1 := DrawRectangle(10, 10, 150, 150, 'P1');
  P2 := DrawRectangle(160, 20, 260, 140, 'P2');
  C1 := DrawRectangle(40, 40, 110, 110, 'C1');

  TestLib.RunMouseClick(170, 30);
  TestLib.RunMousePath(MousePath.New
  .Add(180, 30)
  .Add(100, 30)
  .Add(40, 30).Path);

  Check(P1.ItemCount = 1);
  Check(C1.Parent = P2, C1.Parent.Name);
  CheckEquals(P2.Position.X, 100, 3, Format('P2.X : %f', [P2.Position.X]));
  CheckEquals(C1.Position.X, 200, 3, Format('C1.X : %f', [C1.Position.X]));
end;

procedure TestTThItemGrouppingMulti.TestCmdHistoryRecoveryParent_Add;
begin

end;

procedure TestTThItemGrouppingMulti.TestCmdHistoryRecoveryParent_Delete;
begin

end;

procedure TestTThItemGrouppingMulti.TestCmdHistoryRecoveryParent_Move;
var
  P1, P2, C1: TThItem;
begin
  P1 := DrawRectangle(10, 10, 150, 150, 'P1');
  C1 := DrawRectangle(160, 160, 210, 210, 'C1');

  TestLib.RunMousePath(MousePath.New
  .Add(180, 180)
  .Add(100, 30)
  .Add(30, 30).Path);

  Check(C1.Parent = P1, 'Contain');

  FThothController.Undo;

  Check(C1.Parent <> P1, Format('After Undo: %s', [C1.Parent.Name]));
end;

procedure TestTThItemGrouppingMulti.TestCmdHistoryRecoveryParent_Resize;
begin

end;

initialization
  RegisterTest(TestTThItemGrouppingMulti.Suite);

end.

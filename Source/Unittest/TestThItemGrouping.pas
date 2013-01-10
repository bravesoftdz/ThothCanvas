unit TestThItemGrouping;

interface

uses
  TestFramework, BaseTestUnit, FMX.Types, FMX.Forms,
  System.UITypes, System.Types, System.SysUtils, FMX.Controls, System.UIConsts;

type
  // #19 ĵ������ ���� �߰��Ѵ�.
  TestTThItemGroupping = class(TBaseTestUnit)
  published
    // #244 P1�� C1�� �����ϴ� �������� �̵��ϴ� ��� C1�� �׷��� �Ǿ�� �Ѵ�.
    procedure TestP1MoveOuterC1;
    // #235 C1�� P1�� �������� �̵� �� �׷��� �ȴ�.
    procedure TestC1MoveInnerP1;
    // #242 �׷��� ���Ŀ� ������ ���� ��ο� ��ġ�ؾ��Ѵ�.
    procedure TestGroupingAbsPos;
    procedure TestGroupingAbsPos2;
  end;

implementation

uses
  FMX.TestLib, ThItem, ThShapeItem, ThItemFactory, ThConsts, System.Math, DebugUtils;

{ TestTThItemGroupping }

procedure TestTThItemGroupping.TestP1MoveOuterC1;
begin
  DrawRectangle(0, 0, 100, 100); // P1
  DrawRectangle(130, 130, 170, 170);   // C1

//  TestLib.RunMouseClick(30, 30);
  MousePath.New
  .Add(30, 30)
  .Add(180, 180)
  .Add(130, 130);
  TestLib.RunMousePath(MousePath.Path);

  Check(FCanvas.ItemCount = 1, Format('ItemCount = %d', [FCanvas.ItemCount]));
end;

procedure TestTThItemGroupping.TestC1MoveInnerP1;
begin
  DrawRectangle(10, 10, 50, 50);   // C1
  DrawRectangle(100, 100, 200, 200); // P1

//  TestLib.RunMouseClick(30, 30);
  MousePath.New
  .Add(30, 30)
  .Add(180, 180)
  .Add(150, 150);
  TestLib.RunMousePath(MousePath.Path);

  Check(FCanvas.ItemCount = 1, Format('ItemCount = %d', [FCanvas.ItemCount]));
end;

procedure TestTThItemGroupping.TestGroupingAbsPos;
var
  P1, C1: TThItem;
begin
  DrawRectangle(0, 0, 100, 100); // P1
  TestLib.RunMouseClick(50, 50);
  P1 := FCanvas.SelectedItem;
  DrawRectangle(130, 130, 170, 170);   // C1
  TestLib.RunMouseClick(150, 150);
  C1 := FCanvas.SelectedItem;

  CheckEquals(C1.Position.X, -200);

//  TestLib.RunMouseClick(30, 30);
  MousePath.New
  .Add(30, 30)
  .Add(180, 180)
  .Add(130, 130);
  TestLib.RunMousePath(MousePath.Path);

  Check(FCanvas.ItemCount = 1, Format('ItemCount = %d', [FCanvas.ItemCount]));

//  C1.Position.X := 300;
  CheckEquals(C1.Position.X, -200 - P1.Position.X, 0.00001);
end;

procedure TestTThItemGroupping.TestGroupingAbsPos2;
var
  P1, C1: TThItem;
begin
  DrawRectangle(10, 10, 50, 50);   // C1
  TestLib.RunMouseClick(30, 30);
  C1 := FCanvas.SelectedItem;
  DrawRectangle(100, 100, 200, 200); // P1
  TestLib.RunMouseClick(150, 150);
  P1 := FCanvas.SelectedItem;

//  TestLib.RunMouseClick(30, 30);
  MousePath.New
  .Add(30, 30)
  .Add(180, 180)
  .Add(150, 150);
  TestLib.RunMousePath(MousePath.Path);

  Check(FCanvas.ItemCount = 1, Format('ItemCount = %d', [FCanvas.ItemCount]));

//  C1.Position.X := 300;
  CheckEquals(Round(C1.Position.X), Round(-200 - P1.Position.X), 0.00001);
end;

initialization
  RegisterTest(TestTThItemGroupping.Suite);

end.

unit TestThItemCircle;
{

  Delphi DUnit Test Case
  ----------------------
  This unit contains a skeleton test case class generated by the Test Case Wizard.
  Modify the generated code to correctly setup and call the methods from the unit 
  being tested.

}

interface

uses
  TestFramework, BaseTestUnit, FMX.Types, FMX.Forms,
  System.UITypes, System.Types, System.SysUtils, FMX.Controls, System.UIConsts;

type
  // Test methods for class TThCircle

  // #21 캔버스에 원을 추가한다.
  TestTThCircle = class(TThCanvasBaseTestUnit)
  published
    procedure TestItemFactory;

    // #116 마우스 드래그로 시작점과 끝점을 이용해 도형을 그린다.
    procedure TestDrawCircle;

    // #117 끝점이 시작점의 앞에 있어도 그려져야 한다.
    procedure TestDrawCircleRightToLeft;

    // #118 최소 크기로 그려진다.
    procedure TestDrawCircleMinimum;

    // #120 크기 조정이 가능해야 한다.
    procedure TestCircleResize;
    // #121 반대방향으로도 크기조정이 가능해야 한다.
    procedure TestCircleResizeLeftToRight;
    procedure TestCircleResizeTopToBottom;
    procedure TestCircleResizeRightToLeft;
    procedure TestCircleResizeBottomToTop;
    // #119 크기조정 시 최소 크기가 적용되어야 한다.
    procedure TestCircleResizeEx;
  end;

implementation

uses
  FMX.TestLib, ThItem, ThShapeItem, ThItemFactory, ThConsts;

{ TestTThCircle }

procedure TestTThCircle.TestItemFactory;
var
  Item: TThItem;
begin
  // 1300 is Circle
  Item := ItemFactory.Get(1300);
  try
    Check(Assigned(Item));
  finally
    if Assigned(Item) then
      Item.Free;
  end;
end;

procedure TestTThCircle.TestDrawCircle;
var
  Item: TThItem;
begin
  DrawCircle(50, 50, 200, 200);

  TestLib.RunMouseClick(100, 100);
  Item := FCanvas.SelectedItem;

  Check(Assigned(Item), 'Check SelectedItem');
  Check(Item.ClassType = TThCircle, 'Check Class type');

  Check(Item.Position.X = -100, Format('X = %f', [Item.Position.X]));
  Check(Item.Width = 150,     Format('Width = %f', [Item.Width]));
end;

procedure TestTThCircle.TestDrawCircleRightToLeft;
var
  Item: TThItem;
begin
  DrawCircle(200, 200, 50, 50);

  TestLib.RunMouseClick(100, 100);
  Item := FCanvas.SelectedItem;

  Check(Assigned(Item), 'Check SelectedItem');
  Check(Item.ClassType = TThCircle, 'Check Class type');

  Check(Item.Position.X = -100, Format('X = %f', [Item.Position.X]));
  Check(Item.Width = 150,     Format('Width = %f', [Item.Width]));
end;

procedure TestTThCircle.TestDrawCircleMinimum;
var
  Item: TThItem;
begin
  DrawCircle(50, 50, 50, 50);

  TestLib.RunMouseClick(65, 65);
  Item := FCanvas.SelectedItem;

  Check(Assigned(Item), 'Check SelectedItem');
  Check(Item.ClassType = TThCircle, 'Check Class type');

  Check(Item.Width = 30,     Format('Width = %f', [Item.Width]));
end;

procedure TestTThCircle.TestCircleResize;
begin
  DrawCircle(50, 50, 100, 100);
  TestLib.RunMouseClick(65, 65);

  MousePath.New
  .Add(100, 75)
  .Add(120, 75)
  .Add(150, 75);
  TestLib.RunMousePath(MousePath.Path);
  TestLib.RunMouseClick(150, 150);

  TestLib.RunMouseClick(130, 75);
  Check(Assigned(FCanvas.SelectedItem), 'Not assigned');
  Check((FCanvas.SelectedItem.Width = 100) and (FCanvas.SelectedItem.Height = 50),
    Format('W,H : %f, %f', [FCanvas.SelectedItem.Width, FCanvas.SelectedItem.Height]));
end;

procedure TestTThCircle.TestCircleResizeLeftToRight;
begin
  DrawCircle(50, 50, 150, 150);
  TestLib.RunMouseClick(100, 100);

  MousePath.New
  .Add(50, 100)
  .Add(150, 100)
  .Add(200, 100);
  TestLib.RunMousePath(MousePath.Path);
  TestLib.RunMouseClick(0, 0);

  TestLib.RunMouseClick(175, 100);
  Check(Assigned(FCanvas.SelectedItem), 'Not assigned');
  Check((Round(FCanvas.SelectedItem.Width) = 50) and (FCanvas.SelectedItem.Height = 100),
    Format('W,H : %f, %f', [FCanvas.SelectedItem.Width, FCanvas.SelectedItem.Height]));
end;

procedure TestTThCircle.TestCircleResizeTopToBottom;
begin
  DrawCircle(50, 50, 150, 150);
  TestLib.RunMouseClick(100, 100);

  MousePath.New
  .Add(100, 50)
  .Add(100, 150)
  .Add(100, 200);
  TestLib.RunMousePath(MousePath.Path);
  TestLib.RunMouseClick(0, 0);

  TestLib.RunMouseClick(100, 175);
  Check(Assigned(FCanvas.SelectedItem), 'Not assigned');
  Check((FCanvas.SelectedItem.Width = 100) and (Round(FCanvas.SelectedItem.height) = 50),
    Format('W,H : %f, %f', [FCanvas.SelectedItem.Width, FCanvas.SelectedItem.Height]));
end;

procedure TestTThCircle.TestCircleResizeRightToLeft;
begin
  DrawCircle(150, 150, 250, 250);
  TestLib.RunMouseClick(200, 200);

  MousePath.New
  .Add(250, 200)
  .Add(150, 200)
  .Add(50, 200);
  TestLib.RunMousePath(MousePath.Path);
  TestLib.RunMouseClick(0, 0);

  TestLib.RunMouseClick(100, 200);
  Check(Assigned(FCanvas.SelectedItem), 'Not assigned');
  Check((Round(FCanvas.SelectedItem.Width) = 100) and (Round(FCanvas.SelectedItem.Height) = 100),
    Format('W,H : %f, %f', [FCanvas.SelectedItem.Width, FCanvas.SelectedItem.Height]));
end;

procedure TestTThCircle.TestCircleResizeBottomToTop;
begin
  DrawCircle(100, 100, 200, 200);

  TestLib.RunMouseClick(165, 165);

  //크기 조정(50, 50, 150, 100)
  MousePath.New
  .Add(150, 200)
  .Add(150, 100)
  .Add(150, 50);
  TestLib.RunMousePath(MousePath.Path);
  TestLib.RunMouseClick(0, 0);

  TestLib.RunMouseClick(150, 75);
  Check(Assigned(FCanvas.SelectedItem), 'Not assigned');
  Check((FCanvas.SelectedItem.Width = 100) and (FCanvas.SelectedItem.height = 50),
    Format('W,H : %f, %f', [FCanvas.SelectedItem.Width, FCanvas.SelectedItem.Height]));
end;

procedure TestTThCircle.TestCircleResizeEx;
begin
  DrawCircle(100, 100, 200, 200);

  TestLib.RunMouseClick(165, 165);

  //크기 조정(50, 50, 150, 100)
  MousePath.New
  .Add(150, 100)
//  .Add(150, 185)
  .Add(200, 185)
  .Add(150, 190);
  TestLib.RunMousePath(MousePath.Path);
  TestLib.RunMouseClick(0, 0);

  TestLib.RunMouseClick(150, 185);
  Check(Assigned(FCanvas.SelectedItem), 'Not assigned');
  Check((FCanvas.SelectedItem.Width = 100) and (FCanvas.SelectedItem.height = 30),
    Format('W,H : %f, %f', [FCanvas.SelectedItem.Width, FCanvas.SelectedItem.Height]));
end;

initialization
  // Register any test cases with the test runner
  RegisterTest(TestTThCircle.Suite);
end.


unit TestThShape;
{

  Delphi DUnit Test Case
  ----------------------
  This unit contains a skeleton test case class generated by the Test Case Wizard.
  Modify the generated code to correctly setup and call the methods from the unit
  being tested.

}

interface

uses
  TestFramework, BaseTestUnit, FMX.Types,
  System.UITypes, System.Types, System.SysUtils, FMX.Controls, System.UIConsts;

type
  TestTThShape = class(TBaseTestUnit)
  private
    FTestClick: Boolean;
    procedure _Test(Sender: TObject);
  published
    procedure TestItemFactory;

    // #36 마우스 드래그로 시작점과 끝점을 이용해 도형을 그린다.
    procedure TestDrawRectangle;

    // #56 사각형 영역을 클릭하면 사각형이 선택되어야 한다.
    procedure TestRectangleSelect;

    // #54 캔버스 트래킹 이후 마우스 드래그 시 드래그한 위치에 그려져야 한다.
    procedure TestCanvasTrackingAndDrawRectangle;

    // #53 캔버스 Tracking 시 Rectangle이 Canvas 영역 밖으로 나오지 않는다.
    procedure TestRectangleOutOfCanvas;

    // #38 도형에 마우스 오버시 하이라이트 효과가 나타난다.
    procedure TestRectangleShowHighlight;

    // #37 끝점이 시작점 앞에 있어도 그려져야 한다.
    procedure TestDrawRectangleBRToTL;  // BottomRight > TopLeft
    procedure TestDrawRectangleTRToBL;  // TopRight > BottomLeft
    procedure TestDrawRectangleBLToTR;  // BottomLeft > TopRight

  end;

implementation

uses
  FMX.TestLib, ThItem, ThShape, ThItemFactory;

{ TestTThShape }

procedure TestTThShape.TestItemFactory;
var
  Item: TThItem;
begin
  // Not assigned number 0
  Item := ItemFactory.Get(0);
  try
    Check(not Assigned(Item));
  finally
    if Assigned(Item) then
      Item.Free;
  end;

  // 1100 is Rectangle
  Item := ItemFactory.Get(1100);
  try
    Check(Assigned(Item));
  finally
    if Assigned(Item) then
      Item.Free;
  end;
end;

procedure TestTThShape.TestDrawRectangle;
var
  Item: TThItem;
begin
  // Draw
  FCanvas.DrawItemID := 1100;   // 1100 is Rectangles ID

  MousePath.New
  .Add(50, 50)
  .Add(200, 200);
  TestLib.RunMousePath(MousePath.Path);

  // Select
  TestLib.MouseClick(100, 100);

  Item := FCanvas.SelectedItem;

  Check(Assigned(Item), 'Check SelectedItem');
  Check(Item.ClassType = TThRectangle, 'Check Class type');

  Check(Item.Position.X = 50, Format('X = %f', [Item.Position.X]));
  Check(Item.Width = 150,     Format('Width = %f', [Item.Width]));
end;

// S1.100,50 으로 Canvas 이동 후 0,0 > 100, 100 Rectangle 그리면
//    Rectangle의 좌표는 -100, -50 이어야 한다.
procedure TestTThShape.TestCanvasTrackingAndDrawRectangle;
var
  Item: TThItem;
begin
  // Tracking
  MousePath.New
  .Add(0, 0)
  .Add(10, 0)
  .Add(100, 50);
  TestLib.RunMousePath(MousePath.Path);

  Check(FCanvas.ContentPos.X = 100);

  // Draw Rectangle
  FCanvas.DrawItemID := 1100;
  MousePath.New
  .Add(10, 10)
  .Add(10, 20)
  .Add(100, 100);
  TestLib.RunMousePath(MousePath.Path);

  Check(FCanvas.ItemCount = 1);

  // Select
  TestLib.MouseClick(50, 50);

  Item := FCanvas.SelectedItem;

  Check(Assigned(Item), 'not assigned');
  Check(Item.Position.X = -90, Format('Postion.X : %f', [Item.Position.X]));
  Check(Item.Position.Y = -40, Format('Postion.Y : %f', [Item.Position.Y]));
end;

procedure TestTThShape.TestRectangleSelect;
begin
  // Draw Rectangle
  FCanvas.DrawItemID := 1100;
  MousePath.New
  .Add(50, 50)
  .Add(100, 100);
  TestLib.RunMousePath(MousePath.Path);

  // Select
  TestLib.MouseClick(60, 60);

  Check(Assigned(FCanvas.SelectedItem));
end;

// S1.0,0에 Rectangle을 그리고 -100, -100 이동한 후
//    -30, -30을 클릭하면 그영역에 있는 버튼이 클릭되야 한다.
procedure TestTThShape.TestRectangleOutOfCanvas;
var
  Button: TButton;
begin
  Button := TButton.Create(FForm);
  Button.Parent := FForm;
  Button.Position.Point := PointF(0,0);
  Button.OnClick := _Test;
  Button.Width := 50;
  Button.Height := 100;
  Button.SendToBack;

  // Draw Rectangle
  FCanvas.DrawItemID := 1100;
  MousePath.New
  .Add(10, 10)
  .Add(100, 100)
  .Add(150, 150);
  TestLib.RunMousePath(MousePath.Path);

  // Canvas Tracking
  MousePath.New
  .Add(160, 160)
  .Add(80, 80)
  .Add(60, 60);
  TestLib.RunMousePath(MousePath.Path);

  // Button Click
  TestLib.MouseClick(-30, -30);

//  Check(FCanvas.SelectedItem.LocalToAbsolute(PointF(0, 0)).X = -30, Format('Postion.X : %f', [FCanvas.SelectedItem.LocalToAbsolute(PointF(0, 0)).X]));
  Check(FTestClick, '버튼이 클릭되지 않음');
end;

procedure TestTThShape.TestRectangleShowHighlight;
var
  R: TThRectangle;
  AC: TAlphaColor;
begin
  // Hightlight size 10

  // 10,10,100,100 그리기
  FCanvas.DrawItemID := 1100;
  MousePath.New
  .Add(10, 10)
  .Add(50, 50)
  .Add(100, 100);
  TestLib.RunMousePath(MousePath.Path);

  // 50,50 클릭 선택
  TestLib.MouseClick(50, 50);

  R := TThRectangle(FCanvas.SelectedItem);

  Check(Assigned(R), 'Not assigned');

  R.Opacity := 1;
  R.Highlighter.HighlightColor := claGray;
  R.Highlighter.HighlightSize := 10;

  // 105.105 색상확인
  AC := TestLib.GetControlPixelColor(FCanvas, 105, 105);
  Check(AC = claGray, 'Not matching Color');
//  Check(TestLib.GetControlPixelColor(FCanvas, 105, 105) = claGray);
end;

// BottomRight > TopLeft
procedure TestTThShape.TestDrawRectangleBRToTL;
begin
  FCanvas.DrawItemID := 1100;
  MousePath.New
  .Add(100, 100)
  .Add(50, 50)
  .Add(10, 10);
  TestLib.RunMousePath(MousePath.Path);

  TestLib.MouseClick(50, 50);

  Check(Assigned(FCanvas.SelectedItem));
  Check(FCanvas.SelectedItem.Position.X = 10, Format('X : %f', [FCanvas.SelectedItem.Position.X]));
end;

// TopRight > BottomLeft
procedure TestTThShape.TestDrawRectangleTRToBL;
begin
  FCanvas.DrawItemID := 1100;
  MousePath.New
  .Add(100, 10)
  .Add(50, 50)
  .Add(10, 100);
  TestLib.RunMousePath(MousePath.Path);

  TestLib.MouseClick(50, 50);

  Check(Assigned(FCanvas.SelectedItem));
  Check(FCanvas.SelectedItem.Position.X = 10, Format('X : %f', [FCanvas.SelectedItem.Position.X]));
end;

// BottomLeft > TopRight
procedure TestTThShape.TestDrawRectangleBLToTR;
begin
  FCanvas.DrawItemID := 1100;
  MousePath.New
  .Add(10, 100)
  .Add(50, 50)
  .Add(100, 10);
  TestLib.RunMousePath(MousePath.Path);

  TestLib.MouseClick(50, 50);

  Check(Assigned(FCanvas.SelectedItem));
  Check(FCanvas.SelectedItem.Position.X = 10, Format('X : %f', [FCanvas.SelectedItem.Position.X]));
end;

procedure TestTThShape._Test(Sender: TObject);
begin
  FTestClick := True;
end;

initialization
  RegisterTest(TestTThShape.Suite);

end.


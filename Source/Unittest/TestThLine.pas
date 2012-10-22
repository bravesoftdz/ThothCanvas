unit TestThLine;
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
  // #19 캔버스에 선을 추가한다.
  TestTThLine = class(TBaseTestUnit)
  published
    procedure TestItemFactory;

    // #74 마우스 드래그로 시작점과 끝점을 이용해 도형을 그린다.
    procedure TestDrawLineTLtoBR;
    // #75 끝점이 시작점의 앞에 있어도 그려져야 한다.
    procedure TestDrawLineTRtoBL;
    procedure TestDrawLineBLtoTR;
    procedure TestDrawLineBRtoTL;

    // #76 도형에 마우스 오버시 하이라이트 효과가 나타난다.
    procedure TestLineMouseOverHighlight;

    // #99 선을 넘어서는 일직선 범위를 클릭 시 선이 선택된다.
    procedure BugTestLineOutOfRange;

    // #98 선이 아닌 다른 지역에 대해 선택이 되지 않아야 한다.
    procedure TestLineSelectionRange;

    // #97 수직선, 수평선을 그릴 수 있어야 한다.
    procedure TestLineHorizon;
    procedure TestLineVertical;

    // #77 최소 크기를 갖으며 그리거나 크기조정 시 반영된다.
    procedure TestLineMinimumSize;

    // #43 선의 일정간격 내에서도 마우스로 선택되어야 한다.
    procedure TestRangeSelectHorizonOverY;  // 수평선
    procedure TestRangeSelectVerticalOverX; // 수직선
    procedure TestRangeSelectLineTLtoBR;

//    procedure TestSelectLineOverXY;
    // #80 SizeSpot을 드래그 하여 크기를 변경 할 수 있다.
    procedure TestResizeLine;

    procedure TestResizeLineBRtoBottom;
    procedure TestResizeLineBottomtoBLOver;
    procedure TestResizeLineTLtoBROver;
    procedure TestResizeLineTLtoRightOver;
//    procedure TestResizeLineTLtoBottomOver;
//    procedure TestResizeLineTRtoBLOver;
//    procedure TestResizeLineBLtoTROver;
//    procedure TestResizeLineBRtoTLOver;
//
    // #100 크기조정 시 최소 크기가 적용되어야 한다.
    procedure TestResizeMinimum;
//    procedure TestResizeMinimum2;
//    procedure TestResizeSpotSamePosition;
  end;

implementation

uses
  FMX.TestLib, ThItem, ThShape, ThItemFactory, ThConsts, CommonUtils;

{ TestTThShape }

procedure TestTThLine.TestItemFactory;
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

  Item := ItemFactory.Get(1200);
  try
    Check(Assigned(Item));
  finally
    if Assigned(Item) then
      Item.Free;
  end;
end;

procedure TestTThLine.TestDrawLineTLtoBR;
begin
  // TopLeft > BottomRight
  DrawLine(10, 10, 100, 100);

  Check(TestLib.GetControlPixelColor(FCanvas, 20, 20) = ItemShapeDefaultColor, 'TopLeft > BottomRight - 1');
  Check(TestLib.GetControlPixelColor(FCanvas, 90, 90) = ItemShapeDefaultColor, 'TopLeft > BottomRight - 2');
end;

procedure TestTThLine.TestDrawLineTRtoBL;
begin
  // TopRight > BottomLeft
  DrawLine(100, 10, 10, 100);

  Check(TestLib.GetControlPixelColor(FCanvas, 90, 20) = ItemShapeDefaultColor, 'TopRight > BottomLeft - 1');
  Check(TestLib.GetControlPixelColor(FCanvas, 20, 90) = ItemShapeDefaultColor, 'TopRight > BottomLeft - 2');

end;

procedure TestTThLine.TestDrawLineBLtoTR;
begin
  // BottomLeft > TopRight
  DrawLine(10, 100, 100, 10);

  Check(TestLib.GetControlPixelColor(FCanvas, 20, 90) = ItemShapeDefaultColor, 'BottomLeft > TopRight - 1');
  Check(TestLib.GetControlPixelColor(FCanvas, 90, 20) = ItemShapeDefaultColor, 'BottomLeft > TopRight - 2');
end;

procedure TestTThLine.TestDrawLineBRtoTL;
begin
  // BottomRight > TopLeft
  DrawLine(100, 100, 10, 10);

  Check(TestLib.GetControlPixelColor(FCanvas, 20, 20) = ItemShapeDefaultColor, 'BottomRight > TopLeft - 1');
  Check(TestLib.GetControlPixelColor(FCanvas, 90, 90) = ItemShapeDefaultColor, 'BottomRight > TopLeft - 2');
end;

procedure TestTThLine.TestLineMouseOverHighlight;
var
  AC: TAlphaColor;
begin
  // 추가
  DrawLine(10, 10, 100, 100);
  // 선택
  TestLib.RunMouseClick(50, 50);

  FCanvas.BackgroundColor := claPink;

  // 선택해제
  TestLib.RunMouseClick(150, 150);
  AC := TestLib.GetControlPixelColor(FCanvas, 100 + (ItemHighlightSize - 1), 100 + (ItemHighlightSize - 1));
  Check(AC <> ItemHighlightColor, 'Color is not highlight color');

  MousePath.New
  .Add(150, 150)
  .Add(50, 50);
//  .Add(101, 101);
  TestLib.RunMouseMove(MousePath.Path);

  // 그림자 확인
  AC := TestLib.GetControlPixelColor(FCanvas, 100 + (ItemHighlightSize), 100 + (ItemHighlightSize));
  Check(AC = ItemHighlightColor, 'Not matching Color');
//  Check(AC = claGray, 'Not matching Color');
end;

procedure TestTThLine.BugTestLineOutOfRange;
begin
  // 추가
  DrawLine(10, 10, 100, 100);

  // 영역외 선택
  TestLib.RunMouseClick(150, 150);

  Check(not Assigned(FCanvas.SelectedItem), 'Out of range');

  // 선택
  TestLib.RunMouseClick(50, 50);

  // 선택해제
  TestLib.RunMouseClick(150, 150);

  Check(not Assigned(FCanvas.SelectedItem), 'Unselect');
end;

procedure TestTThLine.TestLineSelectionRange;
begin
  // 추가
  DrawLine(10, 10, 100, 100);

  // 선택 범위 외 선택
  TestLib.RunMouseClick(60, 50);
  CheckNull(FCanvas.SelectedItem, 'Invalid select area');

  // 선택
  TestLib.RunMouseClick(50, 50);
//  CheckTrue(Assigned(FCanvas.SelectedItem));
  CheckNotNull(FCanvas.SelectedItem);
end;

procedure TestTThLine.TestLineHorizon;
begin
  DrawLine(10, 200, 20, 200);

  Check(TestLib.GetControlPixelColor(FCanvas, 10, 197) = ItemShapeDefaultColor, 'Start');
  Check(TestLib.GetControlPixelColor(FCanvas, 20, 197) = ItemShapeDefaultColor, 'End');
end;

procedure TestTThLine.TestLineVertical;
begin
  DrawLine(10, 10, 10, 20);

  Check(TestLib.GetControlPixelColor(FCanvas, 7, 10) = ItemShapeDefaultColor, 'Start');
  Check(TestLib.GetControlPixelColor(FCanvas, 7, 20) = ItemShapeDefaultColor, 'End');
end;

procedure TestTThLine.TestLineMinimumSize;
begin
//  DebugShowForm;
//  DrawLine(10, 30, 40, 30);

  DrawLine(10, 10, 20, 10);

  TestLib.RunMouseClick(15, 10);
  Check(Assigned(FCanvas.SelectedItem));
  Check(FCanvas.SelectedItem.Width = 30, Format('W: %f', [FCanvas.SelectedItem.Width]));

  TestLib.RunMouseClick(150, 150);
  TestLib.RunMouseClick(ItemMinimumSize-1, 10);
  Check(Assigned(FCanvas.SelectedItem));
end;

procedure TestTThLine.TestRangeSelectHorizonOverY;
begin
  DrawLine(10, 10, 100, 10);

  TestLib.RunMouseClick(10, 7);
  Check(Assigned(FCanvas.SelectedItem), 'Top');

  TestLib.RunMouseClick(100, 100);
  TestLib.RunMouseClick(10, 13);
  Check(Assigned(FCanvas.SelectedItem), 'Bottom');

  TestLib.RunMouseClick(100, 100);
  TestLib.RunMouseClick(7, 10);
  Check(Assigned(FCanvas.SelectedItem), 'Left');

  TestLib.RunMouseClick(100, 100);
  TestLib.RunMouseClick(103, 10);
  Check(Assigned(FCanvas.SelectedItem), 'Right');
end;

procedure TestTThLine.TestRangeSelectVerticalOverX;
begin
  DrawLine(10, 10, 10, 100);

  TestLib.RunMouseClick(100, 100);
  TestLib.RunMouseClick(10, 7);
  Check(Assigned(FCanvas.SelectedItem), 'Top');

  TestLib.RunMouseClick(100, 100);
  TestLib.RunMouseClick(13, 10);
  Check(Assigned(FCanvas.SelectedItem), 'Right');

  TestLib.RunMouseClick(100, 100);
  TestLib.RunMouseClick(7, 10);
  Check(Assigned(FCanvas.SelectedItem), 'Left');

  TestLib.RunMouseClick(100, 100);
  TestLib.RunMouseClick(10, 103);
  Check(Assigned(FCanvas.SelectedItem), 'Bottom');
end;

procedure TestTThLine.TestRangeSelectLineTLtoBR;
var
  Rect: TRectF;
  P, P2, B, DP: TPointF;
  D, R: Single;
begin
//DebugShowForm;

  Rect := RectF(10, 10,100, 100);
  DrawLine(Rect);

  D := (ItemLineThickness - 1) / 2;
  P := Rect.CenterPoint;
  R := ArcTan(Rect.Height/Rect.Width);

  B := PointF(Sin(R) * D, Cos(R) * D);
  DP := PointF(B.X, -B.Y);
//  DP.X := Sin(R) * D;
//  DP.Y := Cos(R) * D;

//  Debug('%f, %f', [DP.X, DP.Y]);

  P2 := P.Add(PointF(DP.X, -DP.Y));
  TestLib.RunMouseClick(200, 200);
  TestLib.RunMouseClick(P2.X, P2.Y);
  Check(Assigned(FCanvas.SelectedItem), Format('Top D Point(%f, %f)', [P2.X, P2.Y]));

  P2 := P.Add(PointF(-DP.X, DP.Y));
  TestLib.RunMouseClick(200, 200);
  TestLib.RunMouseClick(P2.X, P2.Y);
  Check(Assigned(FCanvas.SelectedItem), Format('Bottom D Point(%f, %f)', [P2.X, P2.Y]));

  P2 := P.Add(PointF(0, -D/Cos(R)));
  TestLib.RunMouseClick(200, 200);
  TestLib.RunMouseClick(P2.X, P2.Y);
  Check(Assigned(FCanvas.SelectedItem), Format('Center Top(%f, %f)', [P2.X, P2.Y]));

  P2 := P.Add(PointF(-D/Sin(R), 0));
  TestLib.RunMouseClick(200, 200);
  TestLib.RunMouseClick(P2.X, P2.Y);
  Check(Assigned(FCanvas.SelectedItem), Format('Center Left(%f, %f)', [P2.X, P2.Y]));

  P2 := P.Add(PointF(D/Sin(R), 0));
  TestLib.RunMouseClick(200, 200);
  TestLib.RunMouseClick(P2.X, P2.Y);
  Check(Assigned(FCanvas.SelectedItem), Format('Center Right(%f, %f)', [P2.X, P2.Y]));

  P2 := P.Add(PointF(0, D/Cos(R)));
  TestLib.RunMouseClick(200, 200);
  TestLib.RunMouseClick(P2.X, P2.Y);
  Check(Assigned(FCanvas.SelectedItem), Format('Center Bottom(%f, %f)', [P2.X, P2.Y]));

  P2 := Rect.TopLeft.Add(PointF(-B.X, B.Y));
  TestLib.RunMouseClick(200, 200);
  TestLib.RunMouseClick(P2.X, P2.Y);
  Check(Assigned(FCanvas.SelectedItem), Format('TopLeft Left(%f, %f)', [P2.X, P2.Y]));

  P2 := Rect.TopLeft.Add(PointF(B.X, - B.Y));
  TestLib.RunMouseClick(200, 200);
  TestLib.RunMouseClick(P2.X, P2.Y);
  Check(Assigned(FCanvas.SelectedItem), Format('TopLeft Top(%f, %f)', [P2.X, P2.Y]));

  P2 := Rect.TopLeft.Add(PointF(-B.Y, -B.X));
  TestLib.RunMouseClick(200, 200);
  TestLib.RunMouseClick(P2.X, P2.Y);
  Check(Assigned(FCanvas.SelectedItem), Format('TopLeft TopLeft(%f, %f)', [P2.X, P2.Y]));

  P2 := Rect.BottomRight.Add(PointF(B.X, -B.Y));
  TestLib.RunMouseClick(200, 200);
  TestLib.RunMouseClick(P2.X, P2.Y);
  Check(Assigned(FCanvas.SelectedItem), Format('BottomRight Right(%f, %f)', [P2.X, P2.Y]));

  P2 := Rect.BottomRight.Add(PointF(-B.X, B.Y));
  TestLib.RunMouseClick(200, 200);
  TestLib.RunMouseClick(P2.X, P2.Y);
  Check(Assigned(FCanvas.SelectedItem), Format('BottomRight Bottom(%f, %f)', [P2.X, P2.Y]));

  P2 := Rect.BottomRight.Add(PointF(B.Y, B.X));
  TestLib.RunMouseClick(200, 200);
  TestLib.RunMouseClick(P2.X, P2.Y);
  Check(Assigned(FCanvas.SelectedItem), Format('BottomRight BottomRight(%f, %f)', [P2.X, P2.Y]));
end;

procedure TestTThLine.TestResizeLine;
begin
  // 그리기
  DrawLine(50, 50, 150, 150);
  TestLib.RunMouseClick(100, 100);

  //크기 조정
  MousePath.New
  .Add(150, 150)
  .Add(180, 180)
  .Add(200, 200);
  TestLib.RunMousePath(MousePath.Path);

  TestLib.RunMouseClick(180, 180);
  Check(Assigned(FCanvas.SelectedItem), 'Not assigned');
  Check(FCanvas.SelectedItem.Width = 150, Format('Width : %f', [FCanvas.SelectedItem.Width]));
end;

procedure TestTThLine.TestResizeLineBRtoBottom;
begin
//  DebugShowForm;

  // 그리기
  DrawLine(50, 50, 150, 150);
  TestLib.RunMouseClick(100, 100);

  //크기 조정
  MousePath.New
  .Add(150, 150)
//  .Add(60, 150)
  .Add(50, 150);
  TestLib.RunMousePath(MousePath.Path);

  TestLib.RunMouseClick(50, 120);
  Check(Assigned(FCanvas.SelectedItem), 'Not assigned');
  Check(
    (FCanvas.SelectedItem.Width = 1) and (FCanvas.SelectedItem.Height = 100),
    Format('W: %f, H: %f', [FCanvas.SelectedItem.Width, FCanvas.SelectedItem.Height])
  );
end;

procedure TestTThLine.TestResizeLineBottomtoBLOver;
begin
  ShowForm;

  // 그리기
  DrawLine(250, 50, 250, 150);
  TestLib.RunMouseClick(250, 100);

  //크기 조정
  MousePath.New
  .Add(250, 150)
  .Add(245, 150)
  .Add(150, 150);
  TestLib.RunMousePath(MousePath.Path);

  TestLib.RunMouseClick(200, 100);
  Check(Assigned(FCanvas.SelectedItem), 'Not assigned');
  Check(
    (FCanvas.SelectedItem.Width = 100) and (FCanvas.SelectedItem.Height = 100),
    Format('W: %f, H: %f', [FCanvas.SelectedItem.Width, FCanvas.SelectedItem.Height])
  );
end;

procedure TestTThLine.TestResizeLineTLtoBROver;
begin
  // 그리기
  DrawLine(50, 50, 150, 150);
  TestLib.RunMouseClick(100, 100);

  //크기 조정
  MousePath.New
  .Add(50, 50)
  .Add(220, 220)
  .Add(250, 250);
  TestLib.RunMousePath(MousePath.Path);

  TestLib.RunMouseClick(180, 180);
  Check(Assigned(FCanvas.SelectedItem), 'Not assigned');
  Check(
    (FCanvas.SelectedItem.Width = 100) and (FCanvas.SelectedItem.Height = 100),
    Format('W: %f, H: %f', [FCanvas.SelectedItem.Width, FCanvas.SelectedItem.Height])
  );
end;

procedure TestTThLine.TestResizeLineTLtoRightOver;
begin
//  DebugShowForm;
  // 그리기
  DrawLine(50, 50, 150, 150);
  TestLib.RunMouseClick(100, 100);

  //크기 조정(150, 60, 250, 150)
  MousePath.New
  .Add(50, 50)
  .Add(180, 55)
  .Add(250, 50);
  TestLib.RunMousePath(MousePath.Path);

  TestLib.RunMouseClick(200, 100);
  Check(Assigned(FCanvas.SelectedItem), 'Not assigned');
  Check(
    (FCanvas.SelectedItem.Width = 100) and (FCanvas.SelectedItem.Height = 100),
    Format('W: %f, H: %f', [FCanvas.SelectedItem.Width, FCanvas.SelectedItem.Height])
  );
end;

// S - 100 크기를 20으로 줄였을때 30이 되어야 한다.
procedure TestTThLine.TestResizeMinimum;
var
  SizeP: TPointF;
begin
  DrawLine(50, 50, 150, 150);
  TestLib.RunMouseClick(100, 100);

  //크기 조정
  MousePath.New
  .Add(150, 150)
  .Add(180, 180)
  .Add(70, 70);
  TestLib.RunMousePath(MousePath.Path);

  SizeP := DistanceSize(RectF(50, 50, 80, 80), ItemMinimumSize);

  Check(Assigned(FCanvas.SelectedItem), 'Not assigned');
  Check(FCanvas.SelectedItem.Width = SizeP.X, Format('W: %f', [FCanvas.SelectedItem.Width]));
end;

{
procedure TestTThLine.TestResizeLineTLtoBottomOver;
begin
  // 그리기
  DrawLine(50, 50, 150, 150);
  TestLib.RunMouseClick(100, 100);

  //크기 조정(60, 150, 150, 250)
  MousePath.New
  .Add(50, 50)
  .Add(180, 180)
  .Add(60, 250);
  TestLib.RunMousePath(MousePath.Path);

  TestLib.RunMouseClick(100, 180);
  Check(Assigned(FCanvas.SelectedItem), 'Not assigned');
  Check(
    (FCanvas.SelectedItem.Width = 90) and (FCanvas.SelectedItem.Height = 100),
    Format('W: %f, H: %f', [FCanvas.SelectedItem.Width, FCanvas.SelectedItem.Height])
  );
end;

procedure TestTThLine.TestResizeLineTRtoBLOver;
begin
  // 그리기
  DrawLine(150, 50, 250, 150);
  TestLib.RunMouseClick(200, 100);

  //크기 조정(60, 150, 150, 250)
  MousePath.New
  .Add(250, 50)
  .Add(180, 180)
  .Add(60, 250);
  TestLib.RunMousePath(MousePath.Path);

  TestLib.RunMouseClick(100, 200);
  Check(Assigned(FCanvas.SelectedItem), 'Not assigned');
  Check(
    (FCanvas.SelectedItem.Width = 90) and (FCanvas.SelectedItem.Height = 100),
    Format('W: %f, H: %f', [FCanvas.SelectedItem.Width, FCanvas.SelectedItem.Height])
  );
end;

procedure TestTThLine.TestResizeLineBLtoTROver;
begin
  // 그리기
  DrawLine(50, 150, 150, 250);
  TestLib.RunMouseClick(100, 200);

  //크기 조정(150, 60, 250, 250)
  MousePath.New
  .Add(50, 250)
  .Add(50, 100)
  .Add(40, 240)
  .Add(250, 60);
  TestLib.RunMousePath(MousePath.Path);

  TestLib.RunMouseClick(200, 100);
  Check(Assigned(FCanvas.SelectedItem), 'Not assigned');
  Check(
    (FCanvas.SelectedItem.Width = 100) and (FCanvas.SelectedItem.Height = 90),
    Format('W: %f, H: %f', [FCanvas.SelectedItem.Width, FCanvas.SelectedItem.Height])
  );
end;

procedure TestTThLine.TestResizeLineBRtoTLOver;
begin
  // 그리기
  DrawLine(150, 150, 250, 250);
  TestLib.RunMouseClick(200, 200);

  //크기 조정(150, 60, 250, 250)
  MousePath.New
  .Add(250, 250)
  .Add(200, 80)
  .Add(70, 80)
  .Add(50, 60);
  TestLib.RunMousePath(MousePath.Path);

  TestLib.RunMouseClick(120, 100);
  Check(Assigned(FCanvas.SelectedItem), 'Not assigned');
  Check(
    (FCanvas.SelectedItem.Width = 100) and (FCanvas.SelectedItem.Height = 90),
    Format('W: %f, H: %f', [FCanvas.SelectedItem.Width, FCanvas.SelectedItem.Height])
  );
end;

// S1 - Spot의 최좌측을 이용해 크기조정
//      1> 이동된 포인터의 X-1 좌표의 색상 확인
//      2> Width 크기변화 확인 100에서 10이동
procedure TestTThLine.TestResizeSpotSamePosition;
var
  SP, EP: TPointF;
  C: TAlphaColor;
begin
  // 그리기
  DrawLine(50, 50, 150, 150);
  TestLib.RunMouseClick(100, 100);

  TestLib.RunMouseMove([PointF(150, 150)]);
  SP := PointF(150 - ItemResizeSpotRadius+1, 150);
  EP := SP;
  EP.Offset(10, 10);

  Check(TestLib.GetControlPixelColor(FCanvas, SP.X, SP.Y) = ItemResizeSpotOverColor, 'Spot color');
  //크기 조정
  MousePath.New
  .Add(SP)
  .Add(180, 180)
  .Add(EP);
  TestLib.RunMousePath(MousePath.Path);

  // 1> 색상확인                                         a
  C := TestLib.GetControlPixelColor(FCanvas, EP.X-1, EP.Y);
  Check(C <> ItemResizeSpotOverColor);

  // 2> 크기확인
  Check(Assigned(FCanvas.SelectedItem), 'Not assigned');
  Check(FCanvas.SelectedItem.Width = 110, Format('Width : %f', [FCanvas.SelectedItem.Width]));
end;

// S - 100 크기를 20으로 줄였을때 30이 되어야 한다.
procedure TestTThLine.TestResizeMinimum;
begin
  DrawLine(50, 50, 150, 150);
  TestLib.RunMouseClick(100, 100);

  //크기 조정
  MousePath.New
  .Add(150, 150)
  .Add(180, 180)
  .Add(70, 70);
  TestLib.RunMousePath(MousePath.Path);

  Check(Assigned(FCanvas.SelectedItem), 'Not assigned');
  Check(FCanvas.SelectedItem.Width = 30, Format('W: %f', [FCanvas.SelectedItem.Width]));
end;

procedure TestTThLine.TestResizeMinimum2;
begin
  DrawLine(100, 100, 200, 200);
  TestLib.RunMouseClick(150, 150);

  MousePath.New
  .Add(200, 200)
  .Add(80, 120);
  TestLib.RunMousePath(MousePath.Path);

  Debug(Format('W: %f, H: %F',[FCanvas.SelectedItem.Width, FCanvas.SelectedItem.Height]));
  Check(Assigned(FCanvas.SelectedItem), 'Not Assigned');
  Check(FCanvas.SelectedItem.Width = 30, Format('Width: %f', [FCanvas.SelectedItem.Width]));
  Check(FCanvas.SelectedItem.Height = 30, Format('Height: %f', [FCanvas.SelectedItem.Height]));
end;
}
initialization
  RegisterTest(TestTThLine.Suite);

end.


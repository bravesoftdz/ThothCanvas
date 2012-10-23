unit TestThCommandHistory;

interface

uses
  TestFramework, BaseTestUnit,
  System.Types, System.SysUtils, FMX.Types, FMX.Objects, System.UIConsts;

type
  // #23 Undo/Redo����� �̿��Ͽ� ����� �ǵ�����.
  TestTThCommandHistory = class(TBaseTestUnit)
  published

  end;

implementation

uses
  UnitTestForm, FMX.TestLib, ThContainer, ThCanvasEditor,
  ThItem, ThShape, ThItemFactory;

initialization
  RegisterTest(TestTThCommandHistory.Suite);

end.


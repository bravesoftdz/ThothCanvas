unit ObjectList;

interface

uses
  System.Classes, System.SysUtils,
  ThothTypes, ThothObjects, ThothCommands;

type
///////////////////////////////////////////////////////
// ObjectList
  TThObjectList = class(TThInterfacedObject, IThObserver)
  private
    FList: TList;
    FBackup: TList;

    procedure InsertShapes(AShapes: TList);
    procedure DeleteShapes(AShapes: TList);
    procedure RestoreShapes(AShapes: TList);
    procedure RemoveShapes(AShapes: TList);
  public
    constructor Create;
    destructor Destroy; override;

    procedure Notifycation(ACommand: IThCommand);
    procedure SetSubject(ASubject: IThSubject);

    procedure test;
  end;


implementation

uses
  WinAPI.Windows;

{ TThObjectList }

constructor TThObjectList.Create;
begin
  FList := TList.Create;
  FBackup := TList.Create;
end;

destructor TThObjectList.Destroy;
var
  I: Integer;
begin
// Canvas���� ó��?
//  for I := FList.Count - 1 downto 0 do
//    TObject(FList[I]).Free;
  FList.Free;

  for I := FBackup.Count - 1 downto 0 do
    TObject(FBackup[I]).Free;
  FBackup.Free;

  inherited;
end;

procedure TThObjectList.InsertShapes(AShapes: TList);
begin
  FList.Assign(AShapes, TListAssignOp.laOr);
end;

procedure TThObjectList.DeleteShapes(AShapes: TList);
var
  I: Integer;
  Shape: TThShape;
begin
  for I := 0 to AShapes.Count - 1 do
  begin
    Shape := TThShape(AShapes[I]);
    Shape.Index := FList.IndexOf(Shape);
    if Shape.Index > -1 then
      FList.Delete(Shape.Index);
    FBackup.Add(Shape);
  end;
end;

procedure TThObjectList.RestoreShapes(AShapes: TList);
var
  I, Idx: Integer;
  Shape: TThShape;
begin
  for I := 0 to AShapes.Count - 1 do
  begin
    Shape := TThShape(AShapes[I]);
    FBackup.RemoveItem(Shape, TList.TDirection.FromEnd);
    FList.Insert(Shape.Index, Shape);
  end;
end;

procedure TThObjectList.RemoveShapes(AShapes: TList);
var
  I: Integer;
begin
  for I := FBackup.Count - 1 downto 0 do
    TObject(FBackup[I]).Free;
end;

procedure TThObjectList.Notifycation(ACommand: IThCommand);
var
  I: Integer;
  Cmd: TThShapeCommand;
begin
  OutputDebugSTring(PChar('TThObjectList - ' + TThShapeCommand(ACommand).ClassName));

  if ACommand is TThInsertShapeCommand then
    InsertShapes(TThShapeCommand(ACommand).List)
    // FList�� �߰�
  else if ACommand is TThDeleteShapeCommand then
    DeleteShapes(TThShapeCommand(ACommand).List)
    // FList���� FBackup���� �̵�, Index�߰�
  else if ACommand is TThRestoreShapeCommand then
    RestoreShapes(TThShapeCommand(ACommand).List)
    // FBackup���� FList�� �̵�(Insert)
  else if ACommand is TThRemoveShapeCommand then
    RemoveShapes(TThShapeCommand(ACommand).List)
    // FBackup���� ���� �� ��ü����
  ;
end;

procedure TThObjectList.SetSubject(ASubject: IThSubject);
begin
  ASubject.RegistObserver(Self);
end;

procedure TThObjectList.test;
var
  I: Integer;
begin
  for I := 0 to FList.Count - 1 do
    with TThShape(FList[I]) do
      OutputDebugString(PChar(Format('%d> %s(W:%f, H:%f, %f,%f / %f,%f)', [I, ClassName, Width, Height, StartPos.X, StartPos.Y, EndPos.X, EndPos.Y])));
end;

end.

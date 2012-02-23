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
    FBackupList: TList;
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
end;

destructor TThObjectList.Destroy;
var
  I: Integer;
begin
  for I := FList.Count - 1 downto 0 do
    TObject(FList[I]).Free;

//  FList.Clear;
  FList.Free;

  inherited;
end;

procedure TThObjectList.Notifycation(ACommand: IThCommand);
var
  I: Integer;
  Cmd: TThShapeCommand;
begin
  OutputDebugSTring(PChar('TThObjectList - ' + TThShapeCommand(ACommand).ClassName));

  if ACommand is TThInsertShapeCommand then
    // FList�� �߰�
  else if ACommand is TThDeleteShapeCommand then
    // FList���� FBackup���� �̵�, Index�߰�
  else if ACommand is TThRestoreShapeCommand then
    // FBackup���� FList�� �̵�(Insert)
  else if ACommand is TThRemoveShapeCommand then
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

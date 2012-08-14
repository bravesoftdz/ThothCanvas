unit ThCommandManager;

interface

uses
  System.Classes, System.SysUtils,
  ThTypes, ThInterface, ThCommand;

type
///////////////////////////////////////////////////////
// Command List
  TThCommandManager = class(TThInterfacedObject, IThObserver)
  private
    FSubject: IThSubject;

    FUndoList: TInterfaceList;
    FRedoList: TInterfaceList;

    FOnChange: TNotifyEvent;
    FLimit: Integer;

    procedure ResizeUndoList(ASize: Integer);
    procedure ClearRedo;
    function ExchangeCommand(ACommand: IThCommand): IThCommand;
//    function ExchangeUndoCommand(ACommand: IThCommand): IThCommand;
//    function ExchangeRedoCommand(ACommand: IThCommand): IThCommand;
  protected
    procedure DoChange;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Notifycation(ACommand: IThCommand);
    procedure SetSubject(ASubject: IThSubject);

    property OnChange: TNotifyEvent read FOnChange write FOnChange;

    procedure Undo;
    procedure Redo;

    function HasUndo: Boolean;
    function HasRedo: Boolean;

    property UndoLimit: Integer read FLimit write FLimit;
  end;


implementation

uses
  System.Math;

{ TThCommandManager }

constructor TThCommandManager.Create;
begin
  FLimit := High(Word) div 2;

  FUndoList := TInterfaceList.Create;
  FRedoList := TInterfaceList.Create;
//  FList.
end;

destructor TThCommandManager.Destroy;
var
  I: Integer;
begin
  FUndoList.Free;
  FRedoList.Free;

  inherited;
end;

procedure TThCommandManager.SetSubject(ASubject: IThSubject);
begin
  FSubject := ASubject;

  ASubject.RegistObserver(Self);
end;

procedure TThCommandManager.Notifycation(ACommand: IThCommand);
begin
  Debug('TThCommandManager - ' + TThShapeCommand(ACommand).ClassName);

  // ���ο� Ŀ�ǵ尡 ������ Undo �Ұ�(Redo�ʱ�ȭ)
  if ACommand is TThInsertShapeCommand then
    ClearRedo;

  FUndoList.Add(ACommand);

  if FUndoList.Count > FLimit then
    ResizeUndoList(FLimit);
end;

procedure TThCommandManager.ClearRedo;
var
  I: Integer;
begin
  for I := 0 to FRedoList.Count - 1 do
    if FRedoList[I] is TThInsertShapeCommand then
      FSubject.Subject(Self, TThRemoveShapeCommand.Create(TThShapeCommand(FRedoList[I]).List));
      // ���� ����Ʈ�� ����� �ִ� ��ü���� ��ī��??
        // 1, Ŀ�ǵ带 ���� �����Ѵ�.
        // 2, ó���Ҷ����� Ȯ���ϰ� ó���Ѵ�.
  FRedoList.Clear;
end;

procedure TThCommandManager.ResizeUndoList(ASize: Integer);
var
  I: Integer;
begin
  for I := FUndoList.Count - 1 - ASize downto 0 do
  begin
    // Delete�� ��ü�� �����ϱ� ���� RemoveShape Ŀ�ǵ� ����
    if FUndoList[I] is TThDeleteShapeCommand then
      FSubject.Subject(Self, TThRemoveShapeCommand.Create(TThShapeCommand(FUndoList[I]).List));
  end;
end;

procedure TThCommandManager.DoChange;
begin

end;

function TThCommandManager.ExchangeCommand(ACommand: IThCommand): IThCommand;
begin
  if ACommand is TThInsertShapeCommand then
    Result := TThDeleteShapeCommand.Create(TThShapeCommand(ACommand).List)
  else if ACommand is TThDeleteShapeCommand then
    Result := TThRestoreShapeCommand.Create(TThShapeCommand(ACommand).List)
  else if ACommand is TThMoveShapeCommand then
    Result := TThMoveShapeCommand.Create(TThShapeCommand(ACommand).List, TThMoveShapeCommand(ACommand).ToPos, TThMoveShapeCommand(ACommand).FromPos)
  ;
end;

function TThCommandManager.HasRedo: Boolean;
begin
  Result := FRedoList.Count > 0;
  if Result then
    Debug('TThCommandList.HasRedo');
end;

function TThCommandManager.HasUndo: Boolean;
begin
  Result := FUndoList.Count > 0;
end;

procedure TThCommandManager.Undo;
var
  Command: IThCommand;
begin
  if FUndoList.Count <= 0 then
    Exit;

  Command := IThCommand(FUndoList.Last);
//  Command2 := ExchangeCommand(Command);

  FUndoList.Delete(FUndoList.Count - 1);
  FRedoList.Add(Command);

  FSubject.Subject(Self, ExchangeCommand(Command));

//  Debug('TCommandList - Un: %d, Re: %d', [FUndoList.Count, FRedoList.Count]);
end;

procedure TThCommandManager.Redo;
var
  Command: IThCommand;
begin
  if FRedoList.Count <= 0 then
    Exit;

  Command := IThCommand(FRedoList.Last);
//  TThCommand(Command).Source := Self;

  FRedoList.Delete(FRedoList.Count - 1);
  FUndoList.Add(Command);

  FSubject.Subject(Self, Command);

  if FUndoList.Count > FLimit then
    ResizeUndoList(FLimit);
end;

end.

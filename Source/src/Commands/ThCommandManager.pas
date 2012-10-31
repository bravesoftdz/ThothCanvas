unit ThCommandManager;

interface

uses
  ThTypes, ThClasses, System.Generics.Collections;

type
  TThCommandManager = class(TThInterfacedObject, IThObserver)
  type
    TThCommandStack = TStack<IThCommand>;
  private
    FSubject: IThSubject;

    FUndoStack: TThCommandStack;
    FRedoStack: TThCommandStack;
    function GetRedoCount: Integer;
    function GetUndoCount: Integer;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Notifycation(ACommand: IThCommand);
    procedure SetSubject(ASubject: IThSubject);

    procedure UndoAction;
    procedure RedoAction;

    property UndoCount: Integer read GetUndoCount;
    property RedoCount: Integer read GetRedoCount;
  end;

implementation

uses
  ThItemCommand;

{ TThCommandHistory }

constructor TThCommandManager.Create;
begin
  FUndoStack := TThCommandStack.Create;
  FRedoStack := TThCommandStack.Create;
end;

destructor TThCommandManager.Destroy;
begin
  FUndoStack.Clear;
  FRedoStack.Clear;
  FUndoStack.Free;
  FRedoStack.Free;

  inherited;
end;

function TThCommandManager.GetRedoCount: Integer;
begin
  Result := FRedoStack.Count;
end;

function TThCommandManager.GetUndoCount: Integer;
begin
  Result := FUndoStack.Count;
end;

procedure TThCommandManager.SetSubject(ASubject: IThSubject);
begin
  FSubject := ASubject;
  FSubject.RegistObserver(Self);
end;

procedure TThCommandManager.Notifycation(ACommand: IThCommand);
var
  I, J: Integer;
  Command: IThCommand;
begin
  FUndoStack.Push(ACommand);

  // Undo�� TThCommandItemAdd Ŀ�ǵ��� Items�� �ű� Ŀ�ǵ� ��û �� ����(Free)
  for I := 0 to FRedoStack.Count - 1 do
  begin
    Command := FRedoStack.Pop;
    if Command is TThCommandItemAdd then
      for J := 0 to TThCommandItemAdd(Command).Items.Count - 1 do
        TThCommandItemAdd(Command).Items[J].Free;
  end;

  // Undo��(FRedoStack�� ��ġ��) Ŀ�ǵ���� ���ο� Ŀ�ǵ� ��û �� Clear
  FRedoStack.Clear;
end;

procedure TThCommandManager.UndoAction;
var
  Command: IThCommand;
begin
  if FUndoStack.Count = 0 then
    Exit;

  Command := FUndoStack.Pop;
  if not Assigned(Command) then
    Exit;

  Command.Rollback;
  FRedoStack.Push(Command);
end;

procedure TThCommandManager.RedoAction;
var
  Command: IThCommand;
begin
  if FRedoStack.Count = 0 then
    Exit;

  Command := FRedoStack.Pop;
  if not Assigned(Command) then
    Exit;

  Command.Execute;
  FUndoStack.Push(Command);
end;

end.

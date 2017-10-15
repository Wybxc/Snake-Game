unit Main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, StdCtrls,
  Snake.Types, Snake.Play, ExtCtrls;

type
  TMainForm = class(TForm)
    tmrStep: TTimer;
    tmrFPS: TTimer;
    procedure FormPaint(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure tmrStepTimer(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure tmrFPSTimer(Sender: TObject);
    procedure GameError(const MSG: string);
    procedure GameOver;
    procedure DoFps(var MSG: TMsg; var Handled: Boolean);
  private
    { Private declarations }
  public
    { Public declarations }
    Game: TGame;
    Gaming: Boolean;
    ScreenBuffer: TScreenBuffer;
    MemBuffer: TBitmap; // Doublebuffered
    RealFacing: TSnakeFacing;
    FPS: Integer;
    DisplayFPS: Integer;
    procedure Draw;
    procedure Clear;
    procedure StartGame;
    procedure FinishGame;
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

procedure TMainForm.Clear;
var
  i, j: Integer;
begin
  for i := 0 to sWidth - 1 do
    for j := 0 to sHeight - 1 do
      ScreenBuffer[i, j] := bcBlack;
end;

procedure TMainForm.DoFps(var Msg: TMsg; var Handled: Boolean);
begin
  Inc(FPS);
end;

procedure TMainForm.Draw;
var
  i, j: Integer;
begin
  with MemBuffer do
    for i := 0 to sWidth - 1 do
      for j := 0 to sHeight - 1 do
      begin
        if ScreenBuffer[i, j] = bcBlack then
          Canvas.Pen.Color := $111111 // ħ�Ե���ɫ
        else
          Canvas.Pen.Color := Colors[ScreenBuffer[i, j]];
        // �Ӹ������ȷ������
        Canvas.Brush.Color := Colors[ScreenBuffer[i, j]];
        Canvas.Rectangle(i * PixelPerBit, j * PixelPerBit, (i + 1) * PixelPerBit, (j + 1) *
          PixelPerBit); // ��Ҫ����˵ʲô�Ż�
      end;
  Canvas.CopyRect(Rect(0, 0, ClientWidth, ClientHeight), MemBuffer.Canvas, Rect(0, 0, ClientWidth, ClientHeight));
  Canvas.TextOut(8, 8, 'FPS:' + IntToStr(DisplayFPS));
end;

procedure TMainForm.FinishGame;
begin
  Gaming := False;
  Game.Free;
  tmrStep.Enabled := False;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  ClientWidth := sWidth * PixelPerBit;
  ClientHeight := sHeight * PixelPerBit;
  // ��ʼ�� FPS ��������
  FPS := 0;
  DisplayFPS := 0;
  Application.OnMessage := DoFps;
  // ��ʼ����Ļ����
  MemBuffer := TBitmap.Create;
  MemBuffer.SetSize(ClientWidth, ClientHeight);
  Brush.Style := bsClear;
  Clear;
  Draw;
  // ��Ϸ��ʼ
  StartGame;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  MemBuffer.Free;
  if Gaming then
    FinishGame;
end;

procedure TMainForm.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  case Key of
    VK_UP, Word('W'):
      if RealFacing <> sfDown then // ��һ����Ϊ�˷�ֹ�����뵱ǰ�����෴�İ���
        Game.Facing := sfUp;       // ���� Game.Facing �Ƚ�����Ϊ��ֹ���ٿ����
    VK_DOWN, Word('S'):                       //   ��������������ͬ����Խ���������
      if RealFacing <> sfUp then   // ���� RealFacing �� tmrStepTimer �и�ֵ
        Game.Facing := sfDown;
    VK_LEFT, Word('A'):
      if RealFacing <> sfRight then
        Game.Facing := sfLeft;
    VK_RIGHT, Word('D'):
      if RealFacing <> sfLeft then
        Game.Facing := sfRight;
    13: // Enter
      if not Gaming then
        StartGame;
  end;
end;

procedure TMainForm.FormPaint(Sender: TObject);
begin
  Draw;
end;

procedure TMainForm.GameError(const Msg: string);
begin
  raise Exception.Create(Msg);
end;

procedure TMainForm.GameOver;
begin
  FinishGame;
  ShowMessage('Game Over!');
  Clear;
  Draw;
end;

procedure TMainForm.StartGame;
begin
  Game := TGame.Create(sWidth, sHeight);
  Game.OnGameOver := GameOver;
  Game.OnError := GameError;
  RealFacing := Game.Facing;
  Gaming := True;
  tmrStep.Enabled := True;
end;

procedure TMainForm.tmrFPSTimer(Sender: TObject);
begin
  DisplayFPS := FPS;
  FPS := 0;
end;

procedure TMainForm.tmrStepTimer(Sender: TObject);
begin
  Game.Step;
  RealFacing := Game.Facing;
  Game.Display(ScreenBuffer);
  Draw;
end;

end.


unit Main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, StdCtrls,
  Snake.Types, Snake.Play, ExtCtrls;

type
  TMainForm = class(TForm)
    lblLoading: TLabel;
    tmrStep: TTimer;
    procedure FormPaint(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure tmrStepTimer(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    { Private declarations }
  public
    { Public declarations }
    Game: TGame;
    Gaming: Boolean;
    ScreenBuffer: TScreenBuffer;
    RealFacing: TSnakeFacing;
    procedure Draw;
    procedure Clear;
    procedure StartGame;
    procedure FinishGame;
    procedure GameError(const MSG: string);
    procedure GameOver;
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

procedure TMainForm.Draw;
var
  i, j: Integer;
begin
  for i := 0 to sWidth - 1 do
    for j := 0 to sHeight - 1 do
    begin
      Canvas.Pen.Color := Colors[ScreenBuffer[i, j]];
      Canvas.Brush.Color := Colors[ScreenBuffer[i, j]];
      Canvas.Rectangle(i * PixelPerBit, j * PixelPerBit, (i + 1) * PixelPerBit, (j + 1) *
        PixelPerBit); // ��Ҫ����˵ʲô�Ż�
    end;
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
  // ��ʼ����Ļ����
  Clear;
  Draw;
  // ��Ϸ��ʼ
  StartGame;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  if Gaming then
    FinishGame;
end;

procedure TMainForm.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  case Key of
    VK_UP:
      if RealFacing <> sfDown then // ��һ����Ϊ�˷�ֹ�����뵱ǰ�����෴�İ���
        Game.Facing := sfUp;       // ���� Game.Facing �Ƚ�����Ϊ��ֹ���ٿ����
    VK_DOWN:                       //   ��������������ͬ����Խ���������
      if RealFacing <> sfUp then   // ���� RealFacing �� tmrStepTimer �и�ֵ
        Game.Facing := sfDown;
    VK_LEFT:
      if RealFacing <> sfRight then
        Game.Facing := sfLeft;
    VK_RIGHT:
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
  lblLoading.Visible := True;
  (************)
  Game := TGame.Create(sWidth, sHeight);
  Game.OnGameOver := GameOver;
  Game.OnError := GameError;
  RealFacing := Game.Facing;
  Gaming := True;
  tmrStep.Enabled := True;
  (************)
  lblLoading.Visible := False;
end;

procedure TMainForm.tmrStepTimer(Sender: TObject);
begin
  Game.Step;
  RealFacing := Game.Facing;
  Game.Display(ScreenBuffer);
  Draw;
end;

end.


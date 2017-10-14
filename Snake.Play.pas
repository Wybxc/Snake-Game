unit Snake.Play;

interface

uses
  Types, Generics.Collections, Snake.Types;

type
  TGame = class;

  TPixelState = (psEmpty, psHead, psBody, psFood);

  TSnakeFacing = (sfUp, sfDown, sfLeft, sfRight);

  TOnMessage = procedure(const Msg: string) of object;

  TOnGameOver = procedure of object;

  TGame = class
  private
    FWidth, FHeight: Integer;
    Map: array of array of TPixelState;
    Head: TPoint;
//  Next: TPoint; // Next 是函数
    Body: TQueue<TPoint>;
    FOnError: TOnMessage;
    FOnGameOver: TOnGameOver;
    procedure SetOnError(const Value: TOnMessage);
    procedure SetOnGameOver(const Value: TOnGameOver);
    procedure NewFood;
    function Next: TPoint; inline;
  public
    Facing: TSnakeFacing;
    constructor Create(const AWidth, AHeight: Integer);
    destructor Destroy; override;
    procedure Step;
    procedure Display(var Screen: TScreenBuffer);
    property OnGameOver: TOnGameOver read FOnGameOver write SetOnGameOver;
    property OnError: TOnMessage read FOnError write SetOnError; // 回调大法好
  end;

{
  Map 方向:
      |
   ---O------------->
      |          Width(x)
      |
      |
      |
      |
      v  Height(y)

  蛇的生成示意图:
    +-----------------------------+
    |                             |
    |                             |
    |    +-------------------+    | <-- 整个场景
    |    |                   |    |
    |    |                   |    |
    |    |                   |    |
    |    |     -->           | <------- 蛇可以生成的地方
    |    |                   |    |
    |    |                   |    |
    |    |                   |    |
    |    +--------+----------+    |
    |             |               |
    |             +-------------------> 一半的宽和高
    +-----------------------------+
}

implementation

{ TGame }

constructor TGame.Create(const AWidth, AHeight: Integer);
var
  i, j: Integer;
begin
  // 初始化地图
  FWidth := AWidth;
  FHeight := AHeight;
  SetLength(Map, FWidth, FHeight);
  for i := 0 to High(Map) do
    for j := 0 to High(Map[0]) do
      Map[i, j] := psEmpty;
  // 设置蛇的初始位置
  Randomize;
  i := Random(FWidth div 2) + FWidth div 4;
  j := Random(FHeight div 2) + FHeight div 4;
  Facing := TSnakeFacing(Random(4));
  Head := Point(i, j);
  Body := TQueue<TPoint>.Create;
  Map[Head.X, Head.Y] := psBody;
  Body.Enqueue(Head);
  Head := Next;
  Map[Head.X, Head.Y] := psBody;
  Body.Enqueue(Head);
  Head := Next;
  Map[Head.X, Head.Y] := psHead;
  // 这里的 Head := Next 可以看做蛇向前走了三步
  // 生成食物
  NewFood;
end;

destructor TGame.Destroy;
begin
  Body.Free;
end;

procedure TGame.Display(var Screen: TScreenBuffer);
var
  i, j: Integer;
begin
  for i := 0 to High(Map) do
    for j := 0 to High(Map[0]) do
      case Map[i, j] of
        psEmpty:
          Screen[i, j] := bcBlack;
        psFood:
          Screen[i, j] := bcYellow;
        psBody:
          Screen[i, j] := bcWhite;
        psHead:
          Screen[i, j] := bcRed;
      end;
end;

procedure TGame.NewFood;
var
  i, j: Integer;
begin
  repeat
    i := Random(FWidth);
    j := Random(FHeight);
  until Map[i, j] = psEmpty;
  Map[i, j] := psFood;
end;

function TGame.Next: TPoint;
begin
  case Facing of
    sfUp:
      Result := Point(Head.X, Head.Y - 1);
    sfDown:
      Result := Point(Head.X, Head.Y + 1);
    sfLeft:
      Result := Point(Head.X - 1, Head.Y);
    sfRight:
      Result := Point(Head.X + 1, Head.Y);
  end;
  if Result.X >= FWidth then
    Dec(Result.X, FWidth);
  if Result.X < 0 then
    Inc(Result.X, FWidth);
  if Result.Y >= FHeight then
    Dec(Result.Y, FHeight);
  if Result.Y < 0 then
    Inc(Result.Y, FWidth);
end;

procedure TGame.SetOnError(const Value: TOnMessage);
begin
  FOnError := Value;
end;

procedure TGame.SetOnGameOver(const Value: TOnGameOver);
begin
  FOnGameOver := Value;
end;

procedure TGame.Step;
var
  Next: TPoint;
  Tail: TPoint;
begin
  Next := Self.Next; // 局部覆盖类方法 Next
  case Map[Next.X, Next.Y] of
    psEmpty:
      begin
        // 头前进一步, 尾前进一步
        Map[Head.X, Head.Y] := psBody;
        Body.Enqueue(Head);
        Head := Next;
        Map[Head.X, Head.Y] := psHead;
        Tail := Body.Dequeue;
        Map[Tail.X, Tail.Y] := psEmpty;
      end;
    psFood:
      begin
        // 头前进一步, 尾不变
        Map[Head.X, Head.Y] := psBody;
        Body.Enqueue(Head);
        Head := Next;
        Map[Head.X, Head.Y] := psHead;
        // 生成下一个 Food
        NewFood;
      end;
    psBody:
      begin
        // Boom!
        OnGameOver;
      end;
    psHead:
      begin
        OnError('数据错误:重复的Head'); // 报错信息一定要高大上地装逼
      end;
  end;
end;

end.


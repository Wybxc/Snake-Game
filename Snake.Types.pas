unit Snake.Types;

interface

uses
  Graphics;

const
  sWidth = 35;
  sHeight = 35;
  PixelPerBit = 17;

type
  TBinaryColor = (bcBlack, bcMaroon, bcGreen, bcOlive, bcNavy, bcPurple, bcTeal, bcGray, bcSilver,
    bcRed, bcLime, bcYellow, bcBlue, bcFuchsia, bcAqua, bcLtGray, bcDkGray, bcWhite);

  TScreenBuffer = array[0..sWidth - 1, 0..sHeight - 1] of TBinaryColor;

const
  Colors: array[TBinaryColor] of TColor = (clBlack, clMaroon, clGreen, clOlive, clNavy, clPurple,
    clTeal, clGray, clSilver, clRed, clLime, clYellow, clBlue, clFuchsia, clAqua, clLtGray, clDkGray, clWhite);

implementation

end.


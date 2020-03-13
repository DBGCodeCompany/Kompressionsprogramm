{------------------------------------------------------------------------------}
{PROGRAMM DER DBG-CODE-COMPANY                                       13.03.2020}
{Kopression von Daten durch:                                                   }
{Burrows-Wheeler-Transformation;                                               }
{One-length-encoding;                                                          }
{Huffman-Coding;                                                               }
{------------------------------------------------------------------------------}

unit kompressorunit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Buttons;

type

  { TKompressorForm }

  TKompressorForm = class(TForm)
    KomprimierenButton: TButton;
    DekomprimierenButton: TButton;
    BWTCheckBox: TCheckBox;
    OpenPathEdit: TEdit;
    SavePathEdit: TEdit;
    OLCheckBox: TCheckBox;
    HaffCheckBox: TCheckBox;
    Memo: TMemo;
    OpenSpeedButton: TSpeedButton;
    SaveSpeedButton: TSpeedButton;
    TopLabel: TLabel;
  private

  public

  end;

var
  KompressorForm: TKompressorForm;

implementation

{$R *.lfm}

{ TKompressorForm }


end.


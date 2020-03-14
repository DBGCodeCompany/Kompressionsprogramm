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
  Tarrayofreal= array of real;
  Tarrayofbyte= array of byte;
  Tarrayofstring= array of string;

  { TKompressorForm }

  TKompressorForm = class(TForm)
    KomprimierenButton: TButton;
    DekomprimierenButton: TButton;
    BWTCheckBox: TCheckBox;
    OpenDialog: TOpenDialog;
    OpenPathEdit: TEdit;
    SaveDialog: TSaveDialog;
    SavePathEdit: TEdit;
    OLCheckBox: TCheckBox;
    HaffCheckBox: TCheckBox;
    Memo: TMemo;
    OpenSpeedButton: TSpeedButton;
    SaveSpeedButton: TSpeedButton;
    TopLabel: TLabel;
    procedure KomprimierenButtonClick(Sender: TObject);
    procedure OpenSpeedButtonClick(Sender: TObject);
    procedure SaveSpeedButtonClick(Sender: TObject);
    //procedure einlesen(data:string);
  private

  public

  end;

var
  KompressorForm: TKompressorForm;

implementation

function SArrayToString(a:Tarrayofstring):String;
var
 i:Integer;
 begin
    result:='';
   For i:=0 to (length(a)-1) do result:=result+a[i]+'; ';
  end;

function StringBitToAofByte(s:string):Tarrayofbyte;
var
 i:int64;
  begin
    //mach was damit da nicht immer ein string den platz für eine bitkette einnehmen muss!
  end;

function aofrealtostr(a:Tarrayofreal):string;   //schreibt ein array of real in einen String um
var
  i:int64;
  begin
    result:='';
    for i:=0 to (length(a)-1) do begin
      result:=result+ floattostr(a[i])+' ';
      end;
    end;

function instring(s:string; a:char):boolean;     //prüfen ob ein Buchstabe in einem String ist
var
  i:int64;
  begin
    result:=false;
    for i:=1 to length(s) do begin
      if s[i]=a then begin
        result:=true;
        break;
      end;
    end;
  end;

function getalpha(s:string):string;       //generiert das Alphabet, das s nutzt
var
  i:int64;
  alpha:string;
  begin
    alpha:='';
    for i:=1 to length(s) do begin
      if not instring(alpha,s[i]) then alpha:=alpha+s[i];                       //Buchstaben in alpha aufnehmen, wenn noch nicht vorhanden
    end;
    result:=alpha;
  end;

function getwahrsch(s,alpha:string):Tarrayofreal;
var
  i,n,lenge:int64;
  wahrsch: array of real;
  begin
    lenge:=length(s);
    setlength(wahrsch,length(alpha));
    for i:=1 to length(alpha) do begin
      for n:=1 to lenge do begin
        if alpha[i]=s[n] then wahrsch[i-1]:= wahrsch[i-1]+(1/lenge); //für jeden gefunden Buchstaben aus alpha in s
      end;                                                           //an dessen Stelle in wahrsch die Wahrscheinlichkeit
    end;                                                             //aufsummieren
    result:=copy(wahrsch);
  end;

{------------------------HUFFMAN-CODING----------------------------------------}
function huffman(s,alpha:string;wahrsch:Tarrayofreal):Tarrayofstring;
var
  i,n,index:int64;
  hilf:real;
  nullen:string;
  codealpha:array of string;
  begin
    nullen:='';
    setlength(codealpha,length(alpha)+1);
    for i:=0 to length(alpha)-1 do codealpha[i]:='f';

    for n:=1 to length(alpha) do begin
    hilf:=0;
    for i:=0 to high(wahrsch) do begin
      if hilf<wahrsch[i] then begin
        if i>0 then begin
         wahrsch[i-1]:=hilf;
         hilf:=wahrsch[i];           //findet den größten Wert und lässt ihn in hilf, löscht ihn in wahrsch (zu 0)
         index:=i;                   //um den nächstgrößten nach dieser Methode finden zu können
         wahrsch[i]:=0;
         end                         //index ist dann der index an der Stelle an dem der Buchstabe in alpha steht
        else begin                    //der am wahrscheinlichsten ist... nach den in vorherigen durchläufen gelöschten
         hilf:=wahrsch[i];
         wahrsch[i]:=0;
         index:=i;
        end;
      end;
      end;

    codealpha[index]:=nullen+'1';
    nullen:=nullen+'0';
    end;
    result:=copy(codealpha);
  end;

{$R *.lfm}

{ TKompressorForm }

procedure TKompressorForm.KomprimierenButtonClick(Sender: TObject);
var
  Data,alpha:string;
  wahrsch:array of real;
  summe:real;
  i:int64;
begin
  data:='';

  for i:=0 to (Memo.Lines.count-1) do data:=data+ Memo.lines[i];       //Text aus Memo einlesen

  alpha:=getalpha(Data);
  showmessage('alphaLÄ: '+inttostr(length(alpha))+' DataLÄ: '+inttostr(length(Data)));
  wahrsch:=copy(getwahrsch(Data,alpha));
  Memo.lines.add('Alphabet: '+alpha);
  Memo.lines.add('Wahrscheinlichkeit: '+aofrealtostr(wahrsch));

  {----------------Zur Kontrolle! Summe muss 1 ergeben-------------------------}
  summe:=0;
  for i:=0 to (length(wahrsch)-1) do begin
    summe:=summe+wahrsch[i];
    end;
  Memo.lines.add('Summe der Wahrscheinlichkeiten: '+floattostr(summe));
  {----------------------------------------------------------------------------}

  Memo.Lines.add('Codealpha: '+Sarraytostring(huffman(data,alpha,wahrsch)));

end;

procedure TKompressorForm.OpenSpeedButtonClick(Sender: TObject);
begin
    If OpenDialog.execute then OpenPathEdit.text:= OpenDialog.Filename;
end;

procedure TKompressorForm.SaveSpeedButtonClick(Sender: TObject);
begin
    If SaveDialog.execute then SavePathEdit.text:= SaveDialog.Filename;
end;

{procedure TKompressorform.einlesen(data:string);
var
  i:int64;
  begin
    for i:=0 to Memo.Lines.count do data:=data+ Memo.lines[i];
  end;      }

{ TKompressorForm }


end.


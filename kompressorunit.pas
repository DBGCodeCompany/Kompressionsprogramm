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
  Tarrayofbool= array of boolean;

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
  codealpha: array of string;

implementation

function SArrayToString(a:Tarrayofstring):String;
var
 i:Integer;
 begin
    result:='';
   For i:=0 to (length(a)-1) do result:=result+a[i]+'; ';
  end;

function StringBitToTBits(s:Tarrayofstring):Tarrayofbool;
var
 i,n:int64;
 bits:Tarrayofbool;
 str:string;
  begin
    setlength(bits,1);
    for i:=0 to high(s) do begin
    str:=s[i];
     for n:=1 to length(str) do begin
       if str[n]='1' then bits[i+n-1]:=true else bits[i+n-1]:=false;
       setlength(bits,length(bits)+1);
     end;
    end;
    result:=copy(bits);
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
  kompdata:array of string;
  begin
    {-------Codealphabet finden--mit Alphabet und Wahrscheinlichkeiten---------}
    nullen:='';
    setlength(codealpha,length(alpha));
    for i:=0 to length(alpha)-1 do codealpha[i]:='f';                           //codealphabet mit f's initialisieren

    for n:=1 to length(alpha) do begin
    hilf:=0;
    for i:=0 to high(wahrsch) do begin
    //showmessage('Hilf: '+floattostr(hilf)+' wahrsch: '+floattostr(wahrsch[i])); //for Debug
      if hilf<wahrsch[i] then begin
         hilf:=wahrsch[i];                                                      //findet den größten Wert und lässt ihn in hilf
         index:=i;
      end;
      end;
    //Showmessage('Durchlauf: '+inttostr(n)+' Index: '+inttostr(index));        //for Debug
    wahrsch[index]:=0;                                                          //löscht den größten zu 0 um den nächstgrößten fiden zu können
    codealpha[index]:=nullen+'1';
    nullen:=nullen+'0';
    end;
    {--------------------------------------------------------------------------}

    {--------Zeichen des Datenstrings mit dem neuen Codealphabet eretzen-------}
    setlength(kompdata,length(s));
    for i:=1 to length(s) do begin
      for n:=1 to length(alpha) do begin
        if alpha[n]=s[i] then kompdata[i-1]:=codealpha[n-1];
      end;
    end;
    {--------------------------------------------------------------------------}
    result:=copy(kompdata);
  end;
{------------------------------------------------------------------------------}
{-------------------huffmankompriemierung entpacken----------------------------}
function dehuff(bits:Tarrayofbool;codealpha:Tarrayofstring;alpha:string):string;
var
  i,index:int64;
  data,strbits:string;
  begin
    data:='';
    strbits:='';
    for index:=0 to high(bits) do begin
     if bits[index]=true then begin
        strbits:=strbits+'1';
        for i:=0 to high(codealpha) do begin
          if strbits=codealpha[i] then data:=data+alpha[i+1];
        end;
        strbits:='';
     end
     else strbits:=strbits+'0';
    end;
    result:=data;
  end;
{------------------------------------------------------------------------------}

{$R *.lfm}

{ TKompressorForm }

procedure TKompressorForm.KomprimierenButtonClick(Sender: TObject);
var
  Data,alpha:string;
  kompdata:array of string;
  bitdata:Tarrayofbool;
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

  kompdata:=huffman(data,alpha,wahrsch);
  Memo.Lines.add('Codealpha: '+Sarraytostring(codealpha));
  Memo.Lines.add('Komprimiert: '+Sarraytostring(kompdata));
  bitdata:=StringBitToTBits(kompdata);
  Memo.lines.add('Entpackt: '+dehuff(bitdata,codealpha,alpha));
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


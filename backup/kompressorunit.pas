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
  TArrayofInt= Array of integer;

  { TKompressorForm }

  TKompressorForm = class(TForm)
    GeneratorButton: TButton;
    AnzahlLabel: TLabel;
    SizeEdit: TEdit;
    KomprimierenButton: TButton;
    DekomprimierenButton: TButton;
    BWTCheckBox: TCheckBox;
    OpenDialog: TOpenDialog;
    OpenPathEdit: TEdit;
    SaveDialog: TSaveDialog;
    SavePathEdit: TEdit;
    RLCheckBox: TCheckBox;
    HaffCheckBox: TCheckBox;
    Memo: TMemo;
    OpenSpeedButton: TSpeedButton;
    SaveSpeedButton: TSpeedButton;
    TopLabel: TLabel;
    procedure GeneratorButtonClick(Sender: TObject);
    procedure DekomprimierenButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure KomprimierenButtonClick(Sender: TObject);
    procedure OpenSpeedButtonClick(Sender: TObject);
    procedure SaveSpeedButtonClick(Sender: TObject);
    procedure save(data:Tarrayofbyte;Path:String);
  private

  public

  end;

var
  KompressorForm: TKompressorForm;
  codealpha: array of string;
  bits:TBits;

implementation

function bittobyte(bits:Tarrayofbyte):Tarrayofbyte;
var
  i,n,lenge:integer;
  abyte:byte;
begin
  lenge:=(length(bits)div 8)+1;
  setlength(result,lenge);
  for n:=0 to lenge do begin
    abyte:=0;
    if (length(bits)-(n*8))>7 then begin
    for i:=0 to 7 do begin
      if bits[i+(n*8)]=1 then abyte:=abyte+potenz(2,7-i);
    end;
    end
    else begin
      for i:=0 to (length(bits)-(n*8))-1 do begin
        if bits[i+(n*8)]=1 then abyte:=abyte+potenz(2,(length(bits)-(n*8))-1-i);
      end;
    end;
    result[n]:=abyte;
  end;
end;

function potenz(basis,exponent:integer):integer;
var
i:integer;
begin
  for i:=2 to exponent do basis:=basis*basis;
  result:=basis;
end;
                                                            //Schreibt ein Tarrayofstring in einen string um (AUSGABE)
function SArrayToString(a:Tarrayofstring;kommata:boolean):String;
var
 i:Integer;
 begin
    result:='';
   if kommata=true then begin
   For i:=0 to (length(a)-1) do result:=result+a[i]+';';
   end
   else begin
   For i:=0 to (length(a)-1) do result:=result+a[i];
   end;
  end;

function bitstostr(bitdata:Tarrayofbool):string;          //Schreibt ein Tarrayofbool in einen String um (AUSGABE)
var
  i:integer;
  s:string;
  begin
    s:='';
    for i:=0 to high(bitdata) do begin
      if bitdata[i]=true then s:=s+'1' else s:=s+'0';
    end;
    result:=s;
  end;

function StringBitToTarrayofbool(s:string):Tarrayofbool;   //Schreibt einen string mit einsen und nullen in
var                                                                //Tarrayofbool um (SPEICHERPLATZ!!)
// i:int64;
 i:integer;
 bits:Tarrayofbool;
  begin
   setlength(bits,0);
    for i:=1 to length(s) do begin
      setlength(bits,length(bits)+1);
      if s[i]='1' then bits[i-1]:=true else bits[i-1]:=false;
    end;
  result:=copy(bits);
  end;

function aofrealtostr(a:Tarrayofreal):string;   //schreibt ein array of real in einen String um
var
  //i:int64;
 i:integer;
  begin
    result:='';
    for i:=0 to (length(a)-1) do begin
      result:=result+ floattostr(a[i])+' ';
      end;
    end;

function instring(s:string; a:char):boolean;     //prüfen ob ein Buchstabe in einem String ist
var
 // i:int64;
 i:integer;
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
 // i:int64;
 i:integer;
  alpha:string;
  begin
    alpha:='';
    for i:=1 to length(s) do begin
      if not instring(alpha,s[i]) then alpha:=alpha+s[i];    //Buchstaben in alpha aufnehmen, wenn noch nicht vorhanden
    end;
    result:=alpha;
  end;

function getwahrsch(s,alpha:string):Tarrayofreal;
var
lenge:int64;  // i, n,
 i,n:integer;
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

function saveTarrayofbool(data:Tarrayofbool;Path:string):boolean;
var
  filestream:TFilestream;
  begin
  filestream:=TFilestream.create(Path,fmCreate);
  try
  Filestream.WriteBuffer(data,SizeOf(data));
  result:=true;
  except
    Showmessage('Fehler beim schreiben der Datei nach:'+Path);
    result:=false;
  end;
  filestream.free;
  end;

function loadTarrayofbool(Path:string):Tarrayofbool;
var
  filestream:TFileStream;
  data:Tarrayofbool;
  begin
  filestream:=TFilestream.create(Path,fmOpenRead);
  try
  setlength(data,filestream.size);
  filestream.ReadBuffer(data,filestream.size);
  result:=copy(data);
  except
    Showmessage('Fehler beim lesen der Datei bei: '+Path);
  end;
  filestream.free;
  end;

function StringInDatei(a,Path:string):boolean;
var
  List:TStringList;
begin
  try
  List:=TStringList.create;
  List.Add(a);
  List.SaveToFile(Path);
  List.free;
  result:=true;
  finally
  end;
end;

function StringausDatei(Path:string):string;
var
  List:TStringList;
  s:string;
  i:integer;
begin
 try
 List:=TStringlist.create;
 List.LoadFromFile(Path);
 s:='';
 for i:=0 to List.count-1 do s:=s+List[i];
 result:=s;
 except
   Showmessage('Fehler beim Laden mit "StringausDate()"');
 end;
end;

function SarrayInDatei(data:Tarrayofstring;Path:string):boolean;
var
  filestream:TFilestream;
  begin
  filestream:=TFilestream.create(Path,fmCreate);
  try
  Filestream.WriteBuffer(data,SizeOf(data));
  result:=true;
  except
    Showmessage('Fehler beim schreiben der Datei nach:'+Path);
    result:=false;
  end;
  filestream.free;
  end;

function SarrayAusDatei(Path:string):Tarrayofstring;
var
  filestream:TFileStream;
  data:Tarrayofstring;
  begin
  filestream:=TFilestream.create(Path,fmOpenRead);
  try
  setlength(data,filestream.size);
  filestream.ReadBuffer(data,filestream.size);
  result:=copy(data);
  except
    Showmessage('Fehler beim lesen der Datei bei: '+Path);
  end;
  filestream.free;
  end;

function load(Path:string):Tarrayofbyte;
var
  ms:TMemorystream;
  begin
  ms:=TMemoryStream.create;
  try
  ms.loadfromfile(Path);
  ms.position:=0;
  setlength(result,ms.size);
  ms.read(result[0],ms.size);
  except
    writeln('Fehler beim Lesen der Datei aus: '+Path);
  end;
  ms.free;
  end;

{------------------------HUFFMAN-CODING----------------------------------------}
function huffman(s,alpha:string;wahrsch:Tarrayofreal):Tarrayofstring;
var
 index:int64;  // i,n,
 i,n:integer;
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
  //i,index:int64;
  i,index:integer;
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
{----------------------Run-Length-Encoding-------------------------------------}
function rleencode(Werte:TArrayofbyte):TArrayofInt;
var i,z:integer;
  WerteKomprimiert: Array of integer;
  wert1:byte;
  wert2:byte;
begin

   z:=0;

  setLength(WerteKomprimiert,1);
  WerteKomprimiert[0]:=1;

  //angelehnt an https://rosettacode.org/wiki/Run-length_encoding#Pascal
     for i:=0 to (Length(werte)-2) do begin
         wert1:=(werte[i]);       //werte miteinander vergleichen,ob wechsel (01) vorliegt
         wert2:=(werte[i+1]);
        if wert1=wert2 then
          inc(WerteKomprimiert[z],1)
        else begin
          inc(z,1);
          setLength(WerteKomprimiert,Length(WerteKomprimiert)+1);
          WerteKomprimiert[z] := 1;
        end;
        end;
   result:=copy(WerteKomprimiert);
end;
{------------------------------------------------------------------------------}
{$R *.lfm}

{ TKompressorForm }

procedure TKompressorform.save(data:Tarrayofbyte;Path:String);
var
  fs:TFilestream;
  ms:TMemoryStream;
  begin
    ms:TMemoryStream.create;
    fs:TFilestream.create(Path,fmCreate);
    try
       ms.writeBuffer(data,SizeOf(data));
       ms.Position:=0;
       fs.CopyFrom(ms, ms.Size);
    except
     Showmessage('Fehler beim Speichern nach: '+Path);
  end;
  fs.free;
  ms.free;
  end;

procedure TKompressorForm.KomprimierenButtonClick(Sender: TObject);
var
  Data,alpha:string;
  kompdata:array of string;
  rbitdata,bitdata:Tarrayofbool;
  wahrsch:array of real;
  summe:real;
  Komprimiert: array of integer;
  origdata: array of byte;
 // i:int64;
 i,y:integer;
 startwert:byte;
begin

if RLCheckBox.Checked=true then begin

    startwert:=strtoint(Memo.lines[0]);   //für späteres zurückrechnen merken

   setLength(origdata,memo.lines.count);    //übernahme der werte aus dem memo
  for i:=0 to (memo.lines.count-1) do begin
    origdata[i]:=strtoint(Memo.lines[i]);
  end;

  Komprimiert:=rleencode(origdata);     //erstellen des kompr. arrays

  Memo.lines.clear;

  for y:=0 to (Length(Komprimiert)-1) do begin     //ausgabe der kompr. werte
    Memo.lines[y]:=inttostr(Komprimiert[y]);
  end;
   end;


if HaffCheckbox.Checked=true then begin
  data:='';

  for i:=0 to (Memo.Lines.count-1) do data:=data+ Memo.lines[i];       //Text aus Memo einlesen

  alpha:=getalpha(Data);
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
  Memo.Lines.add('Codealpha: '+Sarraytostring(codealpha,true));
  Memo.Lines.add('Komprimiert: '+Sarraytostring(kompdata,true));

  bitdata:=StringBitToTarrayofbool(Sarraytostring(kompdata,false));
  saveTarrayofbool(bitdata,SavePathEdit.text);
  Stringindatei(alpha,'Alphabet.txt');
  Sarrayindatei(codealpha,'Codealphabet.txt');
  end;

  rbitdata:=loadTarrayofbool(OpenPathEdit.text);
  Memo.lines.add('Gelesene Daten: '+bitstostr(rbitdata));

end;

procedure TKompressorForm.FormCreate(Sender: TObject);
begin
  bits:=TBits.create;
  Randomize;
end;

procedure TKompressorForm.DekomprimierenButtonClick(Sender: TObject);
var
  rbitdata:Tarrayofbool;
  codealpha:array of string;
  alpha:string;
begin
  rbitdata:=loadTarrayofbool(OpenPathEdit.text);
  Memo.lines.add('Gelesene Daten: '+bitstostr(rbitdata));
  codealpha:=SarrayAusDatei('Codealphabet.txt');
  Memo.lines.add('gelesenes Codealphabet: '+Sarraytostring(codealpha,true));
  alpha:=StringAusDatei('Alphabet.txt');
  Memo.lines.add('gelesenes Alphabet: '+alpha);
  Memo.lines.add('Entpackt: '+dehuff(rbitdata,codealpha,alpha));
end;

procedure TKompressorForm.GeneratorButtonClick(Sender: TObject);
var Werterandom:Array of byte;
  i:integer;
begin
setLength(Werterandom,(strtoint(SizeEdit.text)-1));
  for i:=0 to (strtoint(SizeEdit.text)-1) do begin
    Werterandom[i]:=random(2);
    Memo.lines[i]:=inttostr(Werterandom[i])
  end;
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


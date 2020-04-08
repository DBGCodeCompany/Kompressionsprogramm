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
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Buttons,
  ExtCtrls;

type
  Tarrayofreal= array of real;
  Tarrayofbyte= array of byte;
  Tarrayofstring= array of string;
  Tarrayofbool= array of boolean;
  TArrayofInt= Array of integer;

  { TKompressorForm }

  TKompressorForm = class(TForm)
    AlphaCheckBox: TCheckBox;
    inputLabel: TLabel;
    outputLabel: TLabel;
    KomprimierenButton: TButton;
    DekomprimierenButton: TButton;
    BWTCheckBox: TCheckBox;
    OpenDialog: TOpenDialog;
    OpenPathEdit: TEdit;
    MemoAusgabeRadioButton: TRadioButton;
    keineAusgabeRadioButton: TRadioButton;
    AusgabeRadioGroup: TRadioGroup;
    SaveDialog: TSaveDialog;
    SavePathEdit: TEdit;
    RLCheckBox: TCheckBox;
    HaffCheckBox: TCheckBox;
    Memo: TMemo;
    OpenSpeedButton: TSpeedButton;
    SaveSpeedButton: TSpeedButton;
    TopLabel: TLabel;
    procedure DekomprimierenButtonClick(Sender: TObject);
    procedure KomprimierenButtonClick(Sender: TObject);
    procedure OpenSpeedButtonClick(Sender: TObject);
    procedure SaveSpeedButtonClick(Sender: TObject);
    procedure save(data:String; const Path:String);
    function tausch2(char1,char2:char;str:string;index1,index2:integer;pos,max:integer):boolean;
    function bwt2(indizes:Tarrayofint;origlaenge:integer;orig:string):TArrayofInt;
  private

  public

  end;

var
  KompressorForm: TKompressorForm;
  codealpha: array of string;
  bits:TBits;

implementation

function tausch(str1,str2:string):boolean;                //untersucht ob str1 und str2 getauscht werden sollen
var
  i:integer;
begin
 result:=false;                                    //Damit result auch gesetzt ist, wenn die strings gleich sind
  for i:=1 to length(str1) do begin
    if ord(str1[i])>ord(str2[i]) then begin        //ASCII indizes der Stringzeichen an der stelle i vergleichen
      result:=true;                                //und danach entscheiden
      break;                                       //...wenn sie geleich sind, dann eine position weiter gehen
    end;                                           //im string und wieder vergleichen.
    if ord(str1[i])<ord(str2[i]) then begin
      result:=false;
      break;
    end;
  end;
end;

function permute(str:string;index:integer):string; //Gibt die Permutation von str zurück, die bei str[index] beginnt
var
  i,l:integer;
begin
   l:=length(str);
   setlength(result,l);
   for i:=1 to l do begin
     if (i+index)>l then result[i]:=str[i+index-l]
     else result[i]:=str[index+i];
   end;
end;
function permute2(str:string;index:integer;pos:integer):char;   //gibt die permutation als einzelnen char zurück
var l:integer;
begin
   l:=length(str);
    if (pos+index)>l then result:=str[pos+index-l]
     else result:=str[index+pos];
end;
{alternative zur einfachen tauschfunktion, vorteil, da nicht die gesamte permutation erstellt wird}
{deklaration als tform.funktion und listung unter tform}
{rekursiv: sind die chars gleich, ruft sich die funktion}
{selbst auf, dabei werden die nächsten chars verglichen etc}
function TKompressorForm.tausch2(char1,char2:char;str:string;index1,index2:integer;pos,max:integer):boolean;                //untersucht ob str1 und str2 getauscht werden sollen , übergabewerte sind für rekursion notwendig
begin
 result:=false;                                            //Damit result auch gesetzt ist, wenn die strings gleich sind
     if (ord(char1)=ord(char2)) AND (pos<=max) then begin
       result:=tausch2(permute2(str,index1,pos+1),permute2(str,index2,pos+1),str,index1,index2,pos+1,max);
      end
    else
    if ord(char1)>ord(char2) then begin        //ASCII indizes der chars vergleichen
      result:=true;                                //und danach entscheiden                                      //...wenn sie geleich sind, dann eine position weiter gehen
    end;                                           //im string und wieder vergleichen.
    if ord(char1)<ord(char2) then begin
      result:=false;
    end;
  end;
function potenz(basis,exponent:integer):byte;                  //Potenz halt
var
i:integer;
begin
  if exponent=0 then result:=1
  else begin
    result:=1;
    for i:=1 to exponent do result:=result*basis;
    end;
  end;

function bittobyte(bits:string):Tarrayofbyte;        //schreibt ein string mit 1/0 in ein Tarrayofbyte um. Dabei werden
var                                                  //immer 8 zeichen des Strings zu einem byte-Wert zusammengefasst
  i,n,lenge:integer;                                 //(bsp.: '101'->5
  abyte:byte;
begin                                                       //länge des zukünftigen array of byte festlegen:
  if (length(bits)mod 8)=0 then lenge:=(length(bits)div 8)  //wenn der BitString genau auf eine menge bytes aufgeht
  else lenge:=(length(bits)div 8)+1;                        //sonst einen länger
  setlength(result,lenge);
  for n:=0 to lenge do begin                                //für jeden byte wiederholen
    abyte:=0;
    if (length(bits)-(n*8))>7 then begin                    //wenn noch 8 bits da sind, dann
    for i:=1 to 8 do begin                                  //achtmal machen:
      if bits[i+(n*8)]='1' then abyte:=abyte+potenz(2,8-i); //den jeweiligen dezimalwert aufsummieren
    end;                                                    //(wenn bits[i]=0 dann halt nicht...
    end
    else begin
      for i:=1 to (length(bits)-(n*8)) do begin             //wenn weniger als 8bit noch da sind im string, dann
        if bits[i+(n*8)]='1' then abyte:=abyte+potenz(2,(length(bits)-(n*8))-i);  //nur so oft noch machen
      end;
    end;
    result[n]:=abyte;                                       //jeweiliges ergebnis in das ergebnis schreiben
  end;
end;

function SArrayToString(a:Tarrayofstring;kommata:boolean):String; //Schreibt ein Tarrayofstring in einen string um (Huffman)
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
        break;                                    //bricht ab, wenn gefunden und gibt True zurück
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
    end;                                                             //aufsummieren für jedes gefundene mal plus 1/lenge
    result:=copy(wahrsch);
  end;

function StringInDatei(a,Path:string):boolean;              //Schreibt einen einzelnen String in eine Text datei
var                                                         //(als .txt lesbar, nicht kryptisch)
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

function StringausDatei(Path:string):string;                 //Läd einen einzelnen String aus einer Text datei
var                                                          //(als .txt lesbar, nicht kryptisch)
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

function SarrayInDatei(data:Tarrayofstring;Path:string):boolean;    //Schreibt ein Array of String in eine Datei
var                                                                 //(als .txt lesbar, nicht kryptisch!)
  List:TStringList;                                                 //Jedes Feld des Arrays ist eine neue Zeile der
  i:integer;                                                        //Text Datei.
begin
 List:=TStringList.create;
  try
  for i:=0 to high(data) do List.add(data[i]);
  List.SaveToFile(Path);
  result:=true;
  finally
     List.free;
  end;
end;

function SarrayAusDatei(Path:string):Tarrayofstring;    //Läd ein array of String aus einer Datei (.txt), in der
var                                                     //Text gespeichert ist. Jede neue Zeile der Datei ist
  List:TStringList;                                     //ein neues Feld des Arrays
  i:integer;
begin
 List:=TStringlist.create;
 try
 List.LoadFromFile(Path);
 setlength(result,List.count);
 for i:=0 to List.count-1 do result[i]:=List[i];
 finally
   list.free;
 end;
end;

function LoadBitString(const Path: string): string;     //Läd einen BitString (1/0) aus der Datei unter Path
var                                                     //Diese Datei kann von allen Möglichen Typen sein!
  fs: TFileStream;
  DataLeft,i: Integer;
  bytes:Tarrayofbyte;
begin
  fs := TFileStream.Create(Path,fmOpenRead or fmShareDenyWrite);
  try
     fs.Position:=0;
     DataLeft := fs.Size;
     SetLength(bytes, DataLeft div SizeOf(Byte));
     fs.Read(PByte(bytes)^, DataLeft);
  finally
     fs.Free;
  end;
  result:='';
  for i:=0 to high(bytes) do result:=result+binStr(bytes[i],8);
end;

{------------------------HUFFMAN-CODING----------------------------------------}
function huffman(s,alpha:string;wahrsch:Tarrayofreal):String;
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
    codealpha[index]:=nullen+'1';                                               //für den wahrscheinlichsten buchstaben aus
    nullen:=nullen+'0';                                                         //alpha hat codealpha '1', für den zwiten 01 usw.
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
    result:=SArrayToString(kompdata,false);
  end;
{------------------------------------------------------------------------------}
{-------------------huffmankompriemierung entpacken----------------------------}
function dehuff(bits:string;codealpha:Tarrayofstring;alpha:string):string;
var
  i,index:integer;
  data,strbits:string;
  begin                                                                         //Init
    data:='';                                                                   //Init
    strbits:='';
    for index:=1 to length(bits) do begin                                       //wenn in den Komprimierten Daten eine 1
     if bits[index]='1' then begin                                              //gefunden wird, wird im Codealphabet nach
        strbits:=strbits+'1';                                                   //der kombination aus den nullen un der 1
        for i:=0 to high(codealpha) do begin                                    //gesucht und der richtige buchstabe
          if strbits=codealpha[i] then data:=data+alpha[i+1];                   //aus alpha an das Ergebnis gehängt
        end;
        strbits:='';
     end
     else strbits:=strbits+'0';                                                 //sonst werden weiter nullen an den
    end;                                                                        //"Vergleichsstring" gehängt
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

  WerteKomprimiert[0]:=1;  //anfangswert, falls sofort ein wechsel auftritt

  //angelehnt an https://rosettacode.org/wiki/Run-length_encoding#Pascal

     for i:=0 to (Length(werte)-2) do begin
         wert1:=(werte[i]);       //werte miteinander vergleichen,ob wechsel (01) vorliegt
         wert2:=(werte[i+1]);
        if wert1=wert2 then
          inc(WerteKomprimiert[z],1) //es wird gezählt, wie oft etwas hintereinander steht
        else begin
          inc(z,1);                   //hier liegt ein wechsel vor und greifen auf den nächsten platz des array zu
          setLength(WerteKomprimiert,Length(WerteKomprimiert)+1);  //dynamische erweiterung des arrays
          WerteKomprimiert[z] := 1;       //auch hier 1 als minimum
        end;
        end;
   result:=copy(WerteKomprimiert);
end;
function rleencodestring(s:string):TarrayofInt ;  // nach https://rosettacode.org/wiki/Run-length_encoding#Pascal ,möglich, um bwt weiter zu verarbeiten
var
   i,y, j,r: integer;      //hauptsächlich laufvariablen
   letters:string;          //speichert die chars ;umbennung der strings und arrays evtl. noch erforderlich
   counts:array of integer;   //speichert, wie oft welcher char vorkommt
   ausgabe:array of integer;
 begin

   j := 0;
   setLength(counts,1);
   setlength(letters,1);
     letters[1]:=s[1];       //erster char wird eingelesen
     counts[0] := 1;         //dieser kommt mind. einmal vor


     for i := 1 to (length(s)-1) do
       if s[i] = s[i+1]  then      //wenn gleich, dann
         inc(counts[j])            //zähle einen mehr
       else
       begin                        //wenn nicht
       setlength(counts,length(counts)+1);       //array-erweiterung
         setlength(letters,length(letters)+1);
         letters[j+2]:=s[i+1];        //nächster char wird gespeichert
         inc(j);
         counts[j] := 1;              //auch dieser kommt mind. einmal vor
       end;

   setLength(ausgabe,length(counts)+length(letters));  //ausgabe setzt sich aus beiden array zusammen

    r:=1;
   y:=0;

   for i:=0 to Length(ausgabe) do begin
      if (i mod 2) = 0 then  begin     //in alle geraden plätze wird der asciicode der chars geschrieben
      ausgabe[i]:=ord(letters[r]);
     inc(r,1);
      end
       else  begin                    //in alle ungeraden plätze wird die anzahl geschrieben
     ausgabe[i]:=counts[y];
    inc(y,1);
   end;
   end;

  result:=copy(ausgabe);


 end;
{------------------------------------------------------------------------------}
{-----------------Run-Length-Encoding entpacken--------------------------------}
 function rledecode(Werte:TArrayofInt;Startwert:byte):TArrayofByte;
var entpackt:array of byte;
    x:byte;
    z,n,i,y:integer;
begin

   if Startwert=0 then x:=1 else x:=0;   //festlegen, wann 0/1 geschrieben werden muss

   z:=0;
   n:=0;

   for i:=0 to (Length(Werte)-1) do begin     //menge der daten bestimmen
      n:=n+Werte[i];
   end;

   setLength(entpackt,n);

   for i:=0 to (Length(Werte)-1) do begin
   if (i mod 2) = 0 then  begin    //startwert bei i=0,2,4,usw. deshalb auf teilbarkeit prüfen
      for y:=1 to Werte[i] do begin
         entpackt[z]:=startwert;//0 oder 1
         Inc(z,1);
      end
      end
       else  begin
        for y:=1 to Werte[i]do  begin
         entpackt[z]:=x;//gegenteil vom startwert
         Inc(z,1);
      end;
       end;

end;
   result:=copy(entpackt);

end;
 function rledecodestring(werte:TArrayofInt):string;      //entpackt einen mit rleencodestring verpackten string
   var
      z,y,m,n,i:integer;   //hauptsächlich laufvariablen
      ausgabe:string;      //entpackter string
      chars:string;        //die chars, aus denen der ex-string bestand
   begin
    n:=0;
    i:=1;
    z:=1;
    m:=1;

    setlength(chars,(length(werte) div 2));  //array ist immer durch 2 teilbar, da jedem char eine zahl zugeordnet wird

      for i:=0 to (Length(Werte)-1) do begin
       if (i mod 2) = 0 then  begin    //hinter den geraden zahlen verstecken sich die buchstaben in asciicode
         chars[m]:=chr(werte[i]);      //aus asciicode wird wieder ein char
         inc(m,1);
       end
        else  begin
         n:=n+werte[i];      //zählen, wie lang der string ehemalig war (jede 2. Zahl gibt an, wie oft ein buchstabe vorhanden ist)
      end;
    end;

    setLength(ausgabe,n);  //ausgabe auf finale länge setzen

   m:=1;

   for i:=0 to (Length(Werte)-1) do begin
    if (i mod 2) <> 0 then  begin        //bei ungeraden zahlen ausführen
         for y:=1 to Werte[i]do  begin   //der buchstabe wird sooft in die ausgabe geschrieben, wie es der ihm zugeordnete wert vorgibt
          ausgabe[z]:=chars[m];
          Inc(z,1);
       end;
        Inc(m,1);
        end;
  end;
      result:=ausgabe;
   end;
{------------------------------------------------------------------------------}
{--------------------Alphabet-Codierung----------------------------------------}
function alphacode(data:string):string;         //Optimiert das Alphabet, das data nutzt indem es ein neues
var                                             //generiert, das nur die notwenige anzahl an zeichen hat
    i,n:integer;
    alphabet,bits:string;
    bitdata,bitalpha:array of string;
    len:byte;
begin
  alphabet:=getalpha(data);                  //Alphabet, das data nutzt generieren
  n:=length(alphabet);
  len:=0;                                    //menge an bits errechnen, die ein zeichen braucht um alle zeichen
  repeat                                     //in alphabet abzubilden (=len)
     n:=n div 2;
     len:=len+1;
  until n=0 ;

  setlength(bitalpha,length(alphabet));     //das neue Alphabet generieren
  for i:=0 to high(bitalpha) do begin
    bitalpha[i]:=binstr(i,len);             //binStr() gibt i als bitString der länge (len) zurück
  end;

  setlength(bitdata,length(data));
  for i:=1 to length(data) do begin         //Die daten in alpha mit dem neuen Alphabet ersetzen
    for n:=1 to length(alphabet) do begin
      if alphabet[n]=data[i] then break;
    end;
    bitdata[i-1]:=bitalpha[n-1];
  end;

  bits:=Sarraytostring(bitdata,false);      //alle Bits hintereinander schreiben (zum auseinandernehmen hat man len als
  result:=bits;                             //Zeichen länge! --also kein problem

  StringinDAtei(inttostr(len),'blocklänge.txt');  //die Zeichenlänge mit abspeichern!!
  SarrayinDatei(bitalpha,'BitAlphabet.txt');      //Das Bitalphabet abspeichern
  StringinDatei(alphabet,'Alphabet.txt');         //Das Klare Alphabet abspeichern
end;
{------------------------------------------------------------------------------}
{------------------Alphabet-DECodierung----------------------------------------}
function dealphacode(bitstr:string):string;
var
    i,n:integer;
    str,daten,alphabet:string;
    bitalpha:Array of string;
    len:byte;
begin
 len:=strtoint(StringAusDatei('blocklänge.txt'));//Die Zeichenlänge der Codierung rausholen
 bitalpha:=Sarrayausdatei('BitAlphabet.txt');  //Das CodeAlphabet laden
 alphabet:=StringausDatei('Alphabet.txt');     //Das KlareAlphabet laden

 daten:='';
 for i:=1 to (length(bitstr) div len) do begin
   str:='';
   for n:=1 to len do str:=str+bitstr[i*len+n-len]; //immer eine bitfolge der länge len aus bitstr ziehen

   for n:=0 to high(bitalpha) do begin              //diese bitfolge im bitalpha finden
     if bitalpha[n]=str then break;
   end;
  daten:=daten+alphabet[n+1];                         //und das passende Zeichen aus dem Klaren Alphabet an daten hängen
 end;
 result:=daten;
end;
{------------------------------------------------------------------------------}
{------------------------Burrows-Wheeler-Transformation------------------------}
function bwt(data:string):string;
var
    str:string;
    i,index:integer;
    indizes:array of integer;
begin
   for i:=0 to length(data)-1 do begin         //für jedes sortieren generieren
    setlength(indizes,i+1);
    str:= permute(data,i);                     //permutation generieren
    for index:=length(indizes)-1 downto 0 do begin
      if tausch(permute(data,indizes[index]),str)=true then begin    //und die nummer der Permutation im array
       indizes[i]:=index;                                    //richtig einsortieren
       indizes[index]:=i;
      end
      else begin
       indizes[i]:=i;
       break;
      end;
    end;
   end;

result:='';
for i:=0 to high(indizes) do begin
    if indizes[i]=0 then index:=i;                           //Ort der original Permutation im Array speichern
    str:=permute(data,i);
    result:=result+str[length(str)];                         //den letzten Buchstaben der Tabbelenzeile abspeichern
 end;
end;
function TKompressorForm.bwt2(indizes:Tarrayofint;origlaenge:integer;orig:string):TArrayofInt;
var q,k,g:integer;
begin

   q:=-1;

    //bwt findet allein anhand des arrays indizes statt, sodass weniger speicher benötigt wird
   //neue prozedur
   for g:=1 to origlaenge do begin                                             //basiert auf bubblesort
   repeat
   q:=q+1;                //hier wird überprüft, ob getauscht werden soll
   if  tausch2(permute2(orig,indizes[q],1),permute2(orig,indizes[q+1],1),orig,indizes[q],indizes[q+1],1,origlaenge)=true then begin //vergleichen
   k:=indizes[q+1];                                                                     //dreieckstausch
   indizes[q+1]:=indizes[q];
   indizes[q]:=k;
                                                                                //erhöhen von n
   end;
  until q=origlaenge-2;
  if q=origlaenge-2 then q:=-1;                                               //zurücksetzen von q
  end;


   result:=indizes;   //ausgabe des nun 'sortierten' arrays
end;
{------------------------------------------------------------------------------}
{-----------------Burrows-Wheeler-Transformation-Decodierung-------------------}
function debwt(trans:string;index:integer):string;
var
  i,n,len,k:integer;
  orig:string;
  indizes:array of integer;
  chr:char;
begin
   len:=length(trans);
   orig:=trans;                                         //die originaldaten speichern
   setlength(indizes,len);                                 //für die indizes in den originaldaten
   for i:=1 to len do indizes[i-1]:=i;             //die indizes initialisieren

   n:=0;
   for i:=1 to len do begin                                             //bubblesort
   repeat
   n:=n+1;
   if ord(orig[n])>ord(orig[n+1]) then begin                                    //vergleichen
   chr:=orig[n];                                                                  //dreieckstausch der chars
   orig[n]:=orig[n+1];
   orig[n+1]:=chr;

   k:=indizes[n-1];                                                               //dreieckstausch der indizes
   indizes[n-1]:=indizes[n];
   indizes[n]:=k;
   end;
  until n=len-1;
  if n=len-1 then n:=0;                                               //zurücksetzen von q
  end;

  result:='';
  for i:=1 to len do begin
   result:=result+orig[index];
   index:=indizes[index-1];
  end;
end;
{$R *.lfm}

{ TKompressorForm }

procedure TKompressorform.save(data:String; const Path:String);
var
  fs: TFileStream;
  bytes:Tarrayofbyte;
begin
  bytes:=bittobyte(data);
  fs := TFileStream.Create(Path, fmCreate);
  try
     fs.WriteBuffer(Pointer(bytes)^, Length(bytes));
  finally
     fs.free;
  end;
 end;

procedure TKompressorForm.KomprimierenButtonClick(Sender: TObject);
var
  Data,alpha,kompdata:string;
  wahrsch:array of real;
  summe:real;
  i,y:integer;
  startwert:byte;
  origdata: array of byte;
  Komprimiert: array of integer;
  rledata,startdata:Tarrayofstring;
  //für bwt:
  {origstr:string;
  origlaenge:integer;
  hilf:string;
  indizes:array of integer;
  g,q,k:integer;
  }
begin
//DATEN LADEN:
 startdata:=SarrayausDAtei(OpenPathEdit.text);
 If MemoAusgabeRadioButton.checked=true then begin
 for i:=0 to high(Startdata) do Memo.lines[i]:=Startdata[i];
 end;
{------------------------------------------------------------------------------}
{---------------------------HUFFMAN--------------------------------------------}
if (HaffCheckbox.Checked=true) then begin
  data:='';
  for i:=0 to high(startdata) do data:=data+startdata[i];                       //Gelesene Daten in einen String umschreib
  alpha:=getalpha(Data);
  wahrsch:=copy(getwahrsch(Data,alpha));

  If MemoAusgabeRadioButton.checked=true then begin
  Memo.lines.add('Alphabet: '+alpha);
  Memo.lines.add('Wahrscheinlichkeit: '+aofrealtostr(wahrsch));
  end;

  If MemoAusgabeRadioButton.checked=true then begin
  {----------------Zur Kontrolle! Summe muss 1 ergeben-------------------------}
  summe:=0;
  for i:=0 to (length(wahrsch)-1) do begin
    summe:=summe+wahrsch[i];
    end;
  Memo.lines.add('Summe der Wahrscheinlichkeiten: '+floattostr(summe));
  {----------------------------------------------------------------------------}
  end;

  kompdata:=huffman(data,alpha,wahrsch);
  Stringindatei(alpha,'Alphabet.txt');
  Sarrayindatei(codealpha,'Codealphabet.txt');

  If MemoAusgabeRadioButton.checked=true then begin
  Memo.Lines.add('Codealpha: '+Sarraytostring(codealpha,true));
  Memo.Lines.add('Komprimiert: '+kompdata);
  Showmessage('Jetzt kommt Run-Length-Encoding.');                              //um dem Nutzer Zeit zu geben die Daten
                                                                                //Im Memo zu überprüfen (geht eleganter)
  end;

  end;
{---------------------RLE------------------------------------------------------}
if (RLCheckBox.Checked=true) then begin

if (HaffCheckBox.Checked=true) then begin;
  startwert:=strtoint(kompdata[1]);
  setlength(origdata,length(kompdata)-1);
  for i:=1 to length(kompdata)-1 do origdata[i-1]:=strtoint(kompdata[i+1]);       //kompdata direkt in origdata, ohne Memo
 end;
if (HaffCheckBox.checked=false) and (RLCheckBox.checked=true) then begin
   data:=loadBitString(OpenPathEdit.text);
   startwert:=strtoint(data[1]);    //für späteres zurückrechnen merken    //wenn vorher nicht gehufft wurde, dann
                                                                                //ausgelesene Daten nehmen.
   setLength(origdata,length(data)-1);    //übernahme der werte aus startdata
  for i:=2 to length(data) do begin
    origdata[i-2]:=strtoint(data[i]);
  end;
 end;

  If MemoAusgabeRadioButton.checked=true then begin
  for i:=1 to high(data) do Memo.lines[i-1]:=data[i];
  end;

  Komprimiert:=rleencode(origdata);     //erstellen des kompr. arrays

  If MemoAusgabeRadioButton.checked=true then begin
  Memo.lines.clear;             //für ausgabe der komprimierten Werte
  memo.lines[0]:='Erster byte: '+inttostr(startwert);   //erster byte wird mit ausgegeben/abgespeichert, um später zurückzurechnen

  for y:=0 to (Length(Komprimiert)-1) do begin     //ausgabe der kompr. werte
    Memo.lines[y+1]:=inttostr(Komprimiert[y]);
  end;
  end;

  setlength(rledata,length(komprimiert)+1);             //Die Daten aus komprimiert als String abspeichern
  rledata[0]:=inttostr(startwert);
  for i:=0 to high(komprimiert) do rledata[i+1]:=inttostr(komprimiert[i]);
  SarrayInDatei(rledata,SavePathEdit.text);
  end;
//Wenn nicht noch mit RLE komprimieren:
if (RLCheckbox.checked=false) and (HaffCheckBox.checked=true) then begin
save(kompdata,SavePathEdit.text);    //Den Bitstring, den huffman generiert hat abspeichern.
end;
{------------------------------------------------------------------------------}
{--------------------------Alpha-Codierung-------------------------------------}
if (alphaCheckBox.checked=true) and (RLCheckbox.checked=false) and (HaffCheckBox.checked=false) then begin
  data:=alphacode(sarraytostring(startdata,false));
  If MemoAusgabeRadioButton.checked=true then Showmessage('Bits: '+data);
  save(data,SavePathEdit.text);
  end;
{------------------------------------------------------------------------------}
{-------------------------BURROWS-WHEELER--------------------------------------}
if BWTCheckBox.checked=true then begin
   data:=Memo.lines[0];
  //alter bwt Memo.lines.add(bwt(data));
   //bwt verbessert
    q:=-1;


    origstr:=data;//einlesen?!
    origlaenge:=origstr.length;
    setlength(indizes,origlaenge);
    setlength(verpackt,origlaenge);
   for i:=0 to (origlaenge-1) do begin
    indizes[i]:=i;
   end;

   indizes:=bwt2(indizes,origlaenge,orig);  //ersetzt unten auskommentierte schleife als funbktion
  { for g:=1 to origlaenge do begin                                             //bubblesort
   repeat
   q:=q+1;
   if  tausch2(permute2(orig,indizes[q],1),permute2(orig,indizes[q+1],1),orig,indizes[q],indizes[q+1],1,origlaenge)=true then begin                                               //vergleichen
   k:=indizes[q+1];                                                                     //dreieckstausch
   indizes[q+1]:=indizes[q];
   indizes[q]:=k;
                                                                                //erhöhen von n
   end;
  until q=origlaenge-2;
  if q=origlaenge-2 then q:=-1;                                               //zurücksetzen von q
  end;}

  for i:=0 to (origlaenge-1) do begin      //hier wird verpackt
  hilf:=permute(origstr,indizes[i]);       //erstellen der vollständigen permutation
 // memo.lines[i]:=hilf;    //ausgabe im memo/ abfragen?
  if hilf=origstr then index:=i+1;  //index wäre 1 wenn 2. permutation original ist (memo 0,1..)
  verpackt[i+1]:=hilf[origlaenge];     //nur der letzte buchstabe gelangt in die verpackte version
  end;
  Memo.lines.add(verpackt+inttostr(index));
  //rleencodestring mit bwt-ergebnis (verpackt+inttostr(index))
  //direkt möglich (vorherige kontrolle, ob rle auch haken?
  end;
end;

procedure TKompressorForm.DekomprimierenButtonClick(Sender: TObject);
var
  codealpha,readdata:array of string;
  alpha,sw,rledata,entpacktstr,a:string;
  entpackt:array of byte;
  verpackt:array of integer;
  startwert:byte;
  i:integer;
begin
 {-------------------------RLE-DeRLE--------------------------------------------}
  if RLCheckBox.Checked=true then begin

  //DATEN LADEN:
  Memo.lines.clear;
  readdata:=SarrayausDatei(OpenPathEdit.text);
  If MemoAusgabeRadioButton.checked=true then begin
  for i:=0 to high(readdata) do Memo.Lines[i]:=readdata[i];  //und ins Array schreiben
  end;

 {----------------------EINLESEN-----------------------------------------------}
  setLength(verpackt,length(readdata));       //anlegen des arrays zum Einlesen
  sw:=readdata[0];                    //einlesen des startwerts (erster byte)
  startwert:=strtoint(sw);
  for i:=1 to high(readdata) do begin    //einlesen der zu entpackenden werte
    verpackt[i-1]:=strtoint(readdata[i]);
  end;
{------------------------------------------------------------------------------}

  entpackt:=rledecode(verpackt,startwert);        //hier wird entpackt

  If MemoAusgabeRadioButton.checked=true then begin
  memo.lines.clear;                               //für ausgabe der entpackten werte
  for i:=0 to (Length(entpackt)-1) do begin       //ausgabe der entpackten werte
    Memo.lines[i]:=inttostr(entpackt[i]);
    end;
  end;

  setlength(rledata,length(entpackt));
  for i:=0 to high(entpackt) do begin
    a:=inttostr(entpackt[i]);
    rledata[i+1]:=a[1];                            //Daten für dehuff als String bereitstellen
  end;

  if HaffCheckBox.checked=false then begin         //wenn nicht noch mit Huffman entpackt wird, ergebnis abspeichern
  save(rledata,SavePathedit.text);
  end;
  end;

  //Wenn nicht mit RLE dekomprimiert werden soll, dann:
  if (haffcheckbox.Checked=true) and (rlCheckbox.checked=false) and (alphacheckbox.checked=false) then begin
    rledata:=loadBitString(OpenPathEdit.text);
    If MemoAusgabeRadioButton.checked=true then begin
    for i:=1 to length(rledata) do Memo.lines[i-1]:=rledata[i];
    end;
 end;
{------------------------------------------------------------------------------}
 {--------------------------HUFFMAN-DEHUFF-------------------------------------}
  if (HaffCheckBox.Checked=true) and (alphacheckbox.checked=false) then begin

  codealpha:=SarrayAusDatei('Codealphabet.txt');
  alpha:=StringAusDatei('Alphabet.txt');
  entpacktstr:=dehuff(rledata,codealpha,alpha);              //hier wird die Huffmankomprimierung aufgehoben
  StringinDatei(entpacktstr,SavePathEdit.text);              //und abgespeichert

  If MemoAusgabeRadioButton.checked=true then begin
  Memo.lines.add('gelesenes Codealphabet: '+Sarraytostring(codealpha,true));
  Memo.lines.add('gelesenes Alphabet: '+alpha);
  Memo.lines.add('Entpackt: '+entpacktstr);
  end;
  end;
{------------------------------------------------------------------------------}
{--------------------------Alpha-Codierung-------------------------------------}
if (alphaCheckBox.checked=true) and (RLCheckbox.checked=false) and (HaffCheckBox.checked=false) then begin
  StringINDatei(dealphacode(loadbitstring(OpenPathEdit.text)),SavePathEdit.text);
  end;
{------------------------------------------------------------------------------}
end;

procedure TKompressorForm.OpenSpeedButtonClick(Sender: TObject);
begin
    If OpenDialog.execute then OpenPathEdit.text:= OpenDialog.Filename;
end;

procedure TKompressorForm.SaveSpeedButtonClick(Sender: TObject);
begin
    If SaveDialog.execute then SavePathEdit.text:= SaveDialog.Filename;
end;
{ TKompressorForm }


end.


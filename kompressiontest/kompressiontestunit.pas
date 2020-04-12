unit kompressiontestunit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, FileUtil,
  ComCtrls, Buttons;

type
  TArrayofByte= array of byte;
  TArrayofInt= array of integer;

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Edit1: TEdit;
    Edit2: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Memo1: TMemo;
    Memo2: TMemo;
    OpenDialog1: TOpenDialog;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    function rledecode(Werte:TArrayofInt;Startwert:byte):TArrayofByte;
    procedure SpeedButton2Click(Sender: TObject);
    function tausch2(char1,char2:char;str:string;index1,index2:integer;pos,max:integer):boolean;
    function bwt(indizes:TArrayofInt;origlaenge:integer;orig:string):TArrayofInt;
  private

  public

  end;

var
  Form1: TForm1;
  Werterandom:Array of byte;
  WerteKomprimiert: Array of integer;
  wert1:byte;
  wert2:byte;
  startwert:byte;
  i,n,z,y:integer;

implementation

{$R *.lfm}

{ TForm1 }


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
function permute2(str:string;index:integer;pos:integer):char;
var l:integer;
begin
   l:=length(str);
    if (pos+index)>l then result:=str[pos+index-l]
     else result:=str[index+pos];
end;
{function TForm1.bwt(indizes:array of integer;origlaenge:integer;orig:string):TArrayofInt;
var q,k,g:integer;
begin

   q:=-1;


   //neue prozedur
   for g:=1 to origlaenge do begin                                             //bubblesort
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
  end;


   result:=ausgabe;
end; }

{alternative zur einfachen tauschfunktion}
{deklaration als tform.funktion und listung unter tform}
{rekursiv: sind die chars gleich, ruft sich die funktion}
{selbst auf, dabei werden die nächsten chars verglichen etc}
function TForm1.tausch2(char1,char2:char;str:string;index1,index2:integer;pos,max:integer):boolean;                //untersucht ob str1 und str2 getauscht werden sollen
begin
 result:=false;                                            //Damit result auch gesetzt ist, wenn die strings gleich sind
     if (ord(char1)=ord(char2)) AND (pos<=max) then begin
       result:=tausch2(permute2(str,index1,pos+1),permute2(str,index2,pos+1),str,index1,index2,pos+1,max);
      end
    else
    if ord(char1)>ord(char2) then begin        //ASCII indizes der Stringzeichen an der stelle i vergleichen
      result:=true;                                //und danach entscheiden                                      //...wenn sie geleich sind, dann eine position weiter gehen
    end;                                           //im string und wieder vergleichen.
    if ord(char1)<ord(char2) then begin
      result:=false;
    end;
  end;

function rleencode(Werte:TArrayofByte):TArrayofInt;
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
function rleencode2(Werte:TArrayofByte;startwert:integer):string;
var wertestring:string;
    hilf:string;

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

    setlength(wertestring,2);
     z:=2;
    wertestring[1]:=inttostr(startwert)[1];
   for i:=0 to (length(WerteKomprimiert)-1) do begin
      hilf:=inttostr(Wertekomprimiert[i]);
       for y:=1 to length(hilf)  do begin
          wertestring[z]:=hilf[y];
          setlength(wertestring,length(wertestring)+1);
          inc(z,1);
       end;
   end;
   result:=Wertestring;
end;
// nach https://rosettacode.org/wiki/Run-length_encoding#Pascal
 //möglich, um bwt weiter zu verarbeiten
function rleencodestring1(s:string):TarrayofInt ;
var
   i, j,r: integer;
   letters:string;
   counts:array of integer;
   ausgabe:array of integer;
 begin

   j := 0;
   setLength(counts,1);
   setlength(letters,1);
     letters[1]:=s[1];
     counts[0] := 1;


     for i := 1 to (length(s)-1) do
       if s[i] = s[i+1]  then
         inc(counts[j])
       else
       begin
       setlength(counts,length(counts)+1);
         setlength(letters,length(letters)+1);
         letters[j+2]:=s[i+1];
         inc(j);
         counts[j] := 1;
       end;

   setLength(ausgabe,length(counts)+length(letters));

    r:=1;
   y:=0;

   for i:=0 to Length(ausgabe) do begin
      if (i mod 2) = 0 then  begin
      ausgabe[i]:=ord(letters[r]);
     inc(r,1);
      end
       else  begin
     ausgabe[i]:=counts[y];
    inc(y,1);
   end;
   end;
   {y:=1;
   r:=0;

  repeat
  //ausgabe[y]:=ord(letters[r+1]);
  ausgabe[y]:=counts[r];
  inc(y,2);
  inc(r,1);
  until y>(length(ausgabe));

  y:=0;
  r:=1;
  repeat
  ausgabe[y]:=ord(letters[r]);
  inc(y,2);
  inc(r,1);
  until y=(length(ausgabe)); }

  result:=copy(ausgabe);


 end;
function rleencodestring3(s:string):string ;
var
   i, j,r: integer;
   letters:string;
   counts:array of integer;
   ausgabe:array of integer;
   stringausgabe:string;
   hilf:string;
 begin

   j := 0;
   setLength(counts,1);
   setlength(letters,1);
     letters[1]:=s[1];
     counts[0] := 1;


     for i := 1 to (length(s)-1) do
       if s[i] = s[i+1]  then
         inc(counts[j])
       else
       begin
       setlength(counts,length(counts)+1);
         setlength(letters,length(letters)+1);
         letters[j+2]:=s[i+1];
         inc(j);
         counts[j] := 1;
       end;

   setLength(ausgabe,length(counts)+length(letters));

    r:=1;
   y:=0;

   for i:=0 to Length(ausgabe) do begin
      if (i mod 2) = 0 then  begin
      ausgabe[i]:=ord(letters[r]);
     inc(r,1);
      end
       else  begin
     ausgabe[i]:=counts[y];
    inc(y,1);
   end;
   end;

 setlength(stringausgabe,1);
     z:=1;

   for i:=0 to (length(ausgabe)-1) do begin
    if (i mod 2)=0 then begin
    stringausgabe[z]:=chr(ausgabe[i]);
    setlength(stringausgabe,length(stringausgabe)+1);
    inc(z,1);
    end;
    if (i mod 2)<>0 then begin
    hilf:=inttostr(ausgabe[i]);
       for y:=1 to length(hilf)  do begin
          stringausgabe[z]:=hilf[y];
          setlength(stringausgabe,length(stringausgabe)+1);
          inc(z,1);
       end;
    end;
   end;
  result:=stringausgabe;


 end;
//funktioniert nicht, wenn anzahl>9
 function rleencodestring2(s:string):string;
var
   i, j,r: integer;
   letters:string;
   counts:array of integer;
   hilf,ausgabe:string;
 begin
   j := 0;
   setLength(counts,1);
   setlength(letters,1);
     letters[1]:=s[1];
     counts[0] := 1;


     for i := 1 to (length(s)-1) do
       if s[i] = s[i+1]  then
         inc(counts[j])
       else
       begin
       setlength(counts,length(counts)+1);
         setlength(letters,length(letters)+1);
         letters[j+2]:=s[i+1];
         inc(j);
         counts[j] := 1;
       end;

   setLength(ausgabe,length(counts)+length(letters));


   y:=1;
   r:=0;

  repeat
  ausgabe[y]:=letters[r+1];
  hilf:=inttostr(counts[r]);
  ausgabe[y+1]:=hilf[1];
  inc(y,2);
  inc(r,1);
  until y>(length(ausgabe));

  result:=ausgabe;

 end;
 function rledecodestring(werte:TArrayofInt):string;
 var //n:integer;
    z,y,x,m:integer;
    ausgabe:string;
    chars:string;
 begin
  n:=0;
  i:=1;
  z:=1;
  m:=1;

  setlength(chars,(length(werte) div 2));


  repeat
  n:=n+werte[i];
  if m<5 then chars[m]:=chr(werte[i-1]);
  inc(i,2);
  inc(m,1);
  until i>(length(werte)-1);

  setLength(ausgabe,n);

  x:=1;
  m:=1;
  repeat
  for y:=1 to Werte[x] do begin
         ausgabe[z]:=chars[m];
         Inc(z,1);
      end ;
  inc(m,1);
  Inc(x,2);
  if m=length(chars) then ausgabe[z]:=chars[m];
  until x>(length(ausgabe)) ;

  result:=ausgabe;

 end;
 function rledecodestring2(werte:TArrayofInt):string;
  var
     //n:integer;
     z,y,m:integer;
     ausgabe:string;
     chars:string;
  begin
   n:=0;
   i:=1;
   z:=1;
   m:=1;

   setlength(chars,(length(werte) div 2));

     for i:=0 to (Length(Werte)-1) do begin
      if (i mod 2) = 0 then  begin
        chars[m]:=chr(werte[i]);
        inc(m,1);
      end
       else  begin
        n:=n+werte[i];
     end;
   end;

   setLength(ausgabe,n);

  m:=1;

  for i:=0 to (Length(Werte)-1) do begin
   if (i mod 2) <> 0 then  begin
        for y:=1 to Werte[i]do  begin
         ausgabe[z]:=chars[m];
         Inc(z,1);
      end;
       Inc(m,1);
       end;
 end;
     result:=ausgabe;
  end;
 function Tform1.rledecode(Werte:TArrayofInt;Startwert:byte):TArrayofByte;
var entpackt:array of byte;
  x:byte;
begin

   if Startwert=0 then x:=1 else x:=0;
   z:=0;
   n:=0;
   for i:=0 to (Length(Werte)-1) do begin
      n:=n+Werte[i];
   end;

   setLength(entpackt,n);

   for i:=0 to (Length(Werte)-1) do begin
   if (i mod 2) = 0 then  begin
      for y:=1 to Werte[i] do begin
         entpackt[z]:=startwert;//0 oder 1
         Inc(z,1);
      end
      end
       else  begin
        for y:=1 to Werte[i]do  begin
         entpackt[z]:=x;//0 oder 1
         Inc(z,1);
      end;
       end;

end;
   result:=copy(entpackt);

end;

procedure TForm1.SpeedButton2Click(Sender: TObject);
begin
   if opendialog1.Execute then
  begin
    Label1.caption:=opendialog1.FileName;
    Label2.caption:=inttostr(filesize(opendialog1.FileName))+'bytes';
    //DateiEingabeEdit.OnExit(DateiEingabeEdit);
  end;
end;

function TForm1.bwt(indizes:Tarrayofint;origlaenge:integer;orig:string):TArrayofInt;
var q,k,g:integer;
begin

   q:=-1;


   //neue prozedur
   for g:=1 to origlaenge do begin                                             //bubblesort
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
  end;


   result:=indizes;
end;

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

procedure TForm1.Button1Click(Sender: TObject);
var ausgabe:string;
test2:array of byte;
begin
  memo1.lines.clear;

 setLength(Werterandom,(strtoint(Edit1.text)-1));
  for i:=0 to (strtoint(Edit1.text)-1) do begin
    Werterandom[i]:=random(2);
    Memo1.lines[i]:=inttostr(Werterandom[i])
  end;


  startwert:=strtoint(memo1.lines[0]);

  setLength(test2,memo1.lines.count);

  for i:=0 to (memo1.lines.count-1) do begin
    test2[i]:=strtoint(Memo1.lines[i]);
  end;
  ausgabe:=rleencode2(test2,startwert);

  //memo1.lines.clear;
  memo1.lines.add('länge'+inttostr(length(ausgabe)));
  memo1.lines.add('Erster byte: '+inttostr(startwert));
 // memo1.lines[1]:='Orig. Größe: '+ inttostr(Length(Test2))+'; Verpackt: '+Inttostr(Length(test));//bezieht sich auf das array

    for i:=1 to (Length(ausgabe)) do begin
    Memo1.lines.add(ausgabe[i]);
    end;

end;

procedure TForm1.Button2Click(Sender: TObject);
var testentpackt:array of byte;
test23:array of integer;
  sw:string;
begin









  {   setLength(test23,memo1.lines.count);
      sw:=Memo1.lines[0];
     startwert:=strtoint(sw[14]);

  for i:=1 to (memo1.lines.count-1) do begin
    test23[i-1]:=strtoint(Memo1.lines[i]);
  end;
  memo1.lines.clear;

  testentpackt:=rledecode(test23,startwert);

  for i:=0 to (Length(testentpackt)-1) do begin
    Memo1.lines[i]:=inttostr(testentpackt[i]);
    end;        }

end;

procedure TForm1.Button3Click(Sender: TObject);
var test: array of integer;
    test2: array of byte;
    testtext:string;
    hilf:string;
    tabelle:TStringlist;
    m:integer;
    origlaenge:integer;
    verpackt:string;
    index:integer;
    orig:string;
    hilf2:string;
    q,k,g:integer;
    indizes:array of integer;
    tick1,tick2:int64;
begin
    q:=-1;

    testtext:=edit2.text;
    orig:=testtext;
    origlaenge:=testtext.length;
    setlength(indizes,origlaenge);
    setlength(verpackt,origlaenge);
   tick1:=gettickcount64;
   for i:=0 to (origlaenge-1) do begin
    indizes[i]:=i;
   end;

   indizes:=bwt(indizes,origlaenge,orig);
   //neue prozedur
   {for g:=1 to origlaenge do begin                                             //bubblesort
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
  end; }
   //alte prozedur
 { for g:=1 to origlaenge do begin                                             //bubblesort
   repeat
   q:=q+1;
   if tausch(permute(orig,indizes[q]),permute(orig,indizes[q+1]))=true then begin                                               //vergleichen
   k:=indizes[q+1];                                                                     //dreieckstausch
   indizes[q+1]:=indizes[q];
   indizes[q]:=k;
                                                                                //erhöhen von n
   end;
  until q=origlaenge-2;
  if q=origlaenge-2 then q:=-1;                                               //zurücksetzen von q
  end; }

  for i:=0 to (origlaenge-1) do begin
  hilf2:=permute(orig,indizes[i]);
  memo1.lines[i]:=hilf2;    //ausgabe im memo
  if hilf2=orig then index:=i+1;  //index wäre 1 wenn 2. permutation original ist (memo 0,1..)
  verpackt[i+1]:=hilf2[origlaenge];
  end;
  tick2:=gettickcount64-tick1;
  Memo1.lines.add(verpackt+inttostr(index));
  //memo1.lines[origlaenge]:=verpackt+inttostr(index);
  memo1.lines.add(inttostr(tick2)+'ms');

  memo1.lines.add('detransformiert: ');
  memo1.lines.add(debwt(verpackt,index));
   memo1.lines.add('mit rle:');
   memo1.lines.add(rleencodestring3(verpackt+inttostr(index)));
 // memo1.lines.add(rleencodestring2(verpackt+inttostr(index)));
 {test:=rleencodestring1(verpackt+inttostr(index));
 edit1.text:=inttostr(length(test));
 memo2.lines.clear;
 i:=0;
 repeat
 Memo2.lines.add(chr(test[i]));
 Memo2.lines.Add(inttostr(test[i+1]));
 inc(i,2)
 until i=(Length(test)); }

 { memo1.lines.Add('rle detransformiert:');
 hilf:=rledecodestring2(test);
 memo1.lines.add(hilf);
 edit1.text:=inttostr(length(hilf));  }
// memo1.lines.add(rledecodestring(test));





    //alte bwt
 { tabelle:=TStringlist.Create;
   testtext:=edit2.text;
   orig:=testtext;
   origlaenge:=testtext.length;
   testtext:=testtext+testtext; //als hilfe, keine sorge um zu großes n+m


    m:=0;
   setlength(hilf,origlaenge);
  for i:=0 to (origlaenge-1) do begin
      for n:=1 to origlaenge do begin
        hilf[n]:=testtext[n+m];
      end;
      inc(m);
     tabelle.Add(hilf);
  end;

  tabelle.Sort;
  memo1.lines.Assign(tabelle);    //mit memoausgabe
  setlength(verpackt,origlaenge);
  {for i:=0 to (origlaenge-1) do begin
  hilf2:=memo1.lines[i];
  if hilf2=orig then index:=i+1;  //index wäre 1 wenn 2. permutation original ist (memo 0,1..)
  verpackt[i+1]:=hilf2[origlaenge];
  end;}
    for i:=0 to (origlaenge-1) do begin   //ohne ausgabe
  hilf2:=tabelle[i];
  if hilf2=orig then index:=i+1;  //index wäre 1 wenn 2. permutation original ist (memo 0,1..)
  verpackt[i+1]:=hilf2[origlaenge];
  end;
  }

 // edit1.text:=verpackt+inttostr(index);
 //altes rle
 { startwert:=strtoint(memo1.lines[0]);

  setLength(test2,memo1.lines.count);

  for i:=0 to (memo1.lines.count-1) do begin
    test2[i]:=strtoint(Memo1.lines[i]);
  end;
  test:=rleencode(test2);

  memo1.lines.clear;
  memo1.lines[0]:='Erster byte: '+inttostr(startwert);
 // memo1.lines[1]:='Orig. Größe: '+ inttostr(Length(Test2))+'; Verpackt: '+Inttostr(Length(test));//bezieht sich auf das array

    for i:=0 to (Length(test)-1) do begin
    Memo1.lines[i+1]:=inttostr(test[i]);
    end;

    }



end;

procedure TForm1.FormCreate(Sender: TObject);

begin
  Randomize;
end;



end.


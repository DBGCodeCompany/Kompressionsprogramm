unit kompressiontestunit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ButtonPanel,
  ComCtrls;

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
    Memo1: TMemo;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    function rledecode(Werte:TArrayofInt;Startwert:byte):TArrayofByte;
    function tausch2(char1,char2:char;str:string;index:integer;pos:integer):boolean;
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

function permute2(str:string;index:integer;pos:integer):char;
var l:integer;
begin
   l:=length(str);
    if (pos+index)>l then result:=str[pos+index-l]
     else result:=str[index+pos];
end;
{alternative zur einfachen tauschfunktion}
{deklaration als tform.funktion und listung unter tform}
{rekursiv: sind die chars gleich, ruft sich die funktion}
{selbst auf, dabei werden die nächsten chars verglichen etc}
function TForm1.tausch2(char1,char2:char;str:string;index:integer;pos:integer):boolean;                //untersucht ob str1 und str2 getauscht werden sollen
begin
 result:=false;                                            //Damit result auch gesetzt ist, wenn die strings gleich sind
     if ord(char1)=ord(char2) then begin
       result:=tausch2(permute2(str,index,pos+1),permute2(str,index+1,pos+1),str,index,pos+1);
      end
    else
    if ord(char1)>ord(char2) then begin        //ASCII indizes der Stringzeichen an der stelle i vergleichen
      result:=true;                                //und danach entscheiden                                      //...wenn sie geleich sind, dann eine position weiter gehen
    end;                                           //im string und wieder vergleichen.
    if ord(char1)<ord(char2) then begin
      result:=false;
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


procedure TForm1.Button1Click(Sender: TObject);
begin


 setLength(Werterandom,(strtoint(Edit1.text)-1));
  for i:=0 to (strtoint(Edit1.text)-1) do begin
    Werterandom[i]:=random(2);
    Memo1.lines[i]:=inttostr(Werterandom[i])
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
begin
    q:=-1;

    testtext:=edit2.text;
    orig:=testtext;
    origlaenge:=testtext.length;
    setlength(indizes,origlaenge-1);
    setlength(verpackt,origlaenge);

   for i:=0 to (origlaenge-1) do begin
    indizes[i]:=i;
   end;
    //neue prozedur
    for g:=1 to origlaenge do begin                                             //bubblesort
   repeat
   q:=q+1;
   if tausch2(permute2(orig,indizes[q],1),permute2(orig,indizes[q+1],1),orig,indizes[q],1)=true then begin                                               //vergleichen
   k:=indizes[q+1];                                                                     //dreieckstausch
   indizes[q+1]:=indizes[q];
   indizes[q]:=k;
                                                                                //erhöhen von n
   end;
  until q=origlaenge-2;
  if q=origlaenge-2 then q:=0;                                               //zurücksetzen von q
  end;

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
  if q=origlaenge-2 then q:=0;                                               //zurücksetzen von q
  end; }

  for i:=0 to (origlaenge-1) do begin   //ohne ausgabe
  hilf2:=permute(orig,indizes[i]);
  memo1.lines[i]:=hilf2;
  if hilf2=orig then index:=i+1;  //index wäre 1 wenn 2. permutation original ist (memo 0,1..)

  verpackt[i+1]:=hilf2[origlaenge];
  end;
  memo1.lines[origlaenge]:=verpackt+inttostr(index);






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
  for i:=0 to (origlaenge-1) do begin
  hilf2:=tabelle[i];
  if hilf2=orig then index:=i+1;  //index wäre 1 wenn 2. permutation original ist (memo 0,1..)
  verpackt[i+1]:=hilf2[origlaenge];
  end;
  edit1.text:=verpackt+inttostr(index);
  }



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


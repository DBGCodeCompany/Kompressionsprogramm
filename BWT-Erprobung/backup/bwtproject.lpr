//Zur erprobung der Burrows-Wheeler-Transformation
program bwtproject;

var
  data:string;


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
        end;
      end;
     end;

  result:='';
  for i:=0 to high(indizes) do begin
      if indizes[i]=0 then index:=i;                           //Ort der original Permutation im Array speichern
      str:=permute(data,i);
      writeln(str);                                            //for Debug
      result:=result+str[length(str)];                         //den letzten Buchstaben der Tabbelenzeile abspeichern
   end;
  end;


begin
  writeln('Bitte String angeben: ');
  readln(data);
  writeln('BWT-Transformiert: ');
  writeln(bwt(data));
  readln;
end.


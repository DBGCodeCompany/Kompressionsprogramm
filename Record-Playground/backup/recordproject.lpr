program recordproject;

uses
sysutils,classes;

type
  TDatensatz =record
    str:string;
    Astr: array of shortstring;                   //um den Kram laden zu können muss wenigstens die Felder des arrays
  end;                                            //statisch sein...

  var
    i,count:integer;
    go,path:string;
    daten:TDatensatz;
    FS:TFileStream;

begin
  Writeln('Moechten Sie einen bestehenden Datensatz laden? [J];[n]');
  readln(go);
  if go='J' then begin
    Writeln('Geben Sie dazu den Pfad an.');
    readln(path);
    FS:= TFileStream.Create(path, fmOpenRead or fmShareDenyWrite);
    try
      FS.Position:=0;
      FS.Read(i,sizeof(integer));        //länge des kommenden String auslesen
      Setlength(daten.str,i);              //und länge setzen
      FS.Read(daten.str[1],(i*sizeof(char))); //String lesen

      FS.Read(i,sizeof(integer));                      //länge des kommenden Arrays auslesen
      Setlength(daten.Astr,i);                           //und setzen
      FS.Read(daten.Astr[0],(i*Sizeof(shortstring))); //Array lesen
    finally
      FS.free;
    end;
    Writeln();
    Writeln('Datensatz: '+daten.str);
    for i:=0 to high(daten.Astr) do writeln(daten.Astr[i]);
    readln;
  end
  else begin
  writeln('Wie heisst der Datensatz?');
  readln(daten.str);
  writeln('Wie viele Namen haben Sie?');
  readln(go);
  setlength(daten.Astr,strtoint(go));
  for i:=0 to high(daten.Astr) do readln(daten.Astr[i]);
  Writeln();
  Writeln('Datensatz: '+daten.str);
  for i:=0 to high(daten.Astr) do writeln(daten.Astr[i]);
  Writeln('Moechten Sie diese Abspeichern? [J]; [n]');
  readln(go);
  if go='J' then begin
    writeln('Geben Sie dazu einen Pfad an.');
    readln(path);
    FS:=TFileStream.Create(path,fmCreate);
    try
      FS.Position:=0;
      i:=length(daten.str);
      FS.write(i,sizeOf(i)); //länge des String schreiben
      FS.Write(daten.str[1],i); //String schreiben

      i:=length(daten.Astr);
      FS.Write(i,sizeOf(i)); //länge des Arrays schreiben
      FS.Write(daten.Astr[0],i*sizeOf(shortstring)); //String schreiben
    finally
      FS.free;
    end;
    writeln('Abgespeichert.');
    readln;
  end;
  end;
end.


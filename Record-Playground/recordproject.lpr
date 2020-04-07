program recordproject;

uses
sysutils,classes;

type                                              //um den record abspeichern zu können müssen die strings
  TDatensatz =record                              //und arrays leider statisch sein...
    str:string;
    Astr: array of shortstring;
  end;

  var
    i:integer;
    go,path:string;
    daten:TDatensatz;
    datei:file of TDatensatz;

begin
  Writeln('Moechten Sie einen bestehenden Datensatz laden? [J];[n]');
  readln(go);
  if go='J' then begin
    Writeln('Geben Sie dazu den Pfad an.');
    readln(path);
    try
      Assignfile(datei,path);
      reset(datei);
      read(datei,daten);
    finally
      closefile(datei);
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
  setlength(daten.Astr,inttostr(go));
  for i:=0 to high(daten.Astr) do readln(daten.Astr[i]);
  Writeln();
  Writeln('Datensatz: '+daten.str);
  for i:=0 to high(daten.Astr) do writeln(daten.Astr[i]);
  Writeln('Moechten Sie diese Abspeichern? [J]; [n]');
  readln(go);
  if go='J' then begin
    writeln('Geben Sie dazu einen Pfad an.');
    readln(path);
    try
      AssignFile(datei,path);
      ReWrite(datei);
      Write(datei,daten);
    finally
      closefile(datei);
    end;
    writeln('Abgespeichert.');
    readln;
  end;
  end;
end.


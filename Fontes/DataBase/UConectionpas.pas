unit UConectionpas;

interface

uses
  FireDAC.Comp.Client, FireDAC.Phys,FireDAC.Phys.MySQL, FireDAC.Stan.Async,
  Firedac.Stan.Option,System.IniFiles, System.SysUtils;

function GetConnectionMYSQL: TFDConnection;

implementation

function GetConnectionMYSQL: TFDConnection;
var
  IniFile: TIniFile;
  DBMySQL: TFDConnection;
  FDPhysMySQLDriverLink1: TFDPhysMySQLDriverLink;
begin
  IniFile := TIniFile.Create(ExtractFilePath(ParamStr(0)) +  'config.ini');
  DBMySQL := TFDConnection.Create(nil);
  FDPhysMySQLDriverLink1:= TFDPhysMySQLDriverLink.Create( DBMySQL );
  FDPhysMySQLDriverLink1.VendorLib:= ExtractFilePath(ParamStr(0)) + 'libmysql.dll';
  try
    DBMySQL.DriverName := 'MySQL';
    DBMySQL.Params.DriverID := 'MySQL';

    with DBMySQL.Params do
    begin
      Clear;
      Add('DriverID=MySQL');
      Add('Server='     + IniFile.ReadString ('DATABASE', 'Server', '') );
      Add('Port='       + IniFile.ReadString ('DATABASE', 'Porta', '') );
      Add('Database='   + IniFile.ReadString ('DATABASE', 'Databasename', '') );
      Add('User_Name='  + IniFile.ReadString ('DATABASE', 'User', '') );
      Add('Password='   + IniFile.ReadString ('DATABASE', 'Pass', '') );
    end;


    DBMySQL.TxOptions.AutoCommit:= False;
    DBMySQL.TxOptions.Isolation:= xiReadCommitted;

    DBMySQL.Connected := True;

    Result := DBMySQL;

  finally
    IniFile.Free;
  end;
end;

end.

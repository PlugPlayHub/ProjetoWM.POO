unit DataModule.Global;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.SQLite,
  FireDAC.Phys.SQLiteDef, FireDAC.Stan.ExprFuncs,
  FireDAC.Phys.SQLiteWrapper.Stat, FireDAC.VCLUI.Wait,
  FireDAC.Comp.Client, Vcl.Dialogs,

  System.JSON, FireDAC.DApt,

  FireDAC.Phys.FBDef, FireDAC.Phys.FB,
  FireDAC.Phys.IBBase ,
  System.Generics.Collections, System.Variants, Data.DB, FireDAC.Phys.MySQLDef,
  FireDAC.Phys.MySQL ;

type
  TLinhaDinamica = TDictionary<string, Variant>;
  TListaLinhas = TList<TLinhaDinamica>;
  type_obj = (nsRecord, nsSubForm, nsDescriptor, nsDataset );

  TDmbase = class(TDataModule)

    FDPhysMySQLDriverLink1: TFDPhysMySQLDriverLink;
    DBMySQL: TFDConnection;

    procedure DataModuleCreate(Sender: TObject);

  private
    // credencias database
    BaseDados, PORTA,  USER, PASS, SERVER, Bibliotecadll  :string;

    // Acesso database
    function CarregarConfigDBMySQL:boolean;

  public
    function conectarbse:boolean;
    function Desconectarbse:boolean;
  end;

var
  Dmbase: TDmbase;

implementation


{$R *.dfm}


function TDmbase.CarregarConfigDBMySQL:boolean;
var
   dir:string;
begin
  Result := False;
  try
    if ( BaseDados = EmptyStr ) or
       ( server = EmptyStr ) or
       ( Porta = EmptyStr ) or
       ( USER = EmptyStr ) or
       ( PASS = EmptyStr )
    then
    begin
       ShowMessage('Confira as configuração de acessso ao banco de dados parametros: Databasename, Porta, Ip do server, Username e Password ' );
       Result:=false;
       exit;
    end;

    if DBMySQL.Connected = False then
    begin
      DBMySQL.DriverName := 'MySQL';

      with DBMySQL.Params do
      begin
        Clear;
        Add('DriverID=MySQL');
        Add('Server='     + server);
        Add('Port='       + Porta);
        Add('Database='   + BaseDados);
        Add('User_Name='  + USER );
        Add('Password='   + PASS);
      end;

      dir:=ExtractFilePath(ParamStr(0));

      if Bibliotecadll=EmptyStr then
      begin
         if FileExists(dir+'libmysql.dll') then
            FDPhysMySQLDriverLink1.VendorLib := dir+'libmysql.dll'
         else
         begin
           ShowMessage('Atenção: precisa disponibilizar a libmysql.dll na pasta do sistema, ou informar o diretório de sua localização!' );
           result:=false;
         end;
      end
      else
          FDPhysMySQLDriverLink1.VendorLib := Bibliotecadll;

      FDPhysMySQLDriverLink1.DriverID := 'MySQL';
      DBMySQL.Connected := True;
    end;

    Result := DBMySQL.Connected;

  except
    on E: Exception do
    begin
      result:=false;
      raise Exception.Create('Error Message '+ e.Message);
    end;
  end;

end;

procedure TDmbase.DataModuleCreate(Sender: TObject);
begin

   {
   BaseDados  := ReadParametro(tpString, 'DataBase', 'Databasename','' );
   PORTA      := ReadParametro(tpString, 'DataBase', 'Porta','' );
   USER       := ReadParametro(tpString, 'DataBase', 'User','' );
   PASS       := ReadParametro(tpString, 'DataBase', 'Pass','' );
   SERVER     := ReadParametro(tpString, 'DataBase', 'Server','' );
   Bibliotecadll := ReadParametro(tpString, 'DataBase', 'BibliotecaDll','' );

   conectarbse;

    }
end;


function TDmbase.Desconectarbse: boolean;
begin
  DBMySQL.Connected := false;
end;


function TDmbase.conectarbse: boolean;
begin
   try
     if DBMySQL.Connected = false
     then
       CarregarConfigDBMySQL
     else
       CarregarConfigDBMySQL;

   finally
     Result:=DBMySQL.Connected;
   end;
end;




end.

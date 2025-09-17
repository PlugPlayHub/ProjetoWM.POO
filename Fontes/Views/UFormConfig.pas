unit UFormConfig;

interface

uses
   Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls,
  Datasnap.DBClient, Data.DBXDBReaders,Data.DBXCommon,Data.DBXCDSReaders,
  MidasLib, Vcl.ComCtrls,  Vcl.Menus, Vcl.DBCtrls, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, Data.DB, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client,
  FireDAC.Phys.MySQLDef, FireDAC.UI.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.MySQL,
  FireDAC.VCLUI.Wait,
  System.IniFiles;

type
  TFormConfig = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    ButtonSalvar: TPanel;
    SPBSalvar: TSpeedButton;
    FDPhysMySQLDriverLink1: TFDPhysMySQLDriverLink;
    DBMySQL: TFDConnection;
    PnTestarConection: TPanel;
    SpeedButton1: TSpeedButton;
    edtBaseDados: TEdit;
    edtServer: TEdit;
    EDTPORTA: TEdit;
    EDTUSER: TEdit;
    EDTPASS: TEdit;
    procedure FormCreate(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure SPBSalvarClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormConfig: TFormConfig;

implementation

{$R *.dfm}


procedure TFormConfig.FormCreate(Sender: TObject);
var
  IniFile: TIniFile;
begin
  try
    IniFile := TIniFile.Create(ExtractFilePath(ParamStr(0)) + 'config.ini');
    EDtBaseDados.Text  := IniFile.ReadString ('DataBase', 'Databasename', '');
    EDtSERVER.Text     := IniFile.ReadString ('DataBase', 'Server', '');
    EDtPORTA.Text      := IniFile.ReadString ('DataBase', 'Porta', '');
    EDtUSER.Text       := IniFile.ReadString ('DataBase', 'User', '');
    EDtPASS.Text       := IniFile.ReadString ('DataBase', 'Pass', '');
  finally
    IniFile.Free;
  end;

end;

procedure TFormConfig.SPBSalvarClick(Sender: TObject);
var
  IniFile: TIniFile;
begin
    if ( trim( edtBaseDados.Text ) = EmptyStr ) or
       ( trim( Edtserver.Text ) = EmptyStr ) or
       ( trim( EdtPorta.Text ) = EmptyStr ) or
       ( trim( EdtUSER.Text ) = EmptyStr ) or
       ( trim( EdtPASS.Text ) = EmptyStr )
    then
    begin
       ShowMessage('Precisa informar os parametros: Databasename, Porta, IP do server, Username e Password' );
       exit;
    end;

    try
      IniFile := TIniFile.Create(ExtractFilePath(ParamStr(0)) + 'config.ini');
      IniFile.WriteString('DataBase', 'Databasename', Trim( EDtBaseDados.Text ) );
      IniFile.WriteString('DataBase', 'Server', Trim( EDtSERVER.Text ));
      IniFile.WriteString('DataBase', 'Porta', Trim( EDtPORTA.Text ));
      IniFile.WriteString('DataBase', 'User', Trim( EDtUSER.Text ));
      IniFile.WriteString('DataBase', 'Pass', Trim( EDtPASS.Text ));
    finally
      IniFile.Free;
    end;
    close;

end;

procedure TFormConfig.SpeedButton1Click(Sender: TObject);
begin
   try
      if ( trim( edtBaseDados.Text ) = '') or
         ( trim( edtServer.Text)     = '') or
         ( trim( edtPorta.Text )     = '') or
         ( trim( edtUser.Text )      = '') or
         ( trim( edtPass.Text )      = '') then
      begin
        ShowMessage('Preencha todos os parâmetros: Database, Porta, IP do servidor, Usuário e Senha.');
        Exit;
      end;

      DBMySQL.Params.Clear;
      DBMySQL.Params.Add('DriverID=MySQL');
      DBMySQL.Params.Add('Server='    + Trim ( edtServer.Text ) );
      DBMySQL.Params.Add('Port='      + Trim ( edtPorta.Text ) );
      DBMySQL.Params.Add('Database='  + Trim ( edtBaseDados.Text ) );
      DBMySQL.Params.Add('User_Name=' + Trim ( edtUser.Text  ) );
      DBMySQL.Params.Add('Password='  + Trim ( edtPass.Text ) );

      FDPhysMySQLDriverLink1.DriverID  := 'MySQL';
      FDPhysMySQLDriverLink1.VendorLib := ExtractFilePath(ParamStr(0)) + 'libmysql.dll';

      DBMySQL.Connected := True;
      ShowMessage('Banco de dados conectado com sucesso!');

      // Se o objetivo era só testar, desconectar:
      DBMySQL.Connected := False;

   except
     on e:exception do
     begin
       ShowMessage('Não foi possível conectar ao banco de dados!' + E.Message);
     end;
   end;

end;


end.

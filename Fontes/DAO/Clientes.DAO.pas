unit Clientes.DAO;

interface

uses
  FireDAC.Comp.Client, System.SysUtils, System.Generics.Collections,
  Clientes.Model, UConectionpas;

type
  TClienteDAO = class
  public
    class function Listar_cliente(IDcliente:integer): TCliente;
  end;

implementation



class function TClienteDAO.Listar_cliente(  IDcliente: integer): TCliente;
var
  Conn: TFDConnection;
  Qry: TFDQuery;
  Cliente: TCliente;
begin
  Conn := GetConnectionMYSQL;
  Qry := TFDQuery.Create(nil);
  try
    Qry.Connection := Conn;
    Qry.SQL.Text := 'SELECT cliente, nome, cidade, uf FROM clientes where cliente=:cliente';
    Qry.ParamByName('cliente').AsInteger      := IDcliente;
    Qry.Open;


    if not Qry.IsEmpty then
    begin
      Result := TCliente.Create;
      Result.Cliente := Qry.FieldByName('cliente').AsInteger;
      Result.Nome := Qry.FieldByName('nome').AsString;
      Result.Cidade := Qry.FieldByName('cidade').AsString;
      Result.UF := Qry.FieldByName('uf').AsString;
    end
    else
      raise Exception.Create('Cliente não localizado '+ inttostr( IDcliente) );


  finally
    Qry.Free;
    Conn.Free;
  end;
end;

end.


unit Produto.DAO;

interface

uses
  FireDAC.Comp.Client, Firedac.Stan.Def, System.SysUtils, System.Generics.Collections,
  Produtos.Model, UConectionpas;

type
  TProdutoDAO = class
  public
    class function BuscarProduto( codigo : string): TProduto;
  end;

implementation



class function TProdutoDAO.BuscarProduto( codigo : string): TProduto;
var
  Conn: TFDConnection;
  Qry: TFDQuery;
begin
  Result := nil;
  Conn := GetConnectionMYSQL;
  Qry := TFDQuery.Create(nil);
  try
    Qry.Connection := Conn;
    Qry.SQL.Text := 'SELECT Produto, codigo, descricao, preco_venda FROM produtos WHERE codigo = :codigo';
    Qry.ParamByName('codigo').AsString := codigo;
    Qry.Open;

    if not Qry.IsEmpty then
    begin
      Result := TProduto.Create;
      Result.Produto := Qry.FieldByName('Produto').AsInteger;
      Result.codigo := Qry.FieldByName('codigo').asstring;
      Result.Descricao := Qry.FieldByName('descricao').AsString;
      Result.PrecoVenda := Qry.FieldByName('preco_venda').AsCurrency;
    end
    else
      raise Exception.Create('Produto não localizado :'+codigo );

  finally
    Qry.Free;
    Conn.Free;
  end;
end;

end.


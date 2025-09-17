unit Pedido.DAO;

interface

uses
  FireDAC.Comp.Client, FireDAC.DApt, Firedac.Stan.Def,  System.SysUtils,
  Pedido_venda.Model,  UConectionpas ;

type
  TPedidoDAO = class
  public
    class function BuscaPedido(Pedidov: Integer): TPedido_venda;
    class procedure Gravar(Pedido: TPedido_venda);
    class procedure CancelarPedido(Pedidov: Integer);
  end;

implementation
uses
  produto.Dao;


class procedure TPedidoDAO.Gravar(Pedido: TPedido_venda);
var
  Conn: TFDConnection;
  Qry: TFDQuery;
  Item: TProduto_pedidov;
  PK_pedidov: Integer;
begin
  Conn := GetConnectionMYSQL;
  Qry := TFDQuery.Create(nil);
  try
    Qry.Connection := Conn;
    Conn.Connected := True;
    Conn.StartTransaction;

    if Pedido.Pedidov = -1 then
    begin
      // Inserir pedido novo
      Qry.SQL.Text := 'INSERT INTO pedido_venda (data_emissao, cliente, valor_total, total_qtde) ' +
                      'VALUES (:data_emissao, :cliente, :valor_total, :total_qtde)';
      Qry.ParamByName('data_emissao').AsDate    := Pedido.DataEmissao;
      Qry.ParamByName('cliente').AsInteger      := Pedido.Cliente;
      Qry.ParamByName('valor_total').AsCurrency := Pedido.ValorTotal;
      Qry.ParamByName('total_qtde').AsInteger   := Pedido.TotalQtde;
      Qry.ExecSQL;

      // pega o último ID
      Qry.SQL.Text := 'SELECT LAST_INSERT_ID() AS pedidov';
      Qry.Open;
      PK_pedidov := Qry.FieldByName('pedidov').AsInteger;
    end
    else
    begin
      // Atualizar cabeçalho do pedido existente
      PK_pedidov := Pedido.Pedidov;
      Qry.SQL.Text := 'UPDATE pedido_venda SET data_emissao=:data_emissao, cliente=:cliente, ' +
                      'valor_total=:valor_total, total_qtde=:total_qtde WHERE pedidov=:pedidov';
      Qry.ParamByName('data_emissao').AsDate    := Pedido.DataEmissao;
      Qry.ParamByName('cliente').AsInteger      := Pedido.Cliente;
      Qry.ParamByName('valor_total').AsCurrency := Pedido.ValorTotal;
      Qry.ParamByName('total_qtde').AsInteger   := Pedido.TotalQtde;
      Qry.ParamByName('pedidov').AsInteger      := PK_pedidov;
      Qry.ExecSQL;

      // Apagar produtos antigos do pedido
      Qry.SQL.Text := 'DELETE FROM produto_pedidov WHERE pedidov=:pedidov';
      Qry.ParamByName('pedidov').AsInteger := PK_pedidov;
      Qry.ExecSQL;
    end;

    // Inserir produtos do pedido
    for Item in Pedido.Itens do
    begin
      if (Item.Qtde > 0) and (Item.ValorUnitario > 0) then
      begin
        Qry.SQL.Text := 'INSERT INTO produto_pedidov (pedidov, produto, qtde, valor_unit, valor_total) ' +
                        'VALUES (:pedidov, :produto, :qtde, :valor_unit, :valor_total)';
        Qry.ParamByName('pedidov').AsInteger     := PK_pedidov;
        Qry.ParamByName('produto').AsInteger     := Item.Produto;
        Qry.ParamByName('qtde').AsInteger        := Item.Qtde;
        Qry.ParamByName('valor_unit').AsCurrency := Item.ValorUnitario;
        Qry.ParamByName('valor_total').AsCurrency:= Item.ValorTotal;
        Qry.ExecSQL;
      end;
    end;

    Conn.Commit;

  except
    on E: Exception do
    begin
      if Conn.InTransaction then
        Conn.Rollback;
      raise Exception.Create('Erro gravando pedido: ' + E.Message);
    end;
  end;

  Qry.Free;
  Conn.Free;

end;


class procedure TPedidoDAO.CancelarPedido(Pedidov: Integer);
var
  Conn: TFDConnection;
  Qry: TFDQuery;
begin
  Conn := GetConnectionMYSQL;
  Qry := TFDQuery.Create(nil);
  try
    Conn.StartTransaction;
    Qry.Connection  := Conn;

    Qry.SQL.Text := 'DELETE FROM produto_pedidov WHERE pedidov = :pedidov';
    Qry.ParamByName('pedidov').AsInteger := Pedidov;
    Qry.ExecSQL;

    Qry.SQL.Text := 'DELETE FROM pedido_venda WHERE pedidov = :pedidov';
    Qry.ParamByName('pedidov').AsInteger := Pedidov;
    Qry.ExecSQL;

    Conn.Commit;
  except
    on E: Exception do
    begin
      Conn.Rollback;
      raise;
    end;
  end;
  Qry.Free;
  Conn.Free;
end;



class function TPedidoDAO.BuscaPedido(Pedidov: Integer): TPedido_venda;
var
  Conn: TFDConnection;
  Qry: TFDQuery;
  Pedido: TPedido_venda;
  Item: TProduto_pedidov;
begin
  Conn := GetConnectionMYSQL;
  Qry := TFDQuery.Create(nil);

  try
    try
      Qry.Connection := Conn;
      Qry.SQL.Text := 'Select pv.pedidov, pv.data_emissao, pv.cliente, pv.valor_total, pv.total_qtde, cl.nome '+
                      '  FROM pedido_venda pv '+
                      ' inner join clientes cl on cl.cliente=pv.cliente '+
                      ' WHERE pv.pedidov = :pedidov';
      Qry.ParamByName('pedidov').AsInteger := Pedidov;
      Qry.Open;

      if Qry.IsEmpty then
        Exit(nil);

      Pedido := TPedido_venda.Create;
      Pedido.Pedidov      := Qry.FieldByName('pedidov').AsInteger;
      Pedido.DataEmissao  := Qry.FieldByName('data_emissao').AsDateTime;
      Pedido.Cliente      := Qry.FieldByName('cliente').AsInteger;
      Pedido.TotalQtde    := Qry.FieldByName('total_qtde').AsInteger;
      Pedido.ValorTotal   := Qry.FieldByName('valor_total').AsCurrency;
      Pedido.NomeCliente  := Qry.FieldByName('nome').asstring;

      // Carregar itens
      Qry.Close;
      Qry.SQL.Text := 'Select  ppv.produto, ppv.valor_unit, ppv.qtde, ppv.valor_total, p.codigo, p.descricao '+
                      ' FROM produto_pedidov ppv '+
                      ' inner join produtos p on p.produto=ppv.produto '+
                      '  WHERE ppv. pedidov = :pedidov';
      Qry.ParamByName('pedidov').AsInteger := Pedidov;
      Qry.Open;

      while not Qry.Eof do
      begin
        Item := TProduto_pedidov.Create;
        Item.Produto        := Qry.FieldByName('produto').AsInteger;
        Item.Qtde           := Qry.FieldByName('qtde').AsInteger;
        Item.ValorUnitario  := Qry.FieldByName('valor_unit').AsCurrency;
        Item.ValorTotal     := Qry.FieldByName('valor_total').AsCurrency;
        Item.DescricaoProduto  := Qry.FieldByName('descricao').AsString;
        Item.CodigoProduto     := Qry.FieldByName('codigo').AsString;

        Pedido.Itens.Add(Item);
        Qry.Next;
      end;

      Result := Pedido;

    except
      raise Exception.Create('Error carregando pedido : '+IntToStr( Pedidov) );
    end;

  finally
    Qry.Free;
    Conn.Free;
  end;



end;

end.


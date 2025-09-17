unit Pedido_venda.Model;

interface

uses
  System.Generics.Collections, System.SysUtils;

type
  TProduto_pedidov = class
  private
    FProduto: Integer;
    FDescricaoProduto: string;
    FQtde: Integer;
    FValorUnitario: Currency;
    FValorTotal: Currency;
    FCodigoProduto: string;
  public
    property Produto: Integer read FProduto write FProduto;
    property DescricaoProduto: string read FDescricaoProduto write FDescricaoProduto;
    property CodigoProduto: string read FCodigoProduto write FCodigoProduto;
    property Qtde: Integer read FQtde write FQtde;
    property ValorUnitario: Currency read FValorUnitario write FValorUnitario;
    property ValorTotal: Currency read FValorTotal write FValorTotal;
  end;


  TPedido_venda = class
  private
    FPedidov: Integer;
    FDataEmissao: TDate;
    FCliente: Integer;
    FNomeCliente: string;
    FValorTotal: Currency;
    FTotalQtde: Integer;
    FItens: TObjectList<TProduto_pedidov>;

  public
    constructor Create;
    destructor Destroy; override;

    property Pedidov: Integer read FPedidov write FPedidov;
    property DataEmissao: TDate read FDataEmissao write FDataEmissao;

    property Cliente: Integer read FCliente write FCliente;
    property NomeCliente:string read FNomeCliente write FNomeCliente;

    property ValorTotal: Currency read FValorTotal write FValorTotal;
    property TotalQtde: Integer read FTotalQtde write FTotalQtde;
    property Itens: TObjectList<TProduto_pedidov> read FItens;
  end;

implementation



{ TPedido_venda }

constructor TPedido_venda.Create;
begin
  FItens := TObjectList<TProduto_pedidov>.Create(True);
  FPedidov := -1;
end;

destructor TPedido_venda.Destroy;
begin
  FItens.Free;
  inherited;
end;



end.


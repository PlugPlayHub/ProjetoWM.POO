unit Produtos.Model;

interface

type
  TProduto = class
  private
    FProduto: Integer;
    Fcodigo: string;
    FDescricao: string;
    FPrecoVenda: Currency;
  public
    property Produto: Integer read FProduto write FProduto;
    property Codigo :string read Fcodigo write Fcodigo;
    property Descricao: string read FDescricao write FDescricao;
    property PrecoVenda: Currency read FPrecoVenda write FPrecoVenda;
  end;

implementation

end.


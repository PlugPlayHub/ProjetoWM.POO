unit Clientes.Model;

interface

type
  TCliente = class

  private
    Fcliente: integer;
    FNome: string;
    FCidade: string;
    FUF: string;

  public
    property Cliente:integer read Fcliente write Fcliente;
    property Nome: string read FNome write FNome;
    property Cidade: string read FCidade write FCidade;
    property UF: string read FUF write FUF;
  end;

implementation

end.


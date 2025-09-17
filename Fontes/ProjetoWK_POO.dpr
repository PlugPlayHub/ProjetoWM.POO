program ProjetoWK_POO;

uses
  Vcl.Forms,
  Vcl.Themes,
  Vcl.Styles,
  UConectionpas in 'DataBase\UConectionpas.pas',
  Clientes.Model in 'MODELS\Clientes.Model.pas',
  Produtos.Model in 'MODELS\Produtos.Model.pas',
  UFormAddProdutoPed in 'Views\UFormAddProdutoPed.pas' {FormAddProdutoPed},
  UFormConfig in 'Views\UFormConfig.pas' {FormConfig},
  UFormEditarItemPedido in 'Views\UFormEditarItemPedido.pas' {FormEditarItemPedido},
  UFormPrincipal in 'Views\UFormPrincipal.pas' {FormPrincipal},
  Pedido_venda.Model in 'Models\Pedido_venda.Model.Pas',
  Clientes.DAO in 'DAO\Clientes.DAO.pas',
  Pedido.DAO in 'DAO\Pedido.DAO.pas',
  Produto.DAO in 'DAO\Produto.DAO.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFormPrincipal, FormPrincipal);
  Application.Run;

end.

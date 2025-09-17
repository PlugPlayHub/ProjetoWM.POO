unit UFormAddProdutoPed;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Data.DB,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, Vcl.Grids, Vcl.DBGrids,
  System.ImageList, Vcl.ImgList, Vcl.Buttons, Vcl.ExtCtrls,

  Vcl.Mask, Vcl.DBCtrls, Pedido_venda.Model, Produto.DAO, Produtos.Model;

type
  TFormAddProdutoPed = class(TForm)
    DsItemPed: TDataSource;
    Label1: TLabel;
    Label_qtde: TLabel;
    Label_valor: TLabel;
    Label_total: TLabel;
    EditCodigo: TEdit;
    BtnAdd: TBitBtn;
    BtCancelarItem: TBitBtn;
    EdtQtde: TEdit;
    EdtValorUnit: TEdit;
    EdtValorTotal: TEdit;
    EdtDescproduto: TEdit;
    procedure dbgridprodutosKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure BtnAddClick(Sender: TObject);
    procedure EditCodigoKeyPress(Sender: TObject; var Key: Char);
    procedure BtCancelarItemClick(Sender: TObject);
    procedure EdtValorUnitExit(Sender: TObject);
    procedure EdtValorUnitKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure EdtQtdeKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
    Tprod:TProduto;
    procedure BuscarProdutoDigitado;
    procedure CalcValorTotal;
    procedure Edicao_ativa ( ativo : Boolean);

  public
    { Public declarations }
    Pedido: TPedido_venda;
  end;

var
  FormAddProdutoPed: TFormAddProdutoPed;

implementation

{$R *.dfm}



procedure TFormAddProdutoPed.Edicao_ativa( ativo : Boolean );
begin
  if ativo then
  begin
     EditCodigo.Enabled:=false;
     EdtDescproduto.Enabled:=true;
     EdtQtde.Enabled:=true;
     EdtValorUnit.Enabled:=true;
     EdtValorTotal.Enabled:=true;
     BtnAdd.Enabled:=true;
     BtCancelarItem.Enabled:=true;
     EdtQtde.SetFocus;
  end
  else
  begin
     EditCodigo.Text:=EmptyStr;
     EdtDescproduto.Text:=EmptyStr;
     EdtValorUnit.Text:=EmptyStr;
     EdtValorTotal.Text:=EmptyStr;
     EdtQtde.Text:='1';

     EdtDescproduto.Enabled:=false;
     EdtQtde.Enabled:=false;
     EdtValorUnit.Enabled:=false;
     EdtValorTotal.Enabled:=false;
     BtnAdd.Enabled:=false;
     BtCancelarItem.Enabled:=false;

     EditCodigo.Enabled:=true;
     EditCodigo.SetFocus;
  end;
end;

procedure TFormAddProdutoPed.EditCodigoKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
    BuscarProdutoDigitado;

end;

procedure TFormAddProdutoPed.EdtQtdeKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (key = VK_RETURN) then
  begin
    if strtoint( EdtQtde.Text) <0 then EdtQtde.Text:='1';
    CalcValorTotal;
    EdtValorUnit.SetFocus;
  end;
end;

procedure TFormAddProdutoPed.EdtValorUnitExit(Sender: TObject);
var
  ValorUnit: Currency;
begin
  ValorUnit:=StrToCurr(EdtValorUnit.Text);
  EdtValorUnit.Text := FormatFloat('0.00', ValorUnit);
  CalcValorTotal;
  BtnAdd.SetFocus;
end;

procedure TFormAddProdutoPed.EdtValorUnitKeyDown(Sender: TObject; var Key: Word;  Shift: TShiftState);
begin
  if (Key = VK_RETURN)  then
  begin
     CalcValorTotal;
     BtnAdd.SetFocus;
  end;
end;



procedure TFormAddProdutoPed.BtCancelarItemClick(Sender: TObject);
begin
  EditCodigo.Text:=EmptyStr;
  Edicao_ativa(false);
end;

procedure TFormAddProdutoPed.BtnAddClick(Sender: TObject);
var
  Item: TProduto_pedidov;
  Qtde: Integer;
  ValorUnit, ValorTotal: Double;
begin
  // Lê valores do form
  Qtde := StrToIntDef(EdtQtde.Text, 0);
  ValorUnit := StrToFloatDef(EdtValorUnit.Text, 0);
  ValorTotal := StrToFloatDef(EdtValorTotal.Text, 0);

  if (Qtde <= 0) then
  begin
    ShowMessage('Informe uma quantidade válida.');
    Exit;
  end;

  if (ValorUnit <= 0) then
  begin
    ShowMessage('Informe um valor unitário válido.');
    Exit;
  end;

  // Cria o item do pedido
  Item := TProduto_pedidov.Create;
  Item.Produto := tprod.Produto;
  Item.DescricaoProduto := tprod.Descricao;
  Item.Qtde := Qtde;
  Item.ValorUnitario := ValorUnit;
  Item.ValorTotal := ValorTotal;

  // Adiciona ao pedido
  Pedido.Itens.Add(Item);

  // Atualiza o Grid
  with TFDMemTable(DsItemPed.DataSet) do
  begin
    Append;
    FieldByName('produto').AsInteger := Item.Produto;
    FieldByName('codigo').AsString := tprod.Codigo;
    FieldByName('descricao').AsString := Item.DescricaoProduto;
    FieldByName('qtde').AsInteger := Item.Qtde;
    FieldByName('valor_unit').AsFloat := Item.ValorUnitario;
    FieldByName('valor_total').AsFloat := Item.ValorTotal;
    Post;
  end;

  Edicao_ativa(False);

end;

procedure TFormAddProdutoPed.BuscarProdutoDigitado;
begin
  try
     if EditCodigo.Text<>EmptyStr then
       Tprod := TProdutoDAO.BuscarProduto( EditCodigo.Text ) ;

     if Assigned( tprod) then
     begin
       Edicao_ativa(true);
       EdtValorUnit.Text    := FormatFloat('0.00',tProd.PrecoVenda);
       EdtValorTotal.Text   := FormatFloat('0.00',tProd.PrecoVenda);
       EdtDescproduto.text  := tprod.Descricao;
     end;

  finally

  end;
  

end;

procedure TFormAddProdutoPed.CalcValorTotal;
var
  ValorUnit, Total: Currency;
begin
  ValorUnit:=StrToCurr(EdtValorUnit.Text);
  Total := ValorUnit * strtoint( EdtQtde.text );
  EdtValorTotal.Text := FormatFloat('0.00',Total);
end;

procedure TFormAddProdutoPed.dbgridprodutosKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  // Bloqueia tecla Insert
  if Key = VK_INSERT then
    Key := 0;


end;

end.

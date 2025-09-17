unit UFormPrincipal;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.Buttons, Vcl.StdCtrls,
  Vcl.ExtCtrls,

  System.TypInfo, Vcl.Imaging.pngimage, Vcl.Mask, Vcl.DBCtrls, Data.DB,
  Vcl.Grids, Vcl.DBGrids, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Comp.DataSet, FireDAC.Comp.Client,

  Pedido_venda.Model , Pedido.DAO, Produto.DAO ;

type
  TtipoCadastro = ( Cliente, Pedido, Produto);

  TFormPrincipal = class(TForm)
    PanelCentral: TPanel;
    PanelTopBTN: TPanel;
    Label11: TLabel;
    Labelmenu: TLabel;
    SpeedButton1: TSpeedButton;
    Image1: TImage;
    Panel2: TPanel;
    Panel4: TPanel;
    Label1: TLabel;
    Label5: TLabel;
    EditCodigoCliente: TEdit;
    PanelCarregarPedido: TPanel;
    SPBCarregarPedido: TSpeedButton;
    PanelCancelarPedido: TPanel;
    SPBCancelarPedido: TSpeedButton;
    Panel7: TPanel;
    PanelGridProdutos: TPanel;
    Panel9: TPanel;
    SpbAddproduto: TSpeedButton;
    SpbDeleteproduto: TSpeedButton;
    Panel10: TPanel;
    dbgridprodutos: TDBGrid;
    Panel11: TPanel;
    Label4: TLabel;
    Label2: TLabel;
    Label6: TLabel;
    DBEdit2: TDBEdit;
    DBEdit1: TDBEdit;
    Panel12: TPanel;
    Label3: TLabel;
    DtEmissao: TDateTimePicker;
    Panel5: TPanel;
    Panel8: TPanel;
    Panel6: TPanel;
    PanelSalvar: TPanel;
    SPBSalvar: TSpeedButton;
    PanelEdicaoPed: TPanel;
    SPBCancelaEdicao: TSpeedButton;
    FD_Grid_produto: TFDMemTable;
    FD_Grid_produtoproduto: TIntegerField;
    FD_Grid_produtodescricao: TStringField;
    FD_Grid_produtocodigo: TStringField;
    FD_Grid_produtovalor_unit: TFloatField;
    FD_Grid_produtovalor_total: TFloatField;
    FD_Grid_produtoqtde: TIntegerField;
    DsGrid_produto: TDataSource;
    FDMemTablePedido: TFDMemTable;
    FDMemTablePedidopedidov: TIntegerField;
    IntegerField1: TIntegerField;
    FDMemTablePedidodata_emissao: TSQLTimeStampField;
    FDMemTablePedidovalor_total: TFloatField;
    FDMemTablePedidototal_qtde: TIntegerField;
    DsPedido: TDataSource;
    edtNome: TEdit;
    Label7: TLabel;
    procedure SpeedButton1Click(Sender: TObject);
    procedure EditCodigoClienteChange(Sender: TObject);
    procedure EditCodigoClienteKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure SPBCancelaEdicaoClick(Sender: TObject);
    procedure SPBCarregarPedidoClick(Sender: TObject);
    procedure SPBCancelarPedidoClick(Sender: TObject);
    procedure SpbAddprodutoClick(Sender: TObject);
    procedure SpbDeleteprodutoClick(Sender: TObject);
    procedure dbgridprodutosKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure dbgridprodutosKeyPress(Sender: TObject; var Key: Char);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FD_Grid_produtoAfterDelete(DataSet: TDataSet);
    procedure FD_Grid_produtoAfterPost(DataSet: TDataSet);
    procedure SPBSalvarClick(Sender: TObject);

  private
    { Private declarations }

    idCliente:integer;
    TPedido: TPedido_venda;


    procedure EdicaoPedido( Ativo : Boolean ) ;
    procedure BuscarCliente( codigo :string );

    Procedure CalcValores;
    Function SalvarPedido:Boolean;
    procedure EditarItem;


  public
    { Public declarations }
  end;

var
  FormPrincipal: TFormPrincipal;

implementation

{$R *.dfm}

uses UFormConfig, UFormEditarItemPedido, Clientes.Model, Clientes.DAO,  UFormAddProdutoPed;

{ TFormPrincipal }



procedure TFormPrincipal.BuscarCliente(codigo: string);
var
  Cliente: TCliente;
begin
  if Length (codigo)>0 then
  begin

    Cliente := TClienteDAO.Listar_cliente( StrToInt( codigo ) );

    try
      if Assigned(Cliente) then
      begin
        edtNome.Text := Cliente.Nome;
        idCliente:=  Cliente.Cliente;
        EdicaoPedido(true);
      end
      else
        EditCodigoCliente.SetFocus;

    finally
      Cliente.Free;
    end;

  end;

end;

procedure TFormPrincipal.CalcValores;
var
 ValorTotal : Double;
 QtdeTotal : integer;
 id_recno:integer;
begin
    ValorTotal:=0;
    QtdeTotal:=0;

    id_recno:=FD_Grid_produto.RecNo;

    FD_Grid_produto.DisableControls;
    FD_Grid_produto.first;

    while not FD_Grid_produto.eof do
    begin
      QtdeTotal:= QtdeTotal + FD_Grid_produto.FieldByName('qtde').AsInteger;
      ValorTotal:= ValorTotal + FD_Grid_produto.FieldByName('valor_total').AsFloat;

      FD_Grid_produto.next;
    end;

    FD_Grid_produto.first;

    FDMemTablePedido.Edit;
    FDMemTablePedido.FieldByName('total_qtde').AsInteger  :=  QtdeTotal ;
    FDMemTablePedido.FieldByName('valor_total').AsFloat    :=  ValorTotal;
    FDMemTablePedido.post;

    FD_Grid_produto.EnableControls;
    FD_Grid_produto.RecNo:=id_recno;

end;

procedure TFormPrincipal.dbgridprodutosKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
 Indice:integer;
begin
  if Key = VK_DELETE then
  begin
    Indice := FD_Grid_produto.RecNo - 1;
    if (Indice >= 0) and (Indice < TPedido.Itens.Count) then
      TPedido.Itens.Delete(Indice);
    FD_Grid_produto.Delete;
    Key := 0;
  end;
end;

procedure TFormPrincipal.dbgridprodutosKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
     EditarItem;
end;

procedure TFormPrincipal.EdicaoPedido(Ativo: Boolean);
begin
  if ativo  then
  begin
     PanelGridProdutos.visible:=true;
     EditCodigoCliente.enabled:=false;
     PanelEdicaoPed.Visible:=true;
     dbgridprodutos.SetFocus;
     PanelCarregarPedido.Visible:=false;
     PanelCancelarPedido.Visible:=false;
  end
  else
  begin
     PanelGridProdutos.visible:=false;
     EditCodigoCliente.enabled:=true;
     PanelEdicaoPed.Visible:=false;
     PanelCarregarPedido.Visible:=true;
     PanelCancelarPedido.Visible:=true;
  end;

end;

procedure TFormPrincipal.EditarItem;
var
  t : TFormEditarItemPedido;
  ItemSelecionado: TProduto_pedidov;
begin

  if FD_Grid_produto.RecordCount = 0 then
    Exit;

  ItemSelecionado := TPedido.Itens[FD_Grid_produto.RecNo - 1];

  t := TFormEditarItemPedido.Create(nil);
  try
    t.DsEditarItem.DataSet := FD_Grid_produto;
    t.Item := ItemSelecionado;
    t.AtualizarCampos;
    t.ShowModal;
  finally
    FreeAndNil(t);
  end;


end;

procedure TFormPrincipal.EditCodigoClienteChange(Sender: TObject);
begin
  if Length( trim( EditCodigoCliente.Text )) >0 then
  begin
    PanelCarregarPedido.Visible:=false;
    PanelCancelarPedido.Visible:=false;
  end
  else
  begin
    PanelCarregarPedido.Visible:=true;
    PanelCancelarPedido.Visible:=true;
  end;
end;

procedure TFormPrincipal.EditCodigoClienteKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if (Key = VK_RETURN)  then
  begin
    DtEmissao.Date := Date;
    BuscarCliente( Editcodigocliente.text );
    Key := 0;
  end;
end;

procedure TFormPrincipal.FD_Grid_produtoAfterDelete(DataSet: TDataSet);
begin
  CalcValores;
end;

procedure TFormPrincipal.FD_Grid_produtoAfterPost(DataSet: TDataSet);
begin
  CalcValores;
end;

procedure TFormPrincipal.FormCreate(Sender: TObject);
begin
  FD_Grid_produto.CreateDataSet;
  FDMemTablePedido.CreateDataSet;
  TPedido := TPedido_venda.Create;
end;

procedure TFormPrincipal.FormDestroy(Sender: TObject);
begin
 TPedido.Free;
end;

function TFormPrincipal.SalvarPedido: Boolean;
begin
   // Verifica se há produtos
  if FD_Grid_produto.RecordCount = 0 then
  begin
    ShowMessage('Precisa informar os produtos!');
    Exit;
  end;

  try
    TPedido.ValorTotal := 0;
    TPedido.TotalQtde  := 0;
    TPedido.Cliente := idCliente;
    TPedido.DataEmissao:=  DtEmissao.Date;

    for var Item in TPedido.Itens do
    begin
      TPedido.ValorTotal := TPedido.ValorTotal + Item.ValorTotal;
      TPedido.TotalQtde  := TPedido.TotalQtde + Item.Qtde;
    end;

    // Grava no banco de dados via DAO
    TPedidoDAO.Gravar(TPedido);

    // Limpa dados após salvar
    TPedido.Itens.Clear;
    TPedido.ValorTotal := 0;
    TPedido.TotalQtde  := 0;
    TPedido.Cliente    := 0;
    TPedido.DataEmissao := Date;

    FD_Grid_produto.EmptyDataSet; // Limpa o grid

    Result := True;
  except
    Result := false ;
  end;


end;

procedure TFormPrincipal.SpbAddprodutoClick(Sender: TObject);
var
  t: TFormAddProdutoPed;
  ValorTotal:Double;
begin
  inherited;
  t := TFormAddProdutoPed.Create(nil);
  try
    t.DsItemPed.DataSet := FD_Grid_produto;
    t.Pedido := Self.TPedido;
    t.ShowModal;
  finally
    FreeAndNil(t);
  end;

end;

procedure TFormPrincipal.SPBCancelaEdicaoClick(Sender: TObject);
begin
  EdicaoPedido(false);
  EditCodigoCliente.Text:=EmptyStr;
  FD_Grid_produto.Close;
  FD_Grid_produto.open;
end;

procedure TFormPrincipal.SpbDeleteprodutoClick(Sender: TObject);
begin
  if not FD_Grid_produto.IsEmpty then
    if Application.MessageBox(pchar('Confirma a exclusão do item?'),'Aviso',MB_YESNO+MB_ICONWARNING)=ID_YES then
        FD_Grid_produto.delete;
end;

procedure TFormPrincipal.SPBSalvarClick(Sender: TObject);
begin
   if SalvarPedido then
   begin
     ShowMessage('Comando executado com sucesso!');
     EdicaoPedido( false );
     EditCodigoCliente.Text:=EmptyStr;
   end;
end;

procedure TFormPrincipal.SpeedButton1Click(Sender: TObject);
var
  t:TFormConfig;
begin
  try
    t:= TFormConfig.Create(nil);
    t.showmodal;
  finally
    FreeAndNil( t );
  end;
end;

procedure TFormPrincipal.SPBCarregarPedidoClick(Sender: TObject);
var
  StrPedido: string;
  IDPedido: Integer;
  Item: TProduto_pedidov;
begin
  try
    StrPedido := InputBox('Buscar pedido', 'Informe o número do pedido:', '');
    if StrPedido = '' then
      Exit;

    if not TryStrToInt(StrPedido, IDPedido) then
    begin
      ShowMessage('Número de pedido inválido!');
      Exit;
    end;

    FreeAndNil(TPedido); // libera pedido anterior
    TPedido := TPedidoDAO.BuscaPedido(IDPedido);

    if not Assigned(TPedido) then
    begin
      ShowMessage('Pedido não encontrado!');
      Exit;
    end;

    DtEmissao.Date := TPedido.DataEmissao;
    idCliente := TPedido.Cliente;
    edtNome.Text := TPedido.NomeCliente;

    FD_Grid_Produto.EmptyDataSet;

    for Item in TPedido.Itens do
    begin
      FD_Grid_Produto.Append;
      FD_Grid_Produto.FieldByName('produto').AsInteger := Item.Produto;
      FD_Grid_Produto.FieldByName('codigo').AsString := Item.CodigoProduto;
      FD_Grid_Produto.FieldByName('descricao').AsString := Item.DescricaoProduto;
      FD_Grid_Produto.FieldByName('qtde').AsInteger := Item.Qtde;
      FD_Grid_Produto.FieldByName('valor_unit').AsFloat := Item.ValorUnitario;
      FD_Grid_Produto.FieldByName('valor_total').AsFloat := Item.ValorTotal;
      FD_Grid_Produto.Post;
    end;

    EdicaoPedido(True);
  except
    on E: Exception do
      ShowMessage(E.Message);
  end;

end;

procedure TFormPrincipal.SPBCancelarPedidoClick(Sender: TObject);
var
 StrPedido:string;
 IDPedido: Integer;
begin
   StrPedido := InputBox('Cancelar pedido', 'Informe o número do pedido:', '');
   if StrPedido<>EmptyStr then
   begin
     if not TryStrToInt(StrPedido, IDPedido) then
     begin
        ShowMessage('Número de pedido inválido!');
        Exit;
     end;

     if Application.MessageBox(pchar('Confirma a exclusão do cadastro?'),'Aviso',MB_YESNO+MB_ICONWARNING)=ID_YES then
     begin
       TPedidoDAO.CancelarPedido(IDPedido);
       EdicaoPedido(false);
     end;
   end;



end;

end.

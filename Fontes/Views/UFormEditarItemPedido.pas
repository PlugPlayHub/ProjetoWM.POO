unit UFormEditarItemPedido;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Data.DB,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, Vcl.Mask, Vcl.ExtCtrls, Vcl.DBCtrls,
  Vcl.Buttons, Pedido_venda.Model;

type
  TFormEditarItemPedido = class(TForm)
    Label_qtde: TLabel;
    Label_valor: TLabel;
    Label_total: TLabel;
    BtnAdd: TBitBtn;
    EdtQtde: TEdit;
    EdtValorUnit: TEdit;
    EdtValorTotal: TEdit;
    DsEditarItem: TDataSource;
    procedure BtnAddClick(Sender: TObject);
    procedure EdtQtdeKeyDown(Sender: TObject; var Key: Word;      Shift: TShiftState);
    procedure EdtValorUnitKeyDown(Sender: TObject; var Key: Word;      Shift: TShiftState);
    procedure EdtValorUnitExit(Sender: TObject);
  private
    { Private declarations }
    FItem: TProduto_pedidov;
    procedure CalcValorTotal;
  public
    { Public declarations }
    property Item: TProduto_pedidov read FItem write FItem;
    procedure AtualizarCampos;
  end;

var
  FormEditarItemPedido: TFormEditarItemPedido;

implementation

{$R *.dfm}

procedure TFormEditarItemPedido.AtualizarCampos;
begin
  if Assigned(FItem) then
  begin
    EdtQtde.Text := IntToStr(FItem.Qtde);
    EdtValorUnit.Text := FormatFloat('0.00', FItem.ValorUnitario);
    EdtValorTotal.Text := FormatFloat('0.00', FItem.ValorTotal);
  end;
end;

procedure TFormEditarItemPedido.BtnAddClick(Sender: TObject);
begin
    if Assigned(FItem) then
    begin
      FItem.Qtde := StrToInt(EdtQtde.Text);
      FItem.ValorUnitario := StrToFloat(EdtValorUnit.Text);
      FItem.ValorTotal := FItem.Qtde * FItem.ValorUnitario;

      DsEditarItem.DataSet.Edit;
      DsEditarItem.DataSet.FieldByName('qtde').AsInteger := FItem.Qtde;
      DsEditarItem.DataSet.FieldByName('valor_unit').AsFloat := FItem.ValorUnitario;
      DsEditarItem.DataSet.FieldByName('valor_total').AsFloat := FItem.ValorTotal;
      DsEditarItem.DataSet.Post;

      Close;
    end;

end;

procedure TFormEditarItemPedido.CalcValorTotal;
var
  ValorUnit, Total: Currency;
begin
  ValorUnit:=StrToCurr(EdtValorUnit.Text);
  Total := ValorUnit * strtoint( EdtQtde.text );
  EdtValorTotal.Text := FormatFloat('0.00',Total);
end;


procedure TFormEditarItemPedido.EdtQtdeKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (key = VK_RETURN) then
  begin
    if strtoint( EdtQtde.Text) <0 then EdtQtde.Text:='1';
    CalcValorTotal;
    EdtValorUnit.SetFocus;
  end;
end;

procedure TFormEditarItemPedido.EdtValorUnitExit(Sender: TObject);
var
  ValorUnit: Currency;
begin
  ValorUnit:=StrToCurr(EdtValorUnit.Text);
  EdtValorUnit.Text := FormatFloat('0.00', ValorUnit);
  CalcValorTotal;
  BtnAdd.SetFocus;
end;

procedure TFormEditarItemPedido.EdtValorUnitKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if (Key = VK_RETURN)  then
  begin
     CalcValorTotal;
     BtnAdd.SetFocus;
  end;
end;

end.

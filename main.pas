unit main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, Grids, ValEdit, StrUtils, XPMan, jpeg,
  ExtCtrls, ComCtrls,
  IntervalArithmetic32and64, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, Data.DB,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  SplineVal, SplineIntervalVal, SplineCoeffs, SplineCoeffsInterval;

type
  TForm1 = class(TForm)
    XPManifest1: TXPManifest;
    ButtonSplineCoeffs: TButton;
    ButtonIntervalCoeffs: TButton;
    TabControl1: TTabControl;
    Memo1: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure ButtonSplineCoeffsClick(Sender: TObject);
    procedure ButtonIntervalCoeffsClick(Sender: TObject);

    procedure TabControl1Visibility(visible : Boolean);
    procedure TabControl2Visibility(visible : Boolean);
    procedure TabControl3Visibility(visible : Boolean);
    procedure TabControl4Visibility(visible : Boolean);

    procedure TabControl1Change(Sender: TObject);

  private
    { Private declarations }
  public
     selectedID : integer;
  end;

  function resultToString(const res : Extended) : string; overload;
  function resultToString(const res : Interval) : string; overload;

var
  Form1: TForm1;
  SplineValForm : TSplineValForm;
  SplineIntervalValForm : TSplineIntervalValForm;
  SplineCoeffsForm : TSplineCoeffsForm;
  SplineCoeffsIntervalForm : TSplineCoeffsIntervalForm;

implementation

{$R *.dfm}

type
  TIntervalArray = array of interval;

procedure naturalsplinecoeffnsInterval (n      : Integer;
                                x,f    : array of interval;
                                var a  : array of TIntervalArray;
                                var st : Integer); external 'dll.dll';

function resultToString(const res : Extended) : string;  overload;
var
    outLeft, outRight : string;
begin
    iends_to_strings (res, outLeft , outRight);
    Result := outLeft;
end;

function resultToString(const res : Interval) : string;  overload;
var
    outLeft, outRight : string;
begin
    iends_to_strings (res, outLeft , outRight);
    Result := '[' + outLeft + ',' + outRight + ']';
end;

procedure TForm1.Button1Click(Sender: TObject);
var
  n      : Integer;
  x,f    : array of Extended;
  xx     : Extended;
  var st : Integer ;
  outVal: Extended;
begin
  SetLength(x, 9);
  SetLength(f, 9);
  xx := 4;

  x[1] := 1;
  x[2] := 2;
  x[3] := 3;
  x[4] := 5;

  f[1] := 1;
  f[2] := 2;
  f[3] := 3;
  f[4] := 5;

  n := 4;

  outVal := naturalsplinevalue(n, x,f, xx, st);

  if st <> 0 then
    Memo1.Text := 'some error occured ' + IntToStr(st)
  else
    Memo1.Text := resultToString(outVal);
end;

procedure TForm1.ButtonSplineCoeffsClick(Sender: TObject);
var
  n      : Integer;
  x,f    : array of Extended;
  a  : array of TExtendedArray;
  st : Integer ;
  i,j : Integer;
begin
    n := 6;

    SetLength(x, 10);
    SetLength(f, 10);

    f[1] := 4;
    f[2] := 1;
    f[3] := 1.1;
    f[4] := 9;
    f[5] := 3;
    f[6] := 0.2;

    x[1] := 1;
    x[2] := 2;
    x[3] := 3;
    x[4] := 5;
    x[5] := 9;
    x[6] := 10;

    SetLength(a, 10);

    for i := 0 to 10 do
      SetLength(a[i], 10);

    for i := 0 to 10 do
      for j := 0 to 10 do
        a[i,j] := 0;

    naturalsplinecoeffns(n,f,x,a,st);

    if st <> 0 then
       Memo1.Text := 'some error occured ' + IntToStr(st)
    else
    begin
        Memo1.Text := '';
        for i := 0 to n do
        begin
          for j := 0 to 3 do
            Memo1.Text := Memo1.Text + ' ' + resultToString(a[j,i]);

          Memo1.Text := Memo1.Text + sLineBreak;
        end;
    end;

end;

procedure TForm1.ButtonIntervalCoeffsClick(Sender: TObject);
var
  n      : Integer;
  x,f    : array of interval;
  a  : array of TIntervalArray;
  st : Integer ;
  i,j : Integer;
begin
    n := 6;

    SetLength(x, 10);
    SetLength(f, 10);

    f[1] := 4;
    f[2] := 1;
    f[3] := 1.1;
    f[4] := 9;
    f[5] := 3;
    f[6] := 0.2;

    x[1] := 1;
    x[2] := 2;
    x[3] := 3;
    x[4] := 5;
    x[5] := 9;
    x[6] := 10;

    SetLength(a, 11);

    for i := 0 to 10 do
      SetLength(a[i], 10);

    for i := 0 to 10 do
      for j := 0 to 10 do
        a[i,j] := 0;

    naturalsplinecoeffnsInterval(n,f,x,a,st);

    if st <> 0 then
       Memo1.Text := 'some error occured ' + IntToStr(st)
    else
    begin
        Memo1.Text := '';
        for i := 0 to n do
        begin
          for j := 0 to 3 do
            Memo1.Text := Memo1.Text + ' ' + resultToString(a[j,i]);

          Memo1.Text := Memo1.Text + sLineBreak;
        end;
    end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
    Application.UpdateFormatSettings := false;

    SplineValForm := TSplineValForm.Create(TabControl1);
    SplineValForm.Parent := TabControl1;
    SplineValForm.Visible := True;

    SplineIntervalValForm := TSplineIntervalValForm.Create(TabControl1);
    SplineIntervalValForm.Parent := TabControl1;
    SplineIntervalValForm.Visible := False;

    SplineCoeffsForm := TSplineCoeffsForm.Create(TabControl1);
    SplineCoeffsForm.Parent := TabControl1;
    SplineCoeffsForm.Visible := False;

    SplineCoeffsIntervalForm := TSplineCoeffsIntervalForm.Create(TabControl1);
    SplineCoeffsIntervalForm.Parent := TabControl1;
    SplineCoeffsIntervalForm.Visible := False;

    Refresh();
end;

procedure TForm1.TabControl1Change(Sender: TObject);
begin

    Memo1.Text := IntToStr(TabControl1.TabIndex);

    case TabControl1.TabIndex of
      0 : begin
          TabControl1Visibility(True);
          TabControl2Visibility(False);
          TabControl3Visibility(False);
          TabControl4Visibility(False);
      end;
      1 : begin
          TabControl1Visibility(False);
          TabControl2Visibility(True);
          TabControl3Visibility(False);
          TabControl4Visibility(False);
      end;
      2 : begin
          TabControl1Visibility(False);
          TabControl2Visibility(False);
          TabControl3Visibility(True);
          TabControl4Visibility(False);
      end;
      3 : begin
          TabControl1Visibility(False);
          TabControl2Visibility(False);
          TabControl3Visibility(False);
          TabControl4Visibility(True);
      end;
    end;
end;

procedure TForm1.TabControl1Visibility(visible : Boolean);
begin
   SplineValForm.Visible := visible;
end;

procedure TForm1.TabControl2Visibility(visible : Boolean);
begin
   SplineIntervalValForm.Visible := visible;
end;

procedure TForm1.TabControl3Visibility(visible : Boolean);
begin
   SplineCoeffsForm.Visible := visible;
end;

procedure TForm1.TabControl4Visibility(visible : Boolean);
begin
   SplineCoeffsIntervalForm.Visible := visible;
end;

end.

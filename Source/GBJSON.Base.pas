unit GBJSON.Base;

interface

{$IFDEF WEAKPACKAGEUNIT}
  {$WEAKPACKAGEUNIT ON}
{$ENDIF}

uses
  System.SysUtils;

type
  TGBJSONBase = class(TInterfacedObject)
  protected
    FDateTimeFormat: String;
    FDateTimeLocale: string;
  public
    constructor Create; virtual;
    procedure DateTimeLocale(AValue: string);
    procedure DateTimeFormat(AValue: string);
  end;

implementation

{ TGBJSONBase }

constructor TGBJSONBase.Create;
begin
  FDateTimeFormat := EmptyStr;
end;

procedure TGBJSONBase.DateTimeFormat(AValue: string);
begin
  FDateTimeFormat := AValue;
end;

procedure TGBJSONBase.DateTimeLocale(AValue: string);
begin
  FDateTimeLocale := AValue;
end;

end.

unit GBJSON.Config;

interface

{$IFDEF WEAKPACKAGEUNIT}
  {$WEAKPACKAGEUNIT ON}
{$ENDIF}

uses
  System.SysUtils;

type
  TCaseDefinition = (cdNone, cdLower, cdUpper, cdLowerCamelCase);

  TGBJSONConfig = class
  private
    class var FInstance: TGBJSONConfig;

    FCaseDefinition: TCaseDefinition;
    FIgnoreEmptyValues: Boolean;
    FDateTimeFormat: string;
    FDateTimeLocale: string;
    constructor CreatePrivate;
  public
    constructor Create;
    class function GetInstance: TGBJSONConfig;
    class destructor UnInitialize;

    function CaseDefinition(AValue: TCaseDefinition): TGBJSONConfig; overload;
    function CaseDefinition: TCaseDefinition; overload;
    function DateTimeFormat(AValue: string): TGBJSONConfig; overload;
    function DateTimeFormat: string; overload;
    function DateTimeLocale(AValue: string): TGBJSONConfig; overload;
    function DateTimeLocale: string; overload;
    function IgnoreEmptyValues(AValue: Boolean): TGBJSONConfig; overload;
    function IgnoreEmptyValues: Boolean; overload;
  end;

implementation

{ TGBJSONConfig }

function TGBJSONConfig.CaseDefinition(AValue: TCaseDefinition): TGBJSONConfig;
begin
  Result := Self;
  FCaseDefinition := AValue;
end;

function TGBJSONConfig.CaseDefinition: TCaseDefinition;
begin
  Result := FCaseDefinition;
end;

constructor TGBJSONConfig.Create;
begin
  raise Exception.Create('Invoke the GetInstance Method.');
end;

constructor TGBJSONConfig.CreatePrivate;
begin
  FIgnoreEmptyValues := True;
  FCaseDefinition := cdNone;
end;

class function TGBJSONConfig.GetInstance: TGBJSONConfig;
begin
  if not Assigned(FInstance) then
  begin
    FInstance := TGBJSONConfig.CreatePrivate;
    FInstance.CaseDefinition(cdNone)
      .IgnoreEmptyValues(True);
  end;
  Result := FInstance;
end;

function TGBJSONConfig.IgnoreEmptyValues: Boolean;
begin
  Result := FIgnoreEmptyValues;
end;

function TGBJSONConfig.DateTimeFormat: string;
begin
  result := FDateTimeFormat;
end;

function TGBJSONConfig.DateTimeLocale: string;
begin
  Result := FDateTimeLocale;
end;

function TGBJSONConfig.DateTimeLocale(AValue: string): TGBJSONConfig;
begin
  FDateTimeLocale := AValue;
end;

function TGBJSONConfig.DateTimeFormat(AValue: string): TGBJSONConfig;
begin
  FDateTimeFormat := AValue;
end;

function TGBJSONConfig.IgnoreEmptyValues(AValue: Boolean): TGBJSONConfig;
begin
  Result := Self;
  FIgnoreEmptyValues := AValue;
end;

class destructor TGBJSONConfig.UnInitialize;
begin
  if Assigned(FInstance) then
    FreeAndNil(FInstance);
end;

end.

unit GBJSON.DateTime.Helper;

interface

{$IFDEF WEAKPACKAGEUNIT}
  {$WEAKPACKAGEUNIT ON}
{$ENDIF}

uses
  System.sysUtils,
  System.DateUtils;

type
  TGBJSONDatetimeHelper = record helper for TDateTime
  private
    function Iso8601ToDateTime(AValue: string): TDateTime;
//    function NormalizeMask(const S: string): string;
//    function DetectTimeSeparator(const S: string): Char;
//    function DetectDateSeparator(const S: string): Char;
//    function SplitDateAndTime(const AMask: string; out ADatePart, ATimePart: string): Boolean;
    function BuildFormatSettingsFromMask(
      const AMask: string;
      const ALocale: string = 'en-US'
    ): TFormatSettings;
  public
    function DateTimeToIso8601: string;
    function Format(ADateFormat: string): string;
    function FormatYYYY_MM_DD: string;
    procedure FromCustomFormatToDateTime(AValue, AformatDateTime,ALocale: string);
    procedure FromIso8601ToDateTime(AValue: string);
  end;

implementation

{ TGBJSONDatetimeHelper }

function TGBJSONDatetimeHelper.DateTimeToIso8601: string;
begin
  if Self = 0 then
    Result := ''
  else
  if Frac(Self) = 0 then
    Result := FormatDateTime('yyyy"-"mm"-"dd', Self)
  else
  if Trunc(Self) = 0 then
    Result := FormatDateTime('"T"hh":"nn":"ss', Self)
  else
    Result := FormatDateTime('yyyy"-"mm"-"dd"T"hh":"nn":"ss', Self);
end;

function TGBJSONDatetimeHelper.Format(ADateFormat: string): string;
begin
  Result := FormatDateTime(ADateFormat, Self);
end;

function TGBJSONDatetimeHelper.FormatYYYY_MM_DD: string;
begin
  Result := Format('yyyy-MM-dd');
end;

procedure TGBJSONDatetimeHelper.FromCustomFormatToDateTime(AValue, AformatDateTime, ALocale: string);
var
  formatSettings: TFormatSettings;
begin
  if ALocale.Trim.IsEmpty then
    formatSettings := BuildFormatSettingsFromMask(AformatDateTime)
  else
    formatSettings :=BuildFormatSettingsFromMask(AformatDateTime,ALocale);
  self := StrToDate(AValue,formatSettings);
end;

procedure TGBJSONDatetimeHelper.fromIso8601ToDateTime(AValue: string);
begin
  Self := Iso8601ToDateTime(AValue);
end;

function TGBJSONDatetimeHelper.Iso8601ToDateTime(AValue: string): TDateTime;
var
  Y, M, D, HH, MI, SS: Cardinal;
begin
  // YYYY-MM-DD   Thh:mm:ss  or  YYYY-MM-DDThh:mm:ss
  // 1234567890   123456789      1234567890123456789

  //{"$date":"2019-08-24T11:08:13.000-03:00"} // Data no Mongo
  AValue := AValue.Replace('{"$date":"', '').Replace('"}', '');

  Result := 0;
  case Length(AValue) of
    9:
      if (AValue[1] = 'T') and (AValue[4] = ':') and (AValue[7] = ':') then
      begin
        HH := Ord(AValue[2]) * 10 + Ord(AValue[3]) - (48 + 480);
        MI := Ord(AValue[5]) * 10 + Ord(AValue[6]) - (48 + 480);
        SS := Ord(AValue[8]) * 10 + Ord(AValue[9]) - (48 + 480);
        if (HH < 24) and (MI < 60) and (SS < 60) then
          Result := EncodeTime(HH, MI, SS, 0);
      end;
    10:
      if (AValue[5] = AValue[8]) and (Ord(AValue[8]) in [Ord('-'), Ord('/')]) then
      begin
        Y := Ord(AValue[1]) * 1000 + Ord(AValue[2]) * 100 + Ord(AValue[3]) * 10 + Ord(AValue[4]) - (48 + 480 + 4800 + 48000);
        M := Ord(AValue[6]) * 10 + Ord(AValue[7]) - (48 + 480);
        D := Ord(AValue[9]) * 10 + Ord(AValue[10]) - (48 + 480);
        if (Y <= 9999) and ((M - 1) < 12) and ((D - 1) < 31) then
          Result := EncodeDate(Y, M, D);
      end;
    19,20,21,22,23,24,25,26,27,28,29:
      if (AValue[5] = AValue[8]) and
         (Ord(AValue[8]) in [Ord('-'), Ord('/')]) and
         (Ord(AValue[11]) in [Ord(' '), Ord('T')]) and
         (AValue[14] = ':') and
         (AValue[17] = ':') then
      begin
        Y := Ord(AValue[1]) * 1000 + Ord(AValue[2]) * 100 + Ord(AValue[3]) * 10 + Ord(AValue[4]) - (48 + 480 + 4800 + 48000);
        M := Ord(AValue[6]) * 10 + Ord(AValue[7]) - (48 + 480);
        D := Ord(AValue[9]) * 10 + Ord(AValue[10]) - (48 + 480);
        HH := Ord(AValue[12]) * 10 + Ord(AValue[13]) - (48 + 480);
        MI := Ord(AValue[15]) * 10 + Ord(AValue[16]) - (48 + 480);
        SS := Ord(AValue[18]) * 10 + Ord(AValue[19]) - (48 + 480);
        if (Y <= 9999) and ((M - 1) < 12) and ((D - 1) < 31) and (HH < 24) and (MI < 60) and (SS < 60) then
          Result := EncodeDate(Y, M, D) + EncodeTime(HH, MI, SS, 0);
      end;
  end;
end;

function DetectDateSeparator(const S: string): Char;
var
  C: Char;
begin
  for C in S do
    if CharInSet(C, ['/', '-', '.']) then
      Exit(C);
  Result := '/';
end;

function DetectTimeSeparator(const S: string): Char;
var
  C: Char;
begin
  for C in S do
    if CharInSet(C, [':', '.']) then
      Exit(C);
  Result := ':';
end;

function NormalizeMask(const S: string): string;
begin
  Result := Trim(S);
  Result := StringReplace(Result, 'HH', 'hh', [rfReplaceAll]);
  Result := StringReplace(Result, 'H', 'h', [rfReplaceAll]);
  Result := StringReplace(Result, 'NN', 'nn', [rfReplaceAll]);
  Result := StringReplace(Result, 'N', 'n', [rfReplaceAll]);
  Result := StringReplace(Result, 'SS', 'ss', [rfReplaceAll]);
  Result := StringReplace(Result, 'S', 's', [rfReplaceAll]);
  Result := StringReplace(Result, 'YYYY', 'yyyy', [rfReplaceAll]);
  Result := StringReplace(Result, 'YYY', 'yyy', [rfReplaceAll]);
  Result := StringReplace(Result, 'YY', 'yy', [rfReplaceAll]);
  Result := StringReplace(Result, 'DD', 'dd', [rfReplaceAll]);
  Result := StringReplace(Result, 'D', 'd', [rfReplaceAll]);
  Result := StringReplace(Result, 'MM', 'mm', [rfReplaceAll]);
end;

function SplitDateAndTime(const AMask: string; out ADatePart, ATimePart: string): Boolean;
var
  P: Integer;
  S: string;
begin
  S := Trim(AMask);
  P := Pos(' ', S);

  if P > 0 then
  begin
    ADatePart := Trim(Copy(S, 1, P - 1));
    ATimePart := Trim(Copy(S, P + 1, MaxInt));
  end
  else
  begin
    if (Pos(':', S) > 0) or (Pos('h', LowerCase(S)) > 0) or (Pos('n', LowerCase(S)) > 0) then
    begin
      ADatePart := '';
      ATimePart := S;
    end
    else
    begin
      ADatePart := S;
      ATimePart := '';
    end;
  end;

  Result := (ADatePart <> '') or (ATimePart <> '');
end;

function TGBJSONDatetimeHelper.BuildFormatSettingsFromMask(
  const AMask: string;
  const ALocale: string
): TFormatSettings;
var
  Mask: string;
  DatePart: string;
  TimePart: string;
  LowerTime: string;
begin
  Result := TFormatSettings.Create(ALocale);
  Mask := NormalizeMask(AMask);

  if not SplitDateAndTime(Mask, DatePart, TimePart) then
    Exit;

  if DatePart <> '' then
  begin
    Result.DateSeparator := DetectDateSeparator(DatePart);
    Result.ShortDateFormat := DatePart;
    Result.LongDateFormat := DatePart;
  end;

  if TimePart <> '' then
  begin
    Result.TimeSeparator := DetectTimeSeparator(TimePart);
    Result.ShortTimeFormat := TimePart;
    Result.LongTimeFormat := TimePart;

    LowerTime := LowerCase(TimePart);
    if (Pos('am/pm', LowerTime) > 0) or (Pos('a/p', LowerTime) > 0) then
    begin
      Result.TimeAMString := 'AM';
      Result.TimePMString := 'PM';
    end;
  end;
end;

end.



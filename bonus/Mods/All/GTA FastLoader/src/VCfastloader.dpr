library VCfastloader;


uses
  SysUtils,
  Windows,
  Classes;

type
TReadStream = class(TThread)
  private
  protected
   procedure Execute; override;
end;

{$R *.res}

var
  ReadStream : TReadStream;
  _userdir_path : PChar;
  OldProtect : Cardinal;

procedure TReadStream.Execute;

begin
if GetKeyState(VK_SHIFT) >= 0 then
begin

       if (PByte($6DC444)^ = 0) and (PInteger($68CFC8)^ = $5F617467) then  //1.0vc
       begin
          if PInteger($9B5F08)^ <= 7 then
          _userdir_path:= PChar($783EF8);
       if FileExists(_userdir_path+'\GTAVCsf1.b') then
          begin
          PByte($49715C)^ := $85;
          while PInteger($9B5F08)^ < 7 do
          Sleep(0);
          Sleep(1500);
          PByte($49715C)^ := $84;
          end;
       end;



       if (PByte($6DC444)^ = 205) and (PInteger($68CFC8)^ = $5F617467) then //1.1vc
       begin
          if PInteger($9B5F08)^ <= 7 then
          _userdir_path:= PChar($783EF8);
       if FileExists(_userdir_path+'\GTAVCsf1.b') then
          begin
          PByte($49716C)^ := $85;
          while PInteger($9B5F08)^ < 7 do
          Sleep(0);
          Sleep(1500);
          PByte($49716C)^ := $84;
          end;
       end;

       if (PByte($601048)^ = 111) and (PInteger($5F3E18)^ = $33617467) then  //1.0iii
       begin
          if PInteger($8F5838)^ <= 7 then
          _userdir_path:= PChar($6510D8);
       if FileExists(_userdir_path+'\GTA3sf1.b') then
          begin
          PByte($485253)^ := $84;
          while PInteger($8F5838)^ < 7 do
          Sleep(0);
          Sleep(1500);
          PByte($485253)^ := $85;
          end;
       end;


       if (PByte($601048)^ = 205) and (PInteger($5F3D20)^ = $33617467) then //1.1iii
       begin
          if PInteger($8F58EC)^ <= 7 then
          _userdir_path:= PChar($6510D8);
       if FileExists(_userdir_path+'\GTA3sf1.b') then
          begin
          PByte($485323)^ := $84;
          while PInteger($8F58EC)^ < 7 do
          Sleep(0);
          Sleep(1500);
          PByte($485323)^ := $85;
          end;
       end;

       if (PByte($858B50)^ = 0) and (PInteger($865674)^ = $5F617467) then //1.0sa
       begin
          while PInteger($C8D4C0)^ <= 8 do // then
          Sleep(0);
          _userdir_path:= PChar($C16F18);
       if FileExists(_userdir_path+'1.b') then
          begin
          while PByte($BA68A5)^ <> 9 do
          Sleep(0);
          PByte($578D70)^ := $85;

          //while PByte($BA67A4)^ = 1 do
          Sleep(1500);
          PByte($578D70)^ := $84;
          end;
       end;

end;

end;

begin
  VirtualProtect(Ptr($49715C),1,PAGE_READWRITE,OldProtect);
  VirtualProtect(Ptr($49716C),1,PAGE_READWRITE,OldProtect);
  VirtualProtect(Ptr($485253),1,PAGE_READWRITE,OldProtect);
  VirtualProtect(Ptr($485323),1,PAGE_READWRITE,OldProtect);
  VirtualProtect(Ptr($578D70),1,PAGE_READWRITE,OldProtect);
  ReadStream := TReadStream.Create(False);
end.
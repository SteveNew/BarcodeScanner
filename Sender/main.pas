unit main;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, IPPeerClient,
  IPPeerServer, System.Tether.Manager, System.Tether.AppProfile, FMX.Edit,
  FMX.StdCtrls, FMX.Platform, FMX.Helpers.Android, Androidapi.Helpers,
  AndroidApi.JNI.GraphicsContentViewText, Androidapi.Jni.JavaTypes, System.Rtti;

type
  TForm2 = class(TForm)
    SpeedButton1: TSpeedButton;
    Edit1: TEdit;
    TetheringManager1: TTetheringManager;
    TetheringAppProfile1: TTetheringAppProfile;
    Label1: TLabel;
    SpeedButton2: TSpeedButton;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);

    procedure TetheringManager1EndManagersDiscovery(const Sender: TObject;
      const RemoteManagers: TTetheringManagerInfoList);
    procedure TetheringManager1EndProfilesDiscovery(const Sender: TObject;
      const RemoteProfiles: TTetheringProfileInfoList);

    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
  private
    { Private declarations }
    FPreservedClipboardValue: TValue;
    FMonitorClipboard: Boolean;
    ClipService: IFMXClipboardService;
    function HandleAppEvent(AAppEvent: TApplicationEvent; AContext: TObject): Boolean;
    function GetBarcodeValue(): Boolean;
  public
    { Public declarations }
  end;

var
  Form2: TForm2;

implementation

{$R *.fmx}

procedure TForm2.FormCreate(Sender: TObject);
var
  aFMXApplicationEventService: IFMXApplicationEventService;
begin
  FMonitorClipboard := False;
  if not TPlatformServices.Current.SupportsPlatformService(IFMXClipboardService, IInterface(ClipService)) then
    ClipService := nil;
  if TPlatformServices.Current.SupportsPlatformService(IFMXApplicationEventService, IInterface(aFMXApplicationEventService)) then
  begin
    aFMXApplicationEventService.SetApplicationEventHandler(HandleAppEvent);
  end
  else
  begin
    Log.d('Application Event Service is not supported.');
  end;
end;

procedure TForm2.FormShow(Sender: TObject);
var
  I: Integer;
begin
  for I := TetheringManager1.PairedManagers.Count - 1 downto 0 do
    TetheringManager1.UnPairManager(TetheringManager1.PairedManagers[I]);
  TetheringManager1.DiscoverManagers;
end;

function TForm2.GetBarcodeValue: Boolean;
var
  value: String;
begin
  Result := False;
  FMonitorClipboard := False;
  if (ClipService.GetClipboard.ToString <> 'nil') then
  begin
    Edit1.Text := ClipService.GetClipboard.ToString;
    ClipService.SetClipboard(FPreservedClipboardValue);
    Result := True;
  end;
end;

function TForm2.HandleAppEvent(AAppEvent: TApplicationEvent;
  AContext: TObject): Boolean;
begin
  Result := False;
  if FMonitorClipboard and (AAppEvent = TApplicationEvent.BecameActive) then
  begin
    Result := GetBarcodeValue;
  end;
end;

procedure TForm2.SpeedButton1Click(Sender: TObject);
var
  intent: JIntent;
begin
  if Assigned(ClipService) then
  begin
    FPreservedClipboardValue := ClipService.GetClipboard;
    FMonitorClipboard := True;
    ClipService.SetClipboard('nil');
    intent := TJIntent.Create;
    intent.setAction(StringToJString('com.google.zxing.client.android.SCAN'));
//    intent.putExtras(TJIntent.JavaClass.EXTRA_TEXT, StringToJString('"SCAN_MODE", "CODE_39"'));
    SharedActivity.startActivityForResult(intent, 0);
  end;
end;

procedure TForm2.SpeedButton2Click(Sender: TObject);
begin
  TetheringAppProfile1.SendString(TetheringManager1.RemoteProfiles[0], 'Barcode from mobile', Edit1.Text);
end;

procedure TForm2.TetheringManager1EndManagersDiscovery(const Sender: TObject;
  const RemoteManagers: TTetheringManagerInfoList);
var
  I: Integer;
begin
  for I := 0 to RemoteManagers.Count-1 do
    if (RemoteManagers[I].ManagerText = 'BarcodeReceiverManager')  then
    begin
      TetheringManager1.PairManager(RemoteManagers[I]);
      Break; // Break since we only want the first...
    end;
end;

procedure TForm2.TetheringManager1EndProfilesDiscovery(const Sender: TObject;
  const RemoteProfiles: TTetheringProfileInfoList);
var
  i: Integer;
begin
  Label1.Text := 'No receiver found';
  for i := 0 to TetheringManager1.RemoteProfiles.Count-1 do
    if (TetheringManager1.RemoteProfiles[i].ProfileText = 'BarcodeReceiver') then
    begin
      if TetheringAppProfile1.Connect(TetheringManager1.RemoteProfiles[i]) then
        Label1.Text := 'Receiver ready.';
      Break; // Break since we only want the first...
    end;
end;

end.

unit main;

interface

uses
  Winapi.Windows, System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.StdCtrls,
  IPPeerClient, IPPeerServer, System.Tether.Manager, System.Tether.AppProfile;

type
  TForm1 = class(TForm)
    TetheringManager: TTetheringManager;
    TetheringAppProfile: TTetheringAppProfile;
    lblStatus: TLabel;
    cbAddReturn: TCheckBox;
    procedure TetheringAppProfileResourceReceived(const Sender: TObject;
      const AResource: TRemoteResource);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}

procedure TForm1.TetheringAppProfileResourceReceived(const Sender: TObject;
  const AResource: TRemoteResource);

// http://msdn.microsoft.com/en-us/library/windows/desktop/ms646304%28v=vs.85%29.aspx
// http://msdn.microsoft.com/en-us/library/windows/desktop/ms646310%28v=vs.85%29.aspx

  procedure SendKeys(const S: String);  // since we receive barcodes - keybd_event() is ok. otherwise use SendInput()
  var
    I: Integer;
  begin
    for I := 1 to Length(S) do
    begin
      // keybd_event() does not support Unicode, so you should use SendInput() instead...
      if CharInSet(S[I], ['A'..'Z']) then
        keybd_event(VK_SHIFT, 0, 0, 0);
      keybd_event(Ord(S[I]), MapVirtualKey(Ord(S[I]), 0),0, 0);
      keybd_event(Ord(S[I]), MapVirtualKey(Ord(S[I]), 0), KEYEVENTF_KEYUP, 0);
      if CharInSet(S[I], ['A'..'Z']) then
        keybd_event(VK_SHIFT, 0, KEYEVENTF_KEYUP, 0);
    end;
  end;

begin
  SendKeys(AResource.Value.AsString);  // Actually send this to the keyboard buffer.
  if cbAddReturn.IsChecked then
    SendKeys(char(13));
end;

end.

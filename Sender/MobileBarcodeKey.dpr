program MobileBarcodeKey;

uses
  System.StartUpCopy,
  FMX.MobilePreview,
  FMX.Forms,
  main in 'main.pas' {Form2},
  com.google.zxing.integration.android.IntentIntegrator in 'com.google.zxing.integration.android.IntentIntegrator.pas',
  com.google.zxing.integration.android.IntentResult in 'com.google.zxing.integration.android.IntentResult.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.FormFactor.Orientations := [TFormOrientation.Portrait];
  Application.CreateForm(TForm2, Form2);
  Application.Run;
end.

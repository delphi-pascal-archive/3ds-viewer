program View3DS;

uses
  Forms,
  uMain in 'uMain.pas' {fm3DView},
  Open3ds in 'Open3ds.pas',
  Textures in 'Textures.pas',
  uAbout in 'uAbout.pas' {fmAbout};

{$R *.res}

begin
  Application.CreateForm(Tfm3DView, fm3DView);
  Application.Run;
end.

unit uMain;

interface

uses
  Windows, Messages, SysUtils, Forms, Dialogs, Classes,
  Controls, ExtCtrls, Menus, OpenGL, Open3ds, StdCtrls,
  ComCtrls;

const
 StandHeader = '3DS Viewer';
 LblModelText = 'No model';
 
type
  TLight = record
    amb, dif, spec: TGLArrayf3;
    pos: TGLArrayf4;
  end;
  
  TBox = record x1, y1, z1, x2, y2, z2: GLfloat; xC, yC, zC: GLfloat end;
  Tfm3DView = class(TForm)
    pnDraw: TPanel;
    MainMenu1: TMainMenu;
    mnFile: TMenuItem;
    mnFOpen: TMenuItem;
    mnFSep: TMenuItem;
    mnFExit: TMenuItem;
    mnView: TMenuItem;
    mnFRecent: TMenuItem;
    mnFSep2: TMenuItem;
    mnFDefOpen: TMenuItem;
    tcTabs: TTabControl;
    gbLight: TGroupBox;
    gbLightPos: TGroupBox;
    gbLgtSpec: TGroupBox;
    lblR1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    tbRLS: TTrackBar;
    tbGLS: TTrackBar;
    tbBLS: TTrackBar;
    gbLgtAmb: TGroupBox;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    tbRLA: TTrackBar;
    tbGLA: TTrackBar;
    tbBLA: TTrackBar;
    gbLgtDif: TGroupBox;
    Label1: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    tbRLD: TTrackBar;
    tbGLD: TTrackBar;
    tbBLD: TTrackBar;
    gbInfo: TGroupBox;
    cmbObjects: TComboBox;
    cmbMaterials: TComboBox;
    mmInfo: TMemo;
    gbErrors: TGroupBox;
    mmError: TMemo;
    gbView: TGroupBox;
    ledScale: TLabeledEdit;
    mnVAxis: TMenuItem;
    lblModelBox: TLabel;
    mnVAutosize: TMenuItem;
    trvObjects: TTreeView;
    ppmnObjView: TPopupMenu;
    pmnOHide: TMenuItem;
    pmnOUnhide: TMenuItem;
    pmnOHideAll: TMenuItem;
    pmnOUnhideAll: TMenuItem;
    mnFClose: TMenuItem;
    lblFPS: TLabel;
    mnHelp: TMenuItem;
    mnHAbout: TMenuItem;
    mnHSep: TMenuItem;
    mnHHelp: TMenuItem;
    mnVSep: TMenuItem;
    mnVShowGround: TMenuItem;
    mnVModeRotation: TMenuItem;
    mnVModeWThrough: TMenuItem;
    mnVSep2: TMenuItem;
    mnVFullScreen: TMenuItem;
    mnVSep3: TMenuItem;
    mnVOrtho: TMenuItem;
    mnVPerspective: TMenuItem;
    function InitOpenGL(): string;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure mnFExitClick(Sender: TObject);
    procedure pnDrawMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure pnDrawMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure pnDrawMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure mnFOpenClick(Sender: TObject);
    procedure mnFDefOpenClick(Sender: TObject);
    procedure cmbObjectsChange(Sender: TObject);
    procedure tcTabsChange(Sender: TObject);
    procedure tbRLSChange(Sender: TObject);
    procedure tbGLSChange(Sender: TObject);
    procedure tbBLSChange(Sender: TObject);
    procedure tbRLAChange(Sender: TObject);
    procedure tbGLAChange(Sender: TObject);
    procedure tbBLAChange(Sender: TObject);
    procedure tbRLDChange(Sender: TObject);
    procedure tbGLDChange(Sender: TObject);
    procedure tbBLDChange(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ledScaleExit(Sender: TObject);
    procedure ledScaleKeyPress(Sender: TObject; var Key: Char);
    procedure cmbMaterialsChange(Sender: TObject);
    procedure mnVAxisClick(Sender: TObject);
    procedure mnVAutosizeClick(Sender: TObject);
    procedure FormMouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    procedure pmnOHideClick(Sender: TObject);
    procedure pmnOUnhideClick(Sender: TObject);
    procedure pmnOHideAllClick(Sender: TObject);
    procedure pmnOUnhideAllClick(Sender: TObject);
    procedure mnFCloseClick(Sender: TObject);
    procedure mnHAboutClick(Sender: TObject);
    procedure mnVShowGroundClick(Sender: TObject);
    procedure mnVModeRotationClick(Sender: TObject);
    procedure mnVModeWThroughClick(Sender: TObject);
    procedure mnVFullScreenClick(Sender: TObject);
    procedure mnVOrthoClick(Sender: TObject);
    procedure mnVPerspectiveClick(Sender: TObject);
  private
    dc: HDC;
    hrc: HGLRC;
    //
    fname: string;         // current file name
    mouse_rot: boolean;
    lastX, lastY: integer;
    model_box: TBox;
    light: TLight;
    fps: word;             // frame per second
    time: GLuint;
    _scale: GLfloat;
    tnodes: array of TTreeNode;
    procedure set_scale(val: GLfloat);
    procedure draw_axis();
    procedure draw_ground();
  public
    angAlpha, angDelta: GLfloat;  // for rotation mode
    // for fullscreen mode
    pnTop, pnLeft, pnWidth, pnHeight: integer;
    fTop, fLeft, fWidth, fHeight: integer;
    // -------------------
    model: T3DSModel;
    property scale: GLfloat read _scale write set_scale;
    procedure open_file(file_name: string);
    procedure idle(Sender: TObject; var done: boolean);
  end;

var
  fm3DView: Tfm3DView;

implementation

uses uAbout;

{$R *.dfm}
function max(x1, x2, x3: GLfloat): GLfloat;
 begin
  if x1 > x2
   then if x1 > x3 then Result:=x1 else Result:=x3
   else if x2 > x3 then Result:=x2 else Result:=x3;
 end;

function Tfm3DView.InitOpenGL: string;
 var pfd: TPixelFormatDescriptor;
     pf: integer;
begin
 dc:=GetDC(pnDraw.Handle);
 pf:=sizeof(pfd);
 ZeroMemory(@pfd, pf);
 pfd.nSize:=pf;
 pfd.nVersion:=1;
 pfd.dwFlags:=PFD_DRAW_TO_WINDOW or PFD_SUPPORT_OPENGL or PFD_DOUBLEBUFFER;
 pfd.iPixelType:=PFD_TYPE_RGBA;
 pfd.cColorBits:=32;
 pfd.cDepthBits:=16;
 pfd.iLayerType:=PFD_MAIN_PLANE;
 pf:=ChoosePixelFormat(dc, @pfd);
 if not SetPixelFormat(dc, pf, @pfd) then
  begin Result:='Can`t set pixel format'; exit end;
 hrc:=wglCreateContext(dc);
 if hrc = 0 then
  begin Result:='Can`t create context'; exit end;
 if not wglMakeCurrent(dc, hrc) then
  begin Result:='Can`t set context'; exit end;
 //
 glClearColor(0.0, 0.0, 0.0, 1.0);
 glEnable(GL_DEPTH_TEST);
 glEnable(GL_LIGHTING);
 glEnable(GL_LIGHT0);
 glLightfv(GL_LIGHT0, GL_POSITION, @Light.pos);
 glLightfv(GL_LIGHT0, GL_AMBIENT, @Light.amb);
 glLightfv(GL_LIGHT0, GL_DIFFUSE, @Light.dif);
 glLightfv(GL_LIGHT0, GL_SPECULAR, @Light.spec);   //}
 //
 Result:='';
end;

procedure Tfm3DView.FormCreate(Sender: TObject);
 var s: string;
begin
 // vars init
 mouse_rot:=false;
 angAlpha:=0;
 angDelta:=0;
 scale:=100;
 ledScale.Text:=FloatToStr(scale);
 model:=T3DSModel.create();
 with light do
  begin
   amb[0]:=0.6;   tbRLA.Position:=round(amb[0]*64);
   amb[1]:=0.6;   tbGLA.Position:=round(amb[1]*64);
   amb[2]:=0.6;   tbBLA.Position:=round(amb[2]*64);
   dif[0]:=0.5;   tbRLD.Position:=round(dif[0]*64);
   dif[1]:=0.5;   tbRLD.Position:=round(dif[1]*64);
   dif[2]:=0.5;   tbRLD.Position:=round(dif[2]*64);
   spec[0]:=0.7;  tbRLS.Position:=round(spec[0]*64);
   spec[1]:=0.7;  tbGLS.Position:=round(spec[1]*64);
   spec[2]:=0.75;  tbBLS.Position:=round(spec[2]*64);
   pos[0]:=100;
   pos[1]:=100;
   pos[2]:=300;
   pos[3]:=1;
  end;
 // OpenGL init
 s:=InitOpenGL();
 if s <> '' then
  begin
   MessageBox(Handle, PChar('Serious problems with OpenGL occured:'#13 + s), PChar('Error'), MB_OK or MB_ICONERROR);
   Halt
  end;
 // components init
 Self.WindowState:=wsMaximized;
 gbInfo.Visible:=true;
 gbLight.Visible:=false;
 Application.OnIdle:=idle;
 // command line processing
 fname:=GetCommandLine();
 while fname[1]= ' ' do Delete(fname, 1, 1);
 if fname[1] = '"' then
  begin
   Delete(fname, 1, 1);
   Delete(fname, 1, pos('"', fname));
   if pos('"', fname) = 0 then fname:=''
   else
    begin
     Delete(fname, length(fname), 1);
     Delete(fname, 1, pos('"', fname))
    end
  end;
 if fname <> '' then open_file(fname);
end;

procedure Tfm3DView.FormDestroy(Sender: TObject);
begin
 if hrc = 0 then exit;
 model.destroy();
 wglMakeCurrent(0, 0);
 wglDeleteContext(hrc);
 ReleaseDC(pnDraw.Handle, dc); DeleteDC(dc);
end;

procedure Tfm3DView.FormKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 if (0 <> tcTabs.TabIndex) then exit;
 case Key of
   ord('t'), ord('T'): begin angAlpha:=0; angDelta:=90 end;
   ord('f'), ord('F'): begin angAlpha:=0; angDelta:=0 end;
   ord('l'), ord('L'): begin angAlpha:=-90; angDelta:=0 end;
   ord('r'), ord('R'): begin angAlpha:=90; angDelta:=0 end;
 end;
end;

procedure Tfm3DView.tcTabsChange(Sender: TObject);
begin
 gbView.Visible:=(0 = tcTabs.TabIndex);
 gbInfo.Visible:=(1 = tcTabs.TabIndex);
 gbLight.Visible:=(2 = tcTabs.TabIndex);
 gbErrors.Visible:=(3 = tcTabs.TabIndex);
end;

procedure Tfm3DView.open_file(file_name: string);
 var i, j, ttc: integer;
     TNModel: TTreeNode;
     mdlname: string;
begin
 for i:=0 to high(tnodes)-1 do tnodes[i].Delete;
 SetLength(tnodes, 0);
 if (file_name <> '') and not FileExists(file_name) then
  begin
   ShowMessage(file_name + ' not found');
   exit
  end;
 Screen.Cursor:=crHourGlass;
 try model.load(file_name);
 except
  on E: Exception do
   begin
    Screen.Cursor:=crDefault;
    ShowMessage('Error occured when opening ' + file_name + #13#13 + E.Message + #13);
    model.load('');
    exit;
   end;
 end;
  // total faces count
 ttc:=0;
 for i:=0 to model.count-1 do with model.objects[i]^ do
  ttc:=ttc + fcount;
 lblModelBox.Caption:='Total triangles count: ' + IntToStr(ttc);
 // get info
 if model.count = 0
  then with model_box do begin x1:=-1; x2:=1; y1:=-1; y2:=1; z1:=-1; z2:=1; xC:=0; yC:=0; zC:=0 end
  else with model_box do
   begin
    x1:=model.objects[0].points[0][0];
    y1:=model.objects[0].points[0][1];
    z1:=model.objects[0].points[0][2];
    x2:=x1;
    y2:=y1;
    z2:=z1;
    for i:=0 to model.count-1 do with model.objects[i]^ do
     for j:=0 to pcount-1 do
      begin
       if points[j][0] < x1 then x1:=points[j][0];
       if points[j][0] > x2 then x2:=points[j][0];
       if points[j][1] < y1 then y1:=points[j][1];
       if points[j][1] > y2 then y2:=points[j][1];
       if points[j][2] < z1 then z1:=points[j][2];
       if points[j][2] > z2 then z2:=points[j][2];
      end;       //}
    xC:=(x2 + x1)/2;
    yC:=(y2 + y1)/2;
    zC:=(z2 + z1)/2;
    lblModelBox.Caption:=lblModelBox.Caption + #13#13'Model box:'#13;
    lblModelBox.Caption:=lblModelBox.Caption + ' x1: ' + FloatToStr(x1) + #13;
    lblModelBox.Caption:=lblModelBox.Caption + ' y1: ' + FloatToStr(y1) + #13;
    lblModelBox.Caption:=lblModelBox.Caption + ' z1: ' + FloatToStr(z1) + #13#13;
    lblModelBox.Caption:=lblModelBox.Caption + ' x2: ' + FloatToStr(x2) + #13;
    lblModelBox.Caption:=lblModelBox.Caption + ' y2: ' + FloatToStr(y2) + #13;
    lblModelBox.Caption:=lblModelBox.Caption + ' z2: ' + FloatToStr(z2) + #13#13;
    lblModelBox.Caption:=lblModelBox.Caption + ' xC: ' + FloatToStr(xC) + #13;
    lblModelBox.Caption:=lblModelBox.Caption + ' yC: ' + FloatToStr(xC) + #13;
    lblModelBox.Caption:=lblModelBox.Caption + ' zC: ' + FloatToStr(xC) + #13;
   end;
 if mnVAutosize.Checked then with model_box do scale:=max(x2 - x1, y2 - y1, z2 - z1);
 // adding to ComboBoxes lists
 cmbObjects.Items.Clear;
 for i:=0 to model.count-1 do
   cmbObjects.Items.Add(model.objects[i].name);
 cmbMaterials.Items.Clear;
 for i:=0 to model.materials.count-1 do
   cmbMaterials.Items.Add(model.materials.material[i].name);
 Screen.Cursor:=crDefault;
 // adding objects to ObjView
 mdlname:='';
 i:=length(file_name);
 while file_name[i] <> '\' do
  begin mdlname:=file_name[i] + mdlname; dec(i) end;
 Delete(mdlname, length(mdlname) - 3, 4);
 trvObjects.Items.Clear;
 TNModel:=trvObjects.Items.Add(NIL, 'Model '+ mdlname);
 SetLength(tnodes, model.count);
 for i:=0 to model.count-1 do
  tnodes[i]:=trvObjects.Items.AddChild(TNModel, model.objects[i].name);
end;

procedure Tfm3DView.draw_axis;
 var l: GLfloat;
begin
 l:=scale*0.8;
 glBegin(GL_LINES);
 // X
  glColor3ub(255, 0, 0);
  glVertex3f(0, 0, 0);
  glVertex3f(l, 0, 0);

  glVertex3f(l, 0.02*l, 0);
  glVertex3f(0.92*l, 0.06*l, 0);
  glVertex3f(l, 0.06*l, 0);
  glVertex3f(0.92*l, 0.02*l, 0);
 // Y
  glColor3ub(0, 255, 0);
  glVertex3f(0, 0, 0);
  glVertex3f(0, l, 0);

  glVertex3f(0.02*l, l, 0);
  glVertex3f(0.06*l, l*0.92, 0);
  glVertex3f(0.06*l, l, 0);
  glVertex3f(0.04*l, l*0.96, 0);
 // Z
  glColor3ub(0, 0, 255);
  glVertex3f(0, 0, 0);
  glVertex3f(0, 0, l);

  glVertex3f(0, 0.02*l, l);
  glVertex3f(0, 0.06*l, l);
  glVertex3f(0, 0.02*l, 0.92*l);
  glVertex3f(0, 0.06*l, 0.92*l);
  glVertex3f(0, 0.06*l, l);
  glVertex3f(0, 0.02*l, 0.92*l);
 glEnd;
 glColor3ub(255, 255, 255);
end;

procedure Tfm3DView.draw_ground;
 const n = 10;
 var i, j: GLbyte;
     a: GLfloat;
begin
 glEnable(GL_BLEND);
 glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
 glPushMatrix;
 a:=2*scale/n;
 glTranslatef(-a*n/2, -a*n/2, -0.01);
 for i:=0 to n-1 do
  begin
   glBegin(GL_QUADS);
    for j:=0 to n-1 do
     begin
      glColor4f((i+j) mod 2, (i+j) mod 2, (i+j) mod 2, 0.7*((i+j) mod 2));
      glVertex3f(a*i,     a*j,     0.0);
      glVertex3f(a*(i+1), a*j,     0.0);
      glVertex3f(a*(i+1), a*(j+1), 0.0);
      glVertex3f(a*i,     a*(j+1), 0.0);
     end;
   glEnd
  end;
 glPopMatrix
end;

//--------------------------------------------------------------
//------------        Mouse handlers        --------------------
//--------------------------------------------------------------

procedure Tfm3DView.pnDrawMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
 if Button = mbLeft then
  begin
   Screen.Cursor:=crSizeAll;
   mouse_rot:=true;
  end;
 lastX:=X; lastY:=Y;
end;

procedure Tfm3DView.pnDrawMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
 if not mouse_rot then exit;
 angAlpha:=angAlpha + 360*(X - lastX)/pnDraw.Width;
 angDelta:=angDelta + 360*(lastY - Y)/pnDraw.Height;
 lastX:=X;
 lastY:=Y;
end;

procedure Tfm3DView.pnDrawMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin mouse_rot:=false; Screen.Cursor:=crDefault; pnDraw.Cursor:=crCross end;

procedure Tfm3DView.FormMouseWheel(Sender: TObject; Shift: TShiftState;
  WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
begin
 scale:=scale*exp(WheelDelta*ln(1.001));
end;

//--------------------------------------------------------------
//------------    Panel info commands       --------------------
//--------------------------------------------------------------

procedure Tfm3DView.cmbMaterialsChange(Sender: TObject);
begin
 with model.materials.material[cmbMaterials.ItemIndex]^ do
  begin
   mmInfo.Lines.Clear;
   mmInfo.Lines.Add('//-------------------------');
   mmInfo.Lines.Add('//----- MATERIAL '+IntToStr(cmbMaterials.ItemIndex)+': ' + name + '-----');
   mmInfo.Lines.Add('//-------------------------');
   mmInfo.Lines.Add(' ambient: ('+FloatToStr(amb[0])+', '+FloatToStr(amb[1])+', '+FloatToStr(amb[2])+')');
   mmInfo.Lines.Add(' diffuse: ('+FloatToStr(dif[0])+', '+FloatToStr(dif[1])+', '+FloatToStr(dif[2])+')');
   mmInfo.Lines.Add(' specular: ('+FloatToStr(spec[0])+', '+FloatToStr(spec[1])+', '+FloatToStr(spec[2])+')');
   mmInfo.Lines.Add(' shininess is '+IntToStr(shininess));
   mmInfo.Lines.Add(' transparency is '+IntToStr(transparency));
   mmInfo.Lines.Add(' shading is '+IntToStr(shading));
   mmInfo.Lines.Add(' reflection blur is '+IntToStr(reflblur));
   mmInfo.Lines.Add(' self-illumination is '+IntToStr(self_ilum));
   if twosided
    then mmInfo.Lines.Add(' is twosided')
    else mmInfo.Lines.Add(' is one side material');
   if wired
    then mmInfo.Lines.Add(' is wired, wiresize ' + FloatToStr(wiresize));
   if texture <> NIL then
    begin
     if texture.tex_num = ERROR_TEX
      then mmInfo.Lines.Add(' texture [not loaded]:')
      else mmInfo.Lines.Add(' texture [loaded]:');
     mmInfo.Lines.Add('    path: '+texture.path);
     mmInfo.Lines.Add('    id: ' + IntToStr(texture.tex_num));
    end;
  end;
end;

procedure Tfm3DView.cmbObjectsChange(Sender: TObject);
 var i: integer;
begin
 Screen.Cursor:=crHourGlass;
 mmInfo.Visible:=false;
 with model.objects[cmbObjects.ItemIndex]^ do
  begin
   mmInfo.Clear;
   mmInfo.Lines.Add('//------------------------------- ');
   mmInfo.Lines.Add('Object ' + name + ' properties:');
   mmInfo.Lines.Add('');
   mmInfo.Lines.Add('');
   mmInfo.Lines.Add('//----- POINTS ------------------ ');
   mmInfo.Lines.Add(' ' + IntToStr(pcount) + ' points: ');
   for i:=0 to pcount-1 do
    mmInfo.Lines.Add('  '+IntToStr(i)+') (' +
                      FloatToStr(points[i][0]) + ', ' +
                      FloatToStr(points[i][1]) + ', ' +
                      FloatToStr(points[i][2]) + ')');
   if uses_texverts then
    begin
     mmInfo.Lines.Add('');
     mmInfo.Lines.Add('//----- TEXTURE VERTICES ---------');
     mmInfo.Lines.Add(' has texture vertecis: ');
     for i:=0 to pcount-1 do
      mmInfo.Lines.Add('  '+IntToStr(i)+') (' +
                        FloatToStr(tex_verts[i][0]) + ', ' +
                        FloatToStr(tex_verts[i][1]) + ')');
      end;
   mmInfo.Lines.Add('');
   mmInfo.Lines.Add('//----- TRIANGLES --------------- ');
   mmInfo.Lines.Add(' ' + IntToStr(fcount) + ' triangles:');
   if uses_mtr_faces then
    for i:=0 to fcount-1 do
     mmInfo.Lines.Add('  '+IntToStr(i)+') (' +
                      IntToStr(faces[i][0]) + ', ' +
                      IntToStr(faces[i][1]) + ', ' +
                      IntToStr(faces[i][2]) + '); mtrl.: ' +
                      model.materials.material[mtr_faces[i]].name)
   else
    for i:=0 to fcount-1 do
     mmInfo.Lines.Add('  '+IntToStr(i)+') (' +
                      IntToStr(faces[i][0]) + ', ' +
                      IntToStr(faces[i][1]) + ', ' +
                      IntToStr(faces[i][2]) + ');')
  end;
 Screen.Cursor:=crDefault;
 mmInfo.Visible:=true;
end;

procedure Tfm3DView.ledScaleExit(Sender: TObject);
 var a: GLfloat;
begin
 try a:=StrToFloat(ledScale.Text);
 except
  on EConvertError do
   begin
    ShowMessage('Value '#13 + ledScale.Text + #13'is incorrect');
    ledScale.SetFocus();
    exit
   end;
 end;
 _scale:=a;
end;

procedure Tfm3DView.ledScaleKeyPress(Sender: TObject; var Key: Char);
begin if key = #13 then ledScaleExit(Self) end;

procedure Tfm3DView.set_scale(val: GLfloat);
begin
 _scale:=val;
 ledScale.Text:=FloatToStr(_scale);
end;

//--------------------------------------------------------------
//------------    Popup ObjView commands    --------------------
//--------------------------------------------------------------

procedure Tfm3DView.pmnOHideClick(Sender: TObject);
 var i: integer;
begin
 for i:=0 to model.count-1 do
  if tnodes[i].Selected then
   begin
    model.objects[i].hidden:=true;
    if tnodes[i].Text[1] <> '[' then tnodes[i].Text:='[' + tnodes[i].Text + ']';
   end;
end;

procedure Tfm3DView.pmnOUnhideClick(Sender: TObject);
 var i: integer;
begin
 for i:=0 to model.count-1 do
  if tnodes[i].Selected then
   begin
    model.objects[i].hidden:=false;
    if tnodes[i].Text[1] = '[' then
     tnodes[i].Text:=copy(tnodes[i].Text, 2, length(tnodes[i].Text)-2);
   end;
end;

procedure Tfm3DView.pmnOHideAllClick(Sender: TObject);
 var i: integer;
begin
 for i:=0 to model.count-1 do
   begin
    model.objects[i].hidden:=true;
    if tnodes[i].Text[1] <> '[' then tnodes[i].Text:='[' + tnodes[i].Text + ']';
   end;
end;

procedure Tfm3DView.pmnOUnhideAllClick(Sender: TObject);
 var i: integer;
begin
 for i:=0 to model.count-1 do
   begin
    model.objects[i].hidden:=false;
    if tnodes[i].Text[1] = '[' then
     tnodes[i].Text:=copy(tnodes[i].Text, 2, length(tnodes[i].Text)-2);
   end;
end;

//--------------------------------------------------------------
//------------     Main menu commands       --------------------
//--------------------------------------------------------------

procedure Tfm3DView.mnFOpenClick(Sender: TObject);
 var OpenDialog: TOpenDialog;
begin
 OpenDialog:=TOpenDialog.Create(Self);
 OpenDialog.Filter:='3DS files (.3ds)|*.3ds';
 if OpenDialog.Execute then
  begin
   InvalidateRect(Handle, NIL, false);
   open_file(OpenDialog.FileName)
  end;
 OpenDialog.Free
end;

procedure Tfm3DView.mnFCloseClick(Sender: TObject);
begin
 lblModelBox.Caption:=LblModelText;
 trvObjects.Items.Clear;
 cmbObjects.Clear;
 cmbMaterials.Clear;
 model.load('');
end;

procedure Tfm3DView.mnFDefOpenClick(Sender: TObject);
begin open_file('plane.3ds') end;

procedure Tfm3DView.mnFExitClick(Sender: TObject);
begin  Close() end;

procedure Tfm3DView.mnVAxisClick(Sender: TObject);
begin
 mnVAxis.Checked:=not mnVAxis.Checked;
end;

procedure Tfm3DView.mnVAutosizeClick(Sender: TObject);
begin
 mnVAutosize.Checked:=not mnVAutosize.Checked;
 if not mnVAutosize.Checked
  then scale:=100
  else with model_box do scale:=max(x2 - x1, y2 - y1, z2 - z1);
end;

procedure Tfm3DView.mnVOrthoClick(Sender: TObject);
begin mnVOrtho.Checked:=true end;

procedure Tfm3DView.mnVPerspectiveClick(Sender: TObject);
begin mnVPerspective.Checked:=true end;

procedure Tfm3DView.mnVShowGroundClick(Sender: TObject);
begin mnVShowGround.Checked:=not mnVShowGround.Checked end;

procedure Tfm3DView.mnVModeRotationClick(Sender: TObject);
begin mnVModeRotation.Checked:=true end;

procedure Tfm3DView.mnVModeWThroughClick(Sender: TObject);
begin mnVModeWThrough.Checked:=true end;

procedure Tfm3DView.mnHAboutClick(Sender: TObject);
begin
 Application.CreateForm(TfmAbout, fmAbout);
 fmAbout.ShowModal;
end;
procedure Tfm3DView.mnVFullScreenClick(Sender: TObject);
 var s: string;
begin
 mnVFullScreen.Checked:=not mnVFullScreen.Checked;
 wglMakeCurrent(0, 0);
 wglDeleteContext(hrc);
 ReleaseDC(pnDraw.Handle, dc);
 if mnVFullScreen.Checked then
  begin
   fTop:=Top;
   fLeft:=Left;
   fWidth:=Width;
   fHeight:=Height;
   pnTop:=pnDraw.Top;
   pnLeft:=pnDraw.Left;
   pnWidth:=pnDraw.Width;
   pnHeight:=pnDraw.Height;
   BorderStyle:=bsNone;
   pnDraw.BringToFront;
   Top:=0;        Left:=0;
   pnDraw.Top:=0; pnDraw.Left:=0;
   Width:=Screen.Width;  Height:=Screen.Height;
   pnDraw.Width:=Width;  pnDraw.Height:=Height;
   ShowWindow(MainMenu1.Handle, SW_HIDE);
  end
  else
  begin
   BorderStyle:=bsSizeable;
   Top:=fTop;         Left:=fLeft;
   pnDraw.Top:=pnTop; pnDraw.Left:=pnLeft;
   Width:=fWidth;  Height:=fHeight;
   pnDraw.Width:=pnWidth;  pnDraw.Height:=pnHeight;
   ShowWindow(MainMenu1.Handle, SW_SHOWNORMAL);
  end;
 // OpenGL reinit
 s:=InitOpenGL();
 if s <> '' then
  begin
   MessageBox(Handle, PChar('Serious problms with OpenGL occure:'#13 + s), PChar('Error'), MB_OK or MB_ICONERROR);
   Halt
  end;
 //
end;

//--------------------------------------------------------------
//------------    Panel Light commands       --------------------
//--------------------------------------------------------------

procedure Tfm3DView.tbRLSChange(Sender: TObject);
begin
 light.spec[0]:=tbRLS.Position/64;
 InvalidateRect(Handle, NIL, false)
end;
procedure Tfm3DView.tbGLSChange(Sender: TObject);
begin
 light.spec[1]:=tbGLS.Position/64;
 InvalidateRect(Handle, NIL, false)
end;
procedure Tfm3DView.tbBLSChange(Sender: TObject);
begin
 light.spec[2]:=tbBLS.Position/64;
 InvalidateRect(Handle, NIL, false)
end;
procedure Tfm3DView.tbRLAChange(Sender: TObject);
begin
 light.amb[0]:=tbRLA.Position/64;
 InvalidateRect(Handle, NIL, false)
end;
procedure Tfm3DView.tbGLAChange(Sender: TObject);
begin
 light.amb[1]:=tbGLA.Position/64;
 InvalidateRect(Handle, NIL, false)
end;
procedure Tfm3DView.tbBLAChange(Sender: TObject);
begin
 light.amb[2]:=tbBLA.Position/64;
 InvalidateRect(Handle, NIL, false)
end;
procedure Tfm3DView.tbRLDChange(Sender: TObject);
begin
 light.dif[0]:=tbRLD.Position/64;
 InvalidateRect(Handle, NIL, false)
end;
procedure Tfm3DView.tbGLDChange(Sender: TObject);
begin
 light.dif[1]:=tbGLD.Position/64;
 InvalidateRect(Handle, NIL, false)
end;
procedure Tfm3DView.tbBLDChange(Sender: TObject);
begin
 light.dif[2]:=tbBLD.Position/64;
 InvalidateRect(Handle, NIL, false)
end;

//---------------------------------------------------
//-------------   Idle procedure   ------------------
//---------------------------------------------------

procedure Tfm3DView.idle(Sender: TObject; var done: boolean);
begin
 if not Application.Active then exit;
 if (GetTickCount div 1000) <> time then
  begin
   time:=GetTickCount div 1000;
   Caption:=StandHeader;
   if fname <> '' then Caption:=Caption + ' - ' + fname;
   lblFPS.Caption:='fps: ' + IntToStr(fps);
   if time mod 10 = 0 then mmError.Lines:=model.error_list;
   //if mmError.Lines.Count <> 0 then tcTabs.TabIndex:=3;  // if there are errors, other tabs aren't available
   fps:=0;
  end;
 //
 glLoadIdentity();
 glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
 glViewport(0, 0, pnDraw.Width, pnDraw.Height);
 if mnVOrtho.Checked then
  glOrtho(-scale*pnDraw.Width/pnDraw.Height, scale*pnDraw.Width/pnDraw.Height, -scale, scale, -5*scale, 5*scale);
 if mnVPerspective.Checked then
  glFrustum(-scale*pnDraw.Width/pnDraw.Height, scale*pnDraw.Width/pnDraw.Height, -scale, scale, -50*scale, 50*scale);
 // gluPerspective(60, pnDraw.Width/pnDraw.Height, 0, 50*scale); //αλ³ν
 glLightfv(GL_LIGHT0, GL_POSITION, @Light.pos);
 glLightfv(GL_LIGHT0, GL_AMBIENT, @Light.amb);
 glLightfv(GL_LIGHT0, GL_DIFFUSE, @Light.dif);
 glLightfv(GL_LIGHT0, GL_SPECULAR, @Light.spec);
 glPushMatrix();
  glEnable(GL_DEPTH_TEST);
  glRotatef(angDelta, 1, 0, 0);
  glRotatef(angAlpha, 0, 0, 1);
  if mnVShowGround.Checked then draw_ground;
  glEnable(GL_LIGHTING);
  glPushMatrix;
   if mnVAutosize.Checked then glTranslatef(-model_box.xC, -model_box.yC, -model_box.zC);
   model.draw;
  glPopMatrix;
  glDisable(GL_LIGHTING);
  glDisable(GL_DEPTH_TEST);
  if mnVAxis.Checked then draw_axis();
 glPopMatrix();
 SwapBuffers(dc);
 //-----------------------------
 inc(fps);
end;

end.

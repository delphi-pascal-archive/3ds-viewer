//----------------------------------------------------------------------------
//
// Author      : Jan Horn
// Email       : jhorn@global.co.za
// Website     : http://home.global.co.za/~jhorn
// Version     : 1.01
// Date        : 1 May 2001
// Changes     : 28 July - Faster BGR to RGB swapping routine
//               Modifyed by Dm
// Description : A unit that used with OpenGL projects to load BMP, JPG and TGA
//               files from the disk or a resource file.
// Usage       : LoadTexture(Filename, TextureName, LoadFromResource);
//
//               eg : LoadTexture('logo.jpg', LogoTex, TRUE);
//                    will load a JPG texture from the resource included
//                    with the EXE. File has to be loaded into the Resource
//                    using this format  "logo JPEG logo.jpg"
//
//----------------------------------------------------------------------------
unit Textures;

interface

uses
  Windows, OpenGL, Graphics, Classes, JPEG, SysUtils;

function LoadTexture(Filename: String; var Texture: GLuint; qual: GLint = GL_LINEAR): Boolean;
procedure glBindTexture(target: GLenum; texture: GLuint); stdcall; external opengl32;
function gluBuild2DMipmaps(Target: GLenum; Components, Width, Height: GLint; Format, atype: GLenum; Data: Pointer): GLint; stdcall; external glu32;
procedure glGenTextures(n: GLsizei; var textures: GLuint); stdcall; external opengl32;

implementation

procedure SwapRGB(data : Pointer; Size : Integer);
asm
  mov ebx, eax
  mov ecx, size

@@loop :
  mov al,[ebx+0]
  mov ah,[ebx+2]
  mov [ebx+2],al
  mov [ebx+0],ah
  add ebx,3
  dec ecx
  jnz @@loop
end;


{------------------------------------------------------------------}
{  Create the Texture                                              }
{------------------------------------------------------------------}
function CreateTexture(Width, Height, Format : Word; pData : Pointer; quality: GLint) : Integer;
var
  Texture : GLuint;
begin
  glGenTextures(1, Texture);
  glBindTexture(GL_TEXTURE_2D, Texture);
  glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);  {Texture blends with object background}
//  glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_DECAL);  {Texture does NOT blend with object background}

  { Select a filtering type. BiLinear filtering produces very good results with little performance impact
    GL_NEAREST               - Basic texture (grainy looking texture)
    GL_LINEAR                - BiLinear filtering
    GL_LINEAR_MIPMAP_NEAREST - Basic mipmapped texture
    GL_LINEAR_MIPMAP_LINEAR  - BiLinear Mipmapped texture
  }

  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR); { only first two can be used }
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR); { all of the above can be used }

  if Format = GL_RGBA then
    gluBuild2DMipmaps(GL_TEXTURE_2D, GL_RGBA, Width, Height, GL_RGBA, GL_UNSIGNED_BYTE, pData)
  else
    gluBuild2DMipmaps(GL_TEXTURE_2D, 3, Width, Height, GL_RGB, GL_UNSIGNED_BYTE, pData);
//  glTexImage2D(GL_TEXTURE_2D, 0, 3, Width, Height, 0, GL_RGB, GL_UNSIGNED_BYTE, pData);  // Use when not wanting mipmaps to be built by openGL

  result :=Texture;
end;


{------------------------------------------------------------------}
{  Load BMP textures                                               }
{------------------------------------------------------------------}
function LoadBMPTexture(Filename: String; var Texture : GLuint; quality: GLint) : Boolean;
var
  FileHeader: BITMAPFILEHEADER;
  InfoHeader: BITMAPINFOHEADER;
  Palette: array of RGBQUAD;
  BitmapFile: THandle;
  BitmapLength: LongWord;
  PaletteLength: LongWord;
  ReadBytes: LongWord;
  Width, Height : Integer;
  pData : Pointer;

  // used for loading from resource
  //ResStream : TResourceStream;
begin
  result :=FALSE;
  BitmapFile := CreateFile(PChar(Filename), GENERIC_READ, FILE_SHARE_READ, nil, OPEN_EXISTING, 0, 0);
  if (BitmapFile = INVALID_HANDLE_VALUE) then
    raise Exception.Create('Error opening file "' + Filename + '"');
  // Get header information
  ReadFile(BitmapFile, FileHeader, SizeOf(FileHeader), ReadBytes, nil);
  ReadFile(BitmapFile, InfoHeader, SizeOf(InfoHeader), ReadBytes, nil);
  // Get palette
  PaletteLength := InfoHeader.biClrUsed;
  SetLength(Palette, PaletteLength);
  ReadFile(BitmapFile, Palette, PaletteLength, ReadBytes, nil);
  if (ReadBytes <> PaletteLength) then
     raise Exception.Create(Filename + ': error reading palette');
  Width  := InfoHeader.biWidth;
  Height := InfoHeader.biHeight;
  BitmapLength := InfoHeader.biSizeImage;
  if BitmapLength = 0 then
    BitmapLength := Width * Height * InfoHeader.biBitCount Div 8;

  // Get the actual pixel data
  GetMem(pData, BitmapLength);
  ReadFile(BitmapFile, pData^, BitmapLength, ReadBytes, nil);
  if (ReadBytes <> BitmapLength) then
    raise Exception.Create(FileName + ': error reading bitmap data');
  CloseHandle(BitmapFile);
  // Bitmaps are stored BGR and not RGB, so swap the R and B bytes.
  SwapRGB(pData, Width*Height);

  Texture :=CreateTexture(Width, Height, GL_RGB, pData, quality);
  FreeMem(pData);
  result :=TRUE;
end;


{------------------------------------------------------------------}
{  Load JPEG textures                                              }
{------------------------------------------------------------------}
function LoadJPGTexture(Filename: String; var Texture: GLuint; quality: GLint): Boolean;
var
  Data : Array of LongWord;
  W, Width : Integer;
  H, Height : Integer;
  BMP : TBitmap;
  JPG : TJPEGImage;
  C : LongWord;
  Line : ^LongWord;
  ResStream : TResourceStream;      // used for loading from resource
begin
  result :=FALSE;
  JPG:=TJPEGImage.Create;
  try
    JPG.LoadFromFile(Filename);
  except
     raise Exception.Create('Couldn''t load JPG - "'+ Filename +'"');
  end;
  // Create Bitmap
  BMP:=TBitmap.Create;
  BMP.pixelformat:=pf32bit;
  BMP.width:=JPG.width;
  BMP.height:=JPG.height;
  BMP.canvas.draw(0,0,JPG);        // Copy the JPEG onto the Bitmap
  //  BMP.SaveToFile('D:\test.bmp');
  Width :=BMP.Width;
  Height :=BMP.Height;
  SetLength(Data, Width*Height);
  For H:=0 to Height-1 do
  Begin
    Line :=BMP.scanline[Height-H-1];   // flip JPEG
    For W:=0 to Width-1 do
    Begin
      c:=Line^ and $FFFFFF; // Need to do a color swap
      Data[W+(H*Width)] :=(((c and $FF) shl 16)+(c shr 16)+(c and $FF00)) or $FF000000;  // 4 channel.
      inc(Line);
    End;
  End;

  BMP.free;
  JPG.free;

  Texture :=CreateTexture(Width, Height, GL_RGBA, addr(Data[0]), quality);
  result :=TRUE;
end;


{------------------------------------------------------------------}
{  Loads 24 and 32bpp (alpha channel) TGA textures                 }
{------------------------------------------------------------------}
function LoadTGATexture(Filename: String; var Texture: GLuint; quality: GLint): Boolean;
var
  TGAHeader : packed record   // Header type for TGA images
    FileType     : Byte;
    ColorMapType : Byte;
    ImageType    : Byte;
    ColorMapSpec : Array[0..4] of Byte;
    OrigX  : Array [0..1] of Byte;
    OrigY  : Array [0..1] of Byte;
    Width  : Array [0..1] of Byte;
    Height : Array [0..1] of Byte;
    BPP    : Byte;
    ImageInfo : Byte;
  end;
  TGAFile   : File;
  bytesRead : Integer;
  image     : Pointer;    {or PRGBTRIPLE}
  Width, Height : Integer;
  ColorDepth    : Integer;
  ImageSize     : Integer;
  I : Integer;
  Front: ^Byte;
  Back: ^Byte;
  Temp: Byte;

begin
  GetMem(Image, 0);
  AssignFile(TGAFile, Filename);
  Reset(TGAFile, 1);
  // Read in the bitmap file header
  BlockRead(TGAFile, TGAHeader, SizeOf(TGAHeader));
  Result :=FALSE;
  // Only support uncompressed images
  if (TGAHeader.ImageType <> 2) then  { TGA_RGB }
  begin
    Result := False;
    CloseFile(tgaFile);
    raise Exception.Create('Can`t open "' + Filename + '": compressed TGA not supported');
  end;
  // Don't support colormapped files
  if TGAHeader.ColorMapType <> 0 then
  begin
    Result := False;
    CloseFile(TGAFile);
    raise Exception.Create('Couldn''t load "'+ Filename +'". Colormapped TGA files not supported.');
  end;
  // Get the width, height, and color depth
  Width  := TGAHeader.Width[0]  + TGAHeader.Width[1]  * 256;
  Height := TGAHeader.Height[0] + TGAHeader.Height[1] * 256;
  ColorDepth := TGAHeader.BPP;
  ImageSize  := Width*Height*(ColorDepth div 8);

  if ColorDepth < 24 then
  begin
    Result := False;
    CloseFile(TGAFile);
    raise Exception.Create('Couldn''t load "'+ Filename +'". Only 24 bit TGA files supported.');
  end;

  GetMem(Image, ImageSize);

  BlockRead(TGAFile, image^, ImageSize, bytesRead);
  if bytesRead <> ImageSize then
  begin
    Result := False;
    CloseFile(TGAFile);
    raise Exception.Create('Couldn''t read file "'+ Filename +'".');
  end;
  // TGAs are stored BGR and not RGB, so swap the R and B bytes.
  // 32 bit TGA files have alpha channel and gets loaded differently
  if TGAHeader.BPP = 24 then
  begin
    for I :=0 to Width * Height - 1 do
    begin
      Front := Pointer(Integer(Image) + I*3);
      Back := Pointer(Integer(Image) + I*3 + 2);
      Temp := Front^;
      Front^ := Back^;
      Back^ := Temp;
    end;
    Texture :=CreateTexture(Width, Height, GL_RGB, Image, quality);
  end
  else
  begin
    for I :=0 to Width * Height - 1 do
    begin
      Front := Pointer(Integer(Image) + I*4);
      Back := Pointer(Integer(Image) + I*4 + 2);
      Temp := Front^;
      Front^ := Back^;
      Back^ := Temp;
    end;
    Texture :=CreateTexture(Width, Height, GL_RGBA, Image, quality);
  end;
  Result :=TRUE;
  FreeMem(Image);
end;


{------------------------------------------------------------------}
{  Determines file type and sends to correct function              }
{------------------------------------------------------------------}
function LoadTexture(Filename: String; var Texture : GLuint; qual: GLint) : Boolean;
begin
  if copy(Uppercase(filename), length(filename)-3, 4) = '.BMP' then
    LoadBMPTexture(Filename, Texture, qual);
  if copy(Uppercase(filename), length(filename)-3, 4) = '.JPG' then
    LoadJPGTexture(Filename, Texture, qual);
  if copy(Uppercase(filename), length(filename)-3, 4) = '.TGA' then
    LoadTGATexture(Filename, Texture, qual);
end;


end.

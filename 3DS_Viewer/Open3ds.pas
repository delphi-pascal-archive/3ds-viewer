{
    Dmytro Sirenko, Kyiv, Nov 2008
	dmytrish@ukr.net, ICQ 350799719
    unit for loading and rendering (OpenGL1.0) 3ds models
    meshes, materials, textures are available
    warning: this code contains a lot of bugs!
             some files shut program down arbitrarily!
}

unit Open3ds;
interface

uses OpenGL, Classes;
const
 ERROR_TEX = $FFFF;
 // CHUNKS
 MAIN_CHUNK = $4D4D;
  // sub MAIN chunks
  EDIT3DS = $3D3D;
   EDIT_MATERIAL = $AFFF;
    MAT_NAME = $A000;
    MAT_AMBIENT = $A010;
    MAT_DIFFUSE = $A020;
    MAT_SPECULAR = $A030;
    MAT_SHININESS = $A040;
    MAT_SHIN2PCT = $A041;
    MAT_SHIN3PCT = $A042;
    MAT_TRANSPARENCY = $A050;
    MAT_XPFALL = $A052;
    MAT_TWO_SIDED = $A081;
    MAT_SELF_ILPCT = $A084;
    MAT_WIRE = $A085;
    MAT_WIRESIZE = $A087;
    MAT_XPFALLIN = $A08A;
    MAT_TEXMAP = $A200;
     MAT_MAPNAME = $A300;
     MAT_MAP_TILING =$A351;
    MAT_SHADING = $A100;
    MAT_REFL_BLUR = $A053;
   EDIT_CONFIG = $3E3D;
   EDIT_CONFIG1 = $0100;
   EDIT_VIEWPORT1 = $7012;
    VP_TOP = $0001;
    VP_BOTTOM = $0002;
    VP_LEFT = $0003;
    VP_RIGHT = $0004;
    VP_FRONT = $0005;
   //... and such stuff goes on...
   EDIT_OBJECT = $4000;
    EDIT_OBJ_TRIMESH = $4100;
     TRI_VERTEX_LIST = $4110;
     TRI_FACE_LIST = $4120;
     TRI_MESH_MTRGROUP = $4130;
     TRI_TEXVERTS = $4140;
     TRI_SMOOTHGROUPS = $4150;
     TRI_LOCAL_AXES = $4160;
  KEYF3DS = $B000;
  COLOR_FLOAT = $0010;
  COLOR_UBYTE = $0011;

type TGLMatrix = array [0..3, 0..3] of GLfloat;
     TArray3ub = array [0..2] of GLubyte;
     pArray3f = ^TGLArrayf3;

const EMatrix: TGLMatrix =
    ( (1, 0, 0, 0),
      (0, 1, 0, 0),
      (0, 0, 1, 0),
      (0, 0, 0, 1)
    );

type
  T3DSTexture = record
    tex_num: GLuint;
    map_tiling_flags: GLushort;
    path, error: string;
  end;
  p3DSTexture = ^T3DSTexture;

  TMaterial = record
    name: string;
    //---------
    amb, spec, dif: TGLArrayf4;
    shininess, transparency, shading: GLushort;
    reflblur, self_ilum: GLushort;
    twosided, wired: boolean;
    wiresize: GLfloat;
    texture: p3DSTexture;
   end;
  pMaterial = ^TMaterial;

  TMaterials = class
   private
    current: GLshort;
    mcount: GLushort;
    mtrls: array of pMaterial;
    function get_by_index(index: GLushort): pMaterial;
   public
    property count: GLushort read mcount;
    property material[index: GLushort]: pMaterial read get_by_index;
    constructor create();
    function last: pMaterial;
    function get_index_of(mname: string): GLshort;
    procedure add(mname: string);
    procedure set_material(index: GLushort);
    procedure clear();
    destructor destroy; override;
  end;

  TObjectNode = record
    name: string;
    pcount, fcount: GLushort;
    points: array of array [0..2] of GLfloat;
    faces: array of array [0..2] of GLushort;
    normal: array of array [0..2] of GLfloat;
    tex_verts: array of array [0..1] of GLfloat;
    mtr_faces: array of GLubyte;
    matrix: TGLMatrix;
    //
    hidden, uses_texverts, uses_mtr_faces, uses_smoothing: boolean;
   end;
  pObjectNode = ^TObjectNode;

  T3DSModel = class
  private
    ocount: GLushort;
    objs: array of TObjectNode;
    procedure add_object(oname: string);
    function get_object(i: GLushort): pObjectNode;
  public
    materials: TMaterials;
    error_list: TStringList;
    property count: GLushort read ocount;
    property objects[i: GLushort]: pObjectNode read get_object;
    procedure load(fname: string);
    procedure draw();
    constructor create();
    destructor destroy();
  end;

implementation

uses SysUtils, Textures;

function ReadASCIIZ(var F: TFileStream): string;
 var lchar: char;
     res: string;
begin
 res:='';
 f.Read(lchar, 1);
 while (lchar <> #0) do
  begin
   res:=res + lchar;
   f.Read(lchar, 1);
  end;
 Result:=res;
end;

function ReadColorChunk(var f: TFileStream): TGLArrayf4;
 var Rf, Gf, Bf: GLfloat;
     Rub, Gub, Bub: GLubyte;
     chunk_id: GLushort;
     chunk_length: GLuint;
begin
 Rub:=0; Gub:=0; Bub:=0;
 f.Read(chunk_id, 2);
 f.Read(chunk_length, 4);
 case chunk_id of
  COLOR_FLOAT:
   begin
    f.Read(Rf, 4);
    f.Read(Gf, 4);
    f.Read(Bf, 4);
   end;
  COLOR_UBYTE:
   begin
    f.Read(Rub, 1);
    f.Read(Gub, 1);
    f.Read(Bub, 1);
    Rf:=Rub/255;
    Gf:=Gub/255;
    Bf:=Bub/255;
   end;
  else f.Seek(chunk_length-6, soFromCurrent);
 end;
 Result[0]:=Rf;
 Result[1]:=Gf;
 Result[2]:=Bf;
 Result[3]:=1.0;
end;

function get_normal(v1, v2, v3: TGLArrayf3): pArray3f;
begin
 Result[0]:=(v2[1] - v1[1])*(v3[2] - v1[2]) - (v2[2] - v1[2])*(v3[1] - v1[1]);
 Result[1]:=(v2[2] - v1[2])*(v3[0] - v1[0]) - (v2[0] - v1[0])*(v3[2] - v1[2]);
 Result[2]:=(v2[0] - v1[0])*(v3[1] - v1[1]) - (v2[1] - v1[1])*(v3[0] - v1[0]);
end;

{ TMaterials }

procedure TMaterials.add(mname: string);
begin
 inc(mcount);  SetLength(mtrls, mcount);
 New(mtrls[mcount-1]);
 with mtrls[mcount-1]^ do
 begin
  reflblur:=0;
  shininess:=0;
  transparency:=0;
  shading:=0;
  self_ilum:=0;
  twosided:=false;
  wired:=false;
  texture:=NIL;
  name:=mname;
 end;
end;

procedure TMaterials.clear;
 var i: GLshort;
begin
 for i:=0 to mcount-1 do
  begin
   if mtrls[i].texture <> NIL then FreeMem(mtrls[i].texture);
   FreeMem(mtrls[i]);
  end;
 mcount:=0; SetLength(mtrls, mcount);
 current:=-1;
end;

constructor TMaterials.create;
begin
 inherited;
 mcount:=0;
 SetLength(mtrls, mcount);
 current:=-1;
end;

destructor TMaterials.destroy;
begin
 clear();
 inherited;
end;

function TMaterials.get_by_index(index: GLushort): pMaterial;
begin
 if index < mcount then Result:=mtrls[index]
 else raise EAccessViolation.Create('Incorrect index of material '+IntToStr(index));
end;

function TMaterials.get_index_of(mname: string): GLshort;
 var i: GLshort;
begin
 i:=mcount-1;
 while i >= 0 do
  begin
   if mtrls[i].name = mname then break;
   dec(i);
  end;
 Result:=i;
end;

function TMaterials.last: pMaterial;
begin
 if mcount = 0 then Result:=NIL else Result:=mtrls[mcount-1];
end;

procedure TMaterials.set_material(index: GLushort);
 var GLface: GLenum;
begin
 if current > -1 then
  if (material[current].texture <> NIL)
   then glEnable(GL_TEXTURE_2D) else glDisable(GL_TEXTURE_2D)
 else glDisable(GL_TEXTURE_2D);
 if index = current then exit;
 current:=index;
 with mtrls[index]^ do
  begin
   if twosided
    then GLface:=GL_FRONT_AND_BACK
    else GLface:=GL_FRONT;
   glMaterialfv(GLface, GL_AMBIENT, @amb);
   glMaterialfv(GLface, GL_DIFFUSE, @dif);
   glMaterialfv(GLface, GL_SPECULAR, @spec);
   glMaterialf(GLface, GL_SHININESS, shininess/100);    //}
   if transparency <> 0 then
    begin
     glEnable(GL_BLEND);
     glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    end;
   if texture <> NIL then
    begin
     glBindTexture(GL_TEXTURE_2D, texture.tex_num);
     glEnable(GL_TEXTURE_2D);
    end
   else glDisable(GL_TEXTURE_2D);
   {if wired
    then
     begin
      glPolygonMode(GLface, GL_LINE);
      glLineWidth(wiresize);
     end
    else glPolygonMode(GLface, GL_FILL);//}
  end;
end;

{ T3DSModel }

constructor T3DSModel.create;
begin
 error_list:=TStringList.create;
 error_list.Clear;
 ocount:=0; SetLength(objs, ocount);
 materials:=TMaterials.create();
end;

procedure T3DSModel.add_object(oname: string);
begin
 inc(ocount); SetLength(objs, ocount);
 with objs[ocount-1] do
  begin
   name:=oname;
   pcount:=0; SetLength(points, pcount); SetLength(tex_verts, pcount);
   fcount:=0; SetLength(faces, fcount); SetLength(mtr_faces, fcount);
   hidden:=false;
   uses_texverts:=false;
   uses_mtr_faces:=false;
   uses_smoothing:=false;
   matrix:=EMatrix;
  end;
end;

procedure T3DSModel.load(fname: string);
 var f: TFileStream;
     chunk_id, qty, flags, nfaces: GLushort;
     chunk_length: GLuint;
     col: TArray3ub;
     i, j, mat_index: GLshort;
     flTemp: GLfloat;
     usTemp: GLushort;

     dx21, dx31, dy21, dy31, dz31, dz21: GLfloat;
begin
 if ocount <> 0 then
  begin ocount:=0; SetLength(objs, ocount) end;
 materials.clear();
 error_list.Clear();
 //
 if fname = '' then exit; // T3DSModel.load('') == .clear();
 f:=TFileStream.Create(fname, fmOpenRead);
 // Main chunk
 f.Read(chunk_id, 2);
 f.Read(chunk_length, 4);
 if (chunk_id <> $4D4D) then
  begin
   f.Destroy;
   raise Exception.Create('File '+fname+' is not valid 3DS file');
  end;
 // Content
 while f.Position < f.Size do
  begin
   f.Read(chunk_id, 2);
   f.Read(chunk_length, 4);
   case chunk_id of
    MAIN_CHUNK, EDIT3DS, EDIT_OBJ_TRIMESH: ;
    EDIT_MATERIAL:
     begin
      //if materials = NIL then materials:=TMaterials.create;
     end;

    //  ---------------
    //  -- Materials --
    //  ---------------
    MAT_NAME:
     begin
      if materials <> NIL
       then materials.add(ReadASCIIZ(f))
       else raise EAccessViolation.Create('NIL error: MAT_NAME');
     end;
    MAT_AMBIENT:
      if materials <> NIL
       then materials.last^.amb:=ReadColorChunk(f)
       else EAccessViolation.Create('NIL error: MAT_AMBIENT');
    MAT_DIFFUSE:
      if materials <> NIL
       then materials.last^.dif:=ReadColorChunk(f)
       else EAccessViolation.Create('NIL error: MAT_DIFFUSE');
    MAT_SPECULAR:
      if materials <> NIL
       then materials.last^.spec:=ReadColorChunk(f)
       else EAccessViolation.Create('NIL: MAT_SPECULAR');
    MAT_SHININESS:
     begin
      f.Read(chunk_id, 2);
      f.Read(chunk_length, 4);
      f.Read(materials.last^.shininess, 2);
     end;
    MAT_TRANSPARENCY:
     begin
      f.Read(chunk_id, 2);
      f.Read(chunk_length, 4);
      f.Read(materials.last^.transparency, 2);
     end;
    MAT_SHADING:
     f.Read(materials.last^.shading, 2);
    MAT_REFL_BLUR:
     begin
      f.Read(chunk_id, 2);
      f.Read(chunk_length, 4);
      f.Read(materials.last^.reflblur, 2);
     end;
    MAT_TWO_SIDED:
     if materials <> NIL
      then materials.last^.twosided:=true
      else EAccessViolation.Create('NIL: MAT_TWO_SIDED');
    MAT_SELF_ILPCT:
     begin
      f.Read(chunk_id, 2);
      f.Read(chunk_length, 4);
      f.Read(materials.last^.self_ilum, 2);
     end;
    MAT_XPFALLIN:
     begin
     // empty
     end;
    MAT_XPFALL:
     begin
      f.Read(chunk_id, 2);
      f.Read(chunk_length, 4);
      f.Read(usTemp, 2);
     end;
    MAT_SHIN2PCT:
     begin
      f.Read(chunk_id, 2);
      f.Read(chunk_length, 4);
      f.Read(usTemp, 2);
     end;    //}
    MAT_WIRESIZE:
      f.Read(materials.last^.wiresize, 4);
    MAT_TEXMAP:  // SUPERCHUNK
     begin
      f.Read(chunk_id, 2);
      f.Read(chunk_length, 4);
      f.Read(usTemp, 2);
      with materials.last^ do
       begin
        New(texture);
        texture.tex_num:=$FFFF;
        texture.path:='';
        texture.error:='';
       end;
     end;
     // Subchunks of MAT_TEXMAP
     MAT_MAPNAME:
     with materials.last^.texture^ do
      begin
       path:=ReadASCIIZ(f);
       tex_num:=$AFFF
      end;
     MAT_MAP_TILING:
       f.Read(materials.last^.texture.map_tiling_flags, 2);
    // *)
    //  -------------------------------------------
    //  ---------------- MESHES --------------------
    //  ---------------------------------------------

    EDIT_OBJECT:
     begin
      add_object(ReadASCIIZ(f));
     end;
    TRI_VERTEX_LIST:
    with objs[ocount-1] do
     begin
      f.Read(qty, 2);
      pcount:=qty; SetLength(points, pcount);
      for i:=0 to qty-1 do
       begin
        f.Read(points[i][0], sizeof(GLfloat));
        f.Read(points[i][1], sizeof(GLfloat));
        f.Read(points[i][2], sizeof(GLfloat));
       end;
      end;
    TRI_TEXVERTS:
     with objs[ocount-1] do
      begin
       uses_texverts:=true;
       f.Read(qty, 2); SetLength(tex_verts, qty);
       for i:=0 to qty-1 do
        begin
         f.Read(tex_verts[i][0], sizeof(GLfloat));
         f.Read(tex_verts[i][1], sizeof(GLfloat));
        end;
      end;
    TRI_MESH_MTRGROUP:
    with objs[ocount-1] do
     begin
      uses_mtr_faces:=true;               // index of current material
      SetLength(mtr_faces, fcount); // else (in case this chunk is absent) length(mtr_faces) = 0
      mat_index:=materials.get_index_of(ReadASCIIZ(f));
      f.Read(nfaces, 2);  // count of belonging to it vertices - for reading only
      for i:=0 to nfaces-1 do
       begin
        f.Read(usTemp, 2);
        mtr_faces[usTemp]:=mat_index;
       end;
    end;
    {TRI_SMOOTHGROUPS:
     begin
      // hfaces * 4(long int)

     end;    //}
    TRI_FACE_LIST:
     with objs[ocount-1] do
      begin
       f.Read(qty, 2);
       fcount:=qty; SetLength(faces, fcount);
       for i:=0 to qty-1 do
        begin
         f.Read(faces[i][0], sizeof(GLushort));
         f.Read(faces[i][1], sizeof(GLushort));
         f.Read(faces[i][2], sizeof(GLushort));
         f.Read(flags, sizeof(GLushort));
        end;
      end;
     TRI_LOCAL_AXES:
     with objs[ocount-1] do
      begin
       for i:=0 to 3 do matrix[i, 3]:=0.0;
       for i:=0 to 2 do
        for j:=0 to 2 do
         f.Read(matrix[j][i], sizeof(GLfloat));
       for i:=0 to 2 do f.Read(matrix[3, i], sizeof(GLfloat))
      end;
    else f.Seek(chunk_length - 6, soFromCurrent);
   end;
  end;
 f.Destroy;
 // Texture loading
 for i:=0 to materials.count-1 do
   with materials.material[i]^ do
    if texture <> NIL then
     if FileExists(texture.path)
      then
       try LoadTexture(texture.path, texture.tex_num);
       except on E: Exception do
        begin
         texture.error:=E.Message;
         texture.tex_num:=ERROR_TEX;
        end;
       end
      else texture.tex_num:=ERROR_TEX;
 // normals calculation
 for i:=0 to ocount-1 do
  with objs[i] do
   begin
    SetLength(normal, fcount);
    for j:=0 to fcount-1 do
     begin
       dx21:=points[faces[j][1]][0] - points[faces[j][0]][0];
       dx31:=points[faces[j][2]][0] - points[faces[j][0]][0];
       dy21:=points[faces[j][1]][1] - points[faces[j][0]][1];
       dy31:=points[faces[j][2]][1] - points[faces[j][0]][1];
       dz21:=points[faces[j][1]][2] - points[faces[j][0]][2];
       dz31:=points[faces[j][2]][2] - points[faces[j][0]][2];
       normal[j][0]:=dy21*dz31 - dz21*dy31;
       normal[j][1]:=dz21*dx31 - dx21*dz31;
       normal[j][2]:=dx21*dy31 - dx31*dy21;
       flTemp:=sqrt(sqr(normal[j][0])+sqr(normal[j][1])+sqr(normal[j][2]));
       normal[j][0]:=normal[j][0]/flTemp;
       normal[j][1]:=normal[j][1]/flTemp;
       normal[j][2]:=normal[j][2]/flTemp;
     end;
   end;
end;

destructor T3DSModel.destroy;
begin
 ocount:=0; SetLength(objs, ocount);
 materials.destroy;
 inherited destroy;
end;

function T3DSModel.get_object(i: GLushort): pObjectNode;
begin Result:=@objs[i] end;

procedure T3DSModel.draw;
 var i, j: integer;
begin
 error_list.Clear;
 glEnable(GL_NORMALIZE);
 for j:=0 to ocount-1 do
  try with objs[j] do
   begin
    if hidden then continue;
    glPushMatrix();
    //glMultMatrixf(@matrix);
    glTranslatef(matrix[3, 0], matrix[3, 1], matrix[3, 2]);
    glBegin(GL_TRIANGLES);
    if uses_texverts then
     for i:=0 to fcount-1 do
      begin
       if uses_mtr_faces and (materials.count > 0) and (materials.current <> mtr_faces[i]) then
       try
        materials.set_material(mtr_faces[i]);
        glEnd();
        glBegin(GL_TRIANGLES);
       except
        on EAccessViolation do
         error_list.Add('<' + name + '>: Access error or can`t set material ' + materials.material[i].name);
       end;
       try
       glNormal3fv(@normal[i]);
       glTexCoord2fv(@tex_verts[faces[i][0]]);
       glVertex3fv(@points[faces[i][0]]);
       glTexCoord2fv(@tex_verts[faces[i][1]]);
       glVertex3fv(@points[faces[i][1]]);
       glTexCoord2fv(@tex_verts[faces[i][2]]);
       glVertex3fv(@points[faces[i][2]]);
       except on EAccessViolation do
        error_list.Add('Object ' + name +
            ': in Verts/TexVerts/Normal['+ IntToStr(i) + ']')
       end;
      end
    else
     for i:=0 to fcount-1 do
      begin
       if uses_mtr_faces and (materials.count > 0) and (materials.current <> mtr_faces[i]) then
       try
        materials.set_material(mtr_faces[i]);
        glEnd();
        glBegin(GL_TRIANGLES);
       except
        on EAccessViolation do
         error_list.Add('<' + name + '>: Access error or can`t set material ' + materials.material[i].name);
       end;
       try
       glNormal3fv(@normal[i]);
       glVertex3fv(@points[faces[i][0]]);
       glVertex3fv(@points[faces[i][1]]);
       glVertex3fv(@points[faces[i][2]]);
       except on EAccessViolation do
        error_list.Add('Object ' + name +
            ': in Verts/TexVerts/Normal['+ IntToStr(i) + ']')
       end;
      end;
    glEnd;
    glPopMatrix();
   end;
 except error_list.Add('Object access error: object[' + IntToStr(j) +']'); end;
end;

end.

{Yuriy Manyak, KA-23, IASA}
unit Sprt;

interface
uses
   crt, dos, BMP, mouse;

const
   screenheight = 200;
   screenwidth = 320;
   maxinpal = 768;
   defTransC = $0;

type
   TArr = array[0..0] of byte;
   PArr = ^TArr;
   TScreen = array[0..screenheight - 1, 0..screenwidth - 1] of byte;
   TPalette = array[0..maxinpal - 1] of byte;

   TEngine = object
      private
         Screen: ^TScreen;
         Palette: TPalette;
      public
         constructor Init(const filedest: string);
         procedure InitPal(const filedest: string);
         procedure SetEmptyPal;
         procedure Smooth;
         procedure SmoothDying;
         procedure PutPoint(x, y, col: integer);
         destructor Finish;
   end;

   TSprite = object
      private
         Image, Buffer: PArr;
         width, height, x, y: integer;
         transC: integer;
      public
         Palette: TPalette;
         constructor Create(const filedest: string; _x, _y, _width, _height: integer);
         procedure ReadFromFile(const filedest: string);
         procedure SetXY(_x, _y: integer);
         function GetX: integer;
         function GetY: integer;
         function GetWidth: integer;
         function GetHeight: integer;
         procedure SetTransC(newTransC: integer);
         procedure Draw(const Engine: TEngine);
         procedure SaveBack(const Engine: TEngine);
         procedure PutBack(const Engine: TEngine);
         procedure Donate;
         destructor Destroy; virtual;
      end;

      procedure BackGr(const Engine: TEngine);
      procedure Wait(number: integer);
      procedure ReadHeader(const filedest: string; var Header: BMPHeader);
      procedure Line(const Engine: TEngine; x0, y0, x, y: integer; col: integer);
      procedure swap(var a, b: integer);
      function Dist(x1, y1, x2, y2: real): real;
      function sgn(x: real): integer;
      function inttostr(a: integer): string;
      procedure InstallPalette(var firstbyte: byte; number, len:integer);
{$R-}

implementation


   procedure TEngine.SetEmptyPal;
   var
      P: TPalette;
      i: integer;
   begin
      for i := 0 to maxinpal - 1 do
         P[i] := 0;
      InstallPalette(P[0], 0, 256);
   end;

   procedure TEngine.Smooth;
   var
      index, shade: integer;
      P: TPalette;

   begin
      for shade := 0 to 63 do
      begin
         for index := 0 to maxinpal - 1 do
            P[index] := round(Palette[index] * shade / 63);
         Wait(3000);
         InstallPalette(P[0], 0, 256);
      end;
   end;

   procedure TEngine.SmoothDying;
   var
      index, shade: integer;
      P: TPalette;

   begin
      for shade := 63 downto 0 do
      begin
         for index := 0 to maxinpal - 1 do
            P[index] := round(Palette[index] * shade / 63);
         Wait(3000);
         InstallPalette(P[0], 0, 256);
      end;
   end;

   procedure TSprite.SetTransC;
   begin
      if (newTransC = -1) then
         self.TransC := self.Image^[0]
      else
         self.TransC := newTransC;
   end;

   function Dist(x1, y1, x2, y2: real): real;
   begin
      Dist := sqrt(sqr(x1 - x2) + sqr(y1 - y2));
   end;

   function sgn(x: real): integer;
   begin
      if (x > 0) then
         sgn := 1
      else
      if (x < 0) then
         sgn := -1
      else
         sgn := 0;
   end;

   procedure swap(var a, b: integer);
   var
      c: integer;
   begin
      c := a;
      a := b;
      b := c;
   end;

   procedure Line(const Engine: TEngine; x0, y0, x, y: integer; col: integer);
   var
      k: real;
      i: integer;

   begin
      if (x0 > x) then
      begin
         swap(x0, x);
         swap(y0, y);
      end;
      if (x0 = x) then
      with Engine do
      begin
         if (y < y0) then
            swap(y, y0);
         for i := y0 to y do
            PutPoint(x0, i, col);
      end
      else
      with Engine do
      begin
         k := (y - y0) / (x - x0);
         for i := x0 to x do
            PutPoint(i, round(x0 + k * (i - x0)), col);
      end;
   end;


   procedure ConversePal(const Header: BMPHeader; var Palette: TPalette);
   var
      i, j: integer;
   begin
      for i := 0 to 255 do
         for j := 0  to 2 do
            Palette[i * 3 + j] := Header.Pal[i, 2 - j] div 4;
   end;

   procedure ReadHeader(const filedest: string; var Header: BMPHeader);
   var
      f: file;
   begin
      assign(f, filedest);
      reset(f, 1);
      blockread(f, Header, sizeof(Header));
      seek(f, 0);
      close(f);
   end;

   procedure TEngine.PutPoint;
   begin
      Self.Screen^[x, y] := col;
   end;

   constructor TEngine.Init;
   var
      r: registers;
   begin
      r.ax := $13;
      intr($10, r);
      Self.Screen := ptr(SegA000, 0);
      LimVer(180, 0);
      LimHor(600, 10);
      if (filedest <> '') then
         Self.InitPal(filedest);
   end;

   destructor TEngine.Finish;
   var
      r: registers;
   begin
      LimHor(640, 0);
      LimVer(240, 0);
      r.ax := $3;
      intr($10, r);
   end;

   procedure InstallPalette(var firstbyte: byte; number, len:integer);
   var
      r: registers;
   begin
      r.ax := $1012;
      r.bx := number;
      r.cx := len;
      r.dx := ofs(firstbyte);
      r.es := seg(firstbyte);
      intr($10,r);
   end;

   procedure TEngine.InitPal;
   var
      Header: BMPHeader;
   begin
      ReadHeader(filedest, Header);
      ConversePal(Header, self.Palette);
      InstallPalette(self.Palette[0], 0, 256);
   end;

   function TSprite.GetX;
   begin
      GetX := self.x;
   end;

   function TSprite.GetY;
   begin
      GetY := self.y;
   end;

   function TSprite.GetHeight;
   begin
      GetHeight := self.height;
   end;

   function TSprite.GetWidth;
   begin
      GetWidth := self.width;
   end;

   procedure GetPalette(var firstbyte: byte; number, len:integer);
   var
      r: registers;
   begin
      r.ax := $1017;
      r.bx := number;
      r.cx := len;
      r.dx := ofs(firstbyte);
      r.es := seg(firstbyte);
      intr($10,r);
   end;

   procedure TSprite.SetXY;
   begin
      self.x := _x;
      self.y := _y;
   end;

   procedure Wait;
   var i: integer;
   begin
      for i := 1 to number do
         while (port[$3da] and 8) = 0 do;
   end;

   constructor TSprite.Create;
   begin
      self.x := _x;
      self.y := _y;
      self.TransC := defTransC;
      self.width := _width;
      self.height := _height;
      Self.ReadFromFile(filedest);
   end;

   procedure TSprite.ReadFromFile;
   var
      f: file;
      Header: BMPHeader;
      i, j: integer;
      temp: longint;

   begin
      assign(f, filedest);
      reset(f, 1);
      blockread(f, Header, sizeof(Header));

      if (self.width = -1) or (self.height = -1) then
      begin
         self.width := Header.width;
         self.height := Header.height;
      end;

      with Self do
      begin
         getmem(Image, width * height);
         getmem(Buffer, width * height);
      end;

      for i := 0 to self.height - 1 do
      begin
         blockread(f, self.Image^[(self.height - 1 - i)
                                       * self.width], self.width);
         if (self.width mod 4 <> 0) then
            blockread(f, temp, 4 - (self.width mod 4));
      end;
      seek(f, 0);
      close(f);

      ConversePal(Header, self.Palette);
   end;


   destructor TSprite.Destroy;
   begin
      with Self do
      begin
         freemem(Image, width * height);
         freemem(Buffer, width * height);
         Image := NIL;
         Buffer := NIL;
      end;
   end;

   procedure TSprite.SaveBack;
   var
      i, j: word;
   begin
      with Self do
      for j := 0 to height - 1 do
       for i := 0 to width - 1 do
          Buffer^[j * width + i] := Engine.Screen^[j + y, i + x];
   end;

   procedure TSprite.PutBack;
   var
      i, j: word;
   begin
      Wait(1);
      with Self do
      for j := 0 to height - 1 do
       for i := 0 to width - 1 do
          Engine.Screen^[j + y, i + x] := Buffer^[j * width + i];
   end;

   procedure TSprite.Draw;
   var
      i, j: word;
   begin
      with Self do
      for j := 0 to height - 1 do
      begin
         Wait(1);
         for i := 0 to width - 1 do
            if Image^[j * width + i] <> Self.TransC then
               Engine.Screen^[j + y, i + x] := Image^[j * width + i];
      end;
   end;

   procedure TSprite.Donate;
   begin
      InstallPalette(self.Palette[0], 0, 256);
   end;

   procedure BackGr(const Engine: TEngine);
   var
      i, j: integer;
   begin
      Wait(1);
      for j := 0 to screenheight - 1 do
         for i := 0 to screenwidth - 1 do
             Engine.Screen^[j, i] := $0;
   end;

   function inttostr(a: integer): string;
   var
      s: string;
   begin
      str(a, s);
      inttostr := s;
   end;
end.
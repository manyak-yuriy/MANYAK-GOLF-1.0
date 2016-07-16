unit Fields;

interface

uses Sprt, crt, mouse, BMP;
const
   fieldmaxx = 15;
   fieldmaxy = 9;

   koef = 0.003;
   disp = 0.0001;
   frict = 0.001;
   timeout = 50;
   splashtimeout = 30000;
   finaltimeout = 30000;
   acc = 0.0002;
   holeradius = 8;
   maxspeed = 1;

type
   TField = object
      private
         Stone, Ball, Stick, Box, Grass, Water, Hole: TSprite;
         Left, Right, Down, Up: TSprite;
         Left_h, Right_h, Down_h, Up_h: TSprite;

         ballx, bally: real;
         ballvx, ballvy: real;

         attempt: integer;

         Map: array[-1..fieldmaxx + 1, -1..fieldmaxy + 1] of char;

      public
         constructor Create(const source: string; const Engine: TEngine);
         procedure MoveStick(const Engine: TEngine);
         function CheckAcc(const Engine: TEngine): boolean;
         function Exec(const Engine: TEngine): integer;
         function Collide: boolean;
         function AngularCollide(x, y: integer): boolean;
         procedure ShowSplash(x, y: integer; const Engine: TEngine);
         procedure ShowFinal(x, y: integer; const Engine: TEngine);
         procedure DisHigh(const Engine: TEngine);
         destructor Destroy;
   end;

implementation

procedure GetIndexes(var x, y: integer);
begin
   x := x div 20;
   y := y div 20;
end;

procedure TField.ShowSplash;
var
   i: integer;
   Sprite: TSprite;

begin
   Ball.PutBack(Engine);
   for i := 0 to 2 do
   begin
      Sprite.Create('splash\'+ inttostr(i + 1) + '.bmp', 1, 1, -1, -1);
      Sprite.SetXY(x * 20, y * 20);
      Sprite.SaveBack(Engine);
      Sprite.Draw(Engine);
      Wait(splashtimeout);
      Sprite.PutBack(Engine);
      Sprite.Destroy;
   end;
end;

procedure TField.ShowFinal;
var
   i: integer;
   Sprite: TSprite;

begin
   Self.Ball.PutBack(Engine);
   for i := 1 to 3 do
   begin
      Sprite.Create('finish\fin_' + inttostr(i) + '.bmp', 1, 1, -1, -1);
      Sprite.SetXY(20 * x, 20 * y);
      Sprite.SaveBack(Engine);
      Sprite.Draw(Engine);
      Wait(finaltimeout);
      Sprite.PutBack(Engine);
      Sprite.Destroy;
   end;
end;

procedure TField.DisHigh;
var
   i, j: integer;

begin
   for i := 0 to fieldmaxx do
      for j := 0 to fieldmaxy do
      case (map[i, j]) of
      'U':
      begin
         map[i, j] := 'u';
         Ball.PutBack(Engine);
         Up.SetXY(20 * i, 20 * j);
         Up.Draw(Engine);
         Ball.SaveBack(Engine);
         Ball.Draw(Engine);
      end;
      'D':
      begin
         map[i, j] := 'd';
         Ball.PutBack(Engine);
         Down.SetXY(20 * i, 20 * j);
         Down.Draw(Engine);
         Ball.SaveBack(Engine);
         Ball.Draw(Engine);
      end;
      'L':
      begin
         map[i, j] := 'l';
         Ball.PutBack(Engine);
         Left.SetXY(20 * i, 20 * j);
         Left.Draw(Engine);
         Ball.SaveBack(Engine);
         Ball.Draw(Engine);
      end;
      'R':
      begin
         map[i, j] := 'r';
         Ball.PutBack(Engine);
         Right.SetXY(20 * i, 20 * j);
         Right.Draw(Engine);
         Ball.SaveBack(Engine);
         Ball.Draw(Engine);
      end
   end;

end;

function TField.CheckAcc;
var
   i, j: integer;
   flag: boolean;
   Sprite: TSprite;

begin
   i := round(ballx);
   j := round(bally);
   GetIndexes(i, j);
   flag := true;
   case (map[i, j]) of
      'u':
      begin
         map[i, j] := 'U';
         Ball.PutBack(Engine);
         Up_h.SetXY(20 * i, 20 * j);
         Up_h.Draw(Engine);
         Ball.SaveBack(Engine);
         Ball.Draw(Engine);
         self.ballvy := self.ballvy - acc;
      end;
      'U':
         self.ballvy := self.ballvy - acc;
      'd':
      begin
         map[i, j] := 'D';
         Ball.PutBack(Engine);;
         Down_h.SetXY(20 * i, 20 * j);
         Down_h.Draw(Engine);;
         Ball.SaveBack(Engine);;
         Ball.Draw(Engine);;
         self.ballvy := self.ballvy + acc;
      end;
      'D':
         self.ballvy := self.ballvy + acc;
      'l':
      begin
         map[i, j] := 'L';
         Ball.PutBack(Engine);;
         Left_h.SetXY(20 * i, 20 * j);
         Left_h.Draw(Engine);;
         Ball.SaveBack(Engine);;
         Ball.Draw(Engine);;
         self.ballvx := self.ballvx - acc;
      end;
      'L':
         self.ballvx := self.ballvx - acc;
      'r':
      begin
         map[i, j] := 'R';
         Ball.PutBack(Engine);;
         Right_h.SetXY(20 * i, 20 * j);
         Right_h.Draw(Engine);;
         Ball.SaveBack(Engine);;
         Ball.Draw(Engine);;
         self.ballvx := self.ballvx + acc;
      end;
      'R':
         self.ballvx := self.ballvx + acc;
      else
      begin
         flag := false;
      end;
   end;
   CheckAcc := flag;
end;

function TField.AngularCollide(x, y: integer): boolean;
var
   ballcx, ballcy, ballradius: real;
   v, D: real;
   sinphi, cosphi, a, sina, cosa, sino, coso: real;

begin
   ballcx := Self.Ball.GetX - 1 + Self.Ball.GetWidth / 2;
   ballcy := Self.Ball.GetY - 1 + Self.Ball.GetHeight / 2;

   D := Dist(x, y, ballcx, ballcy);
   ballradius := Self.Ball.GetWidth / 2 + 0.5;
   if (D > ballradius) then
   begin
      AngularCollide := false;
      exit;
   end;

   v := sqrt(sqr(self.ballvx) + sqr(self.ballvy));
   if (v = 0) then
   begin
      AngularCollide := false;
      exit;
   end;

   sinphi := -self.ballvy / v;
   cosphi := -self.ballvx / v;
   sina := (x - ballcx) / D;
   cosa := (ballcy - y) / D;

   sino := 2 * sina * cosa * cosphi - sinphi * (sqr(cosa) - sqr(sina));
   coso := (sqr(cosa) - sqr(sina)) * cosphi + 2 * sina * cosa * sinphi;

   self.ballvx := - v * coso;
   self.ballvy := - v * sino;

   AngularCollide := true;
end;

function TField.Collide: boolean;
var
   i, j: integer;
   flag: boolean;

begin
   i := round(self.ballx);
   j := round(self.bally);
   GetIndexes(i, j);
   flag := false;

   if (self.ballx + self.ballvx <= 20 * i) and
   (self.map[i - 1, j] in ['s', 'b']) then
   begin
      self.ballvx := abs(self.ballvx);
      flag := true;
   end;

   if (self.ballx + self.Ball.GetWidth + self.ballvx >= 20 * (i + 1))
   and (self.map[i + 1, j] in ['s', 'b']) then
   begin
      self.ballvx := -abs(self.ballvx);
      flag := true;
   end;

   if (self.bally + self.ballvy <= 20 * j)
   and (self.map[i, j - 1] in ['s', 'b']) then
   begin
      self.ballvy := abs(self.ballvy);
      flag := true;
   end;

   if (self.bally + Self.Ball.GetHeight + self.ballvy >= 20 * (j + 1))
   and (self.map[i, j + 1] in ['s', 'b']) then
   begin
      self.ballvy := -abs(self.ballvy);
      flag := true;
   end;

   if (not flag) and (map[i - 1, j - 1] in ['b', 's'])
      and not (map[i - 1, j] in ['b', 's'])
      and not (map[i, j - 1] in ['b', 's']) then
         flag := AngularCollide(20 * i, 20 * j);

   if (not flag) and (map[i + 1, j - 1] in ['b', 's'])
      and not (map[i + 1, j] in ['b', 's'])
      and not (map[i, j - 1] in ['b', 's']) then
         flag := AngularCollide(20 * (i + 1), 20 * j);

   if (not flag) and (map[i + 1, j + 1] in ['b', 's'])
      and not (map[i + 1, j] in ['b', 's'])
      and not (map[i, j + 1] in ['b', 's']) then
         flag := AngularCollide(20 * (i + 1), 20 * (j + 1));

   if (not flag) and (map[i - 1, j + 1] in ['b', 's'])
      and not (map[i - 1, j] in ['b', 's'])
      and not (map[i, j + 1] in ['b', 's']) then
         flag := AngularCollide(20 * i, 20 * (j + 1));

   Collide := flag;
end;

function TField.Exec(const Engine: TEngine): integer;
var
   flag: boolean;
   i, j: integer;

begin
   Self.MoveStick(Engine);
   inc(attempt);
   flag := true;
   while (Dist(ballvx, ballvy, 0, 0) > disp) or (flag) do    {v == 0}
   begin
      Collide;

      self.ballx := self.ballx + self.ballvx;
      self.bally := self.bally + self.ballvy;

      i := round(self.ballx + Ball.GetWidth / 2);
      j := round(self.bally + Ball.GetHeight / 2);
      GetIndexes(i, j);
      if (self.map[i, j] = 'w') then
      begin
         Self.ShowSplash(i ,j, Engine);
         Exec := -1;
         exit;
      end else
      if (self.map[i, j] = 'h') and
         (Dist(self.ballx, self.bally, 20 * i + Self.Box.GetWidth / 2,
         20 * j + Self.Box.GetHeight / 2) < holeradius)
         and (Dist(ballvx, ballvy, 0, 0) < maxspeed) then
      begin
         Self.ShowFinal(i, j, Engine);
         Exec := attempt;
         exit;
      end;

      Wait(timeout);
      flag := Self.CheckAcc(Engine);
      if (not flag) then
         DisHigh(Engine);
      if (Self.Ball.GetX <> round(self.ballx))
         or (Self.Ball.GetY <> round(self.bally)) then
      begin
         Self.Ball.PutBack(Engine);
         Self.Ball.SetXY(round(self.ballx), round(self.bally));
         Self.Ball.SaveBack(Engine);
         Self.Ball.Draw(Engine);
      end;

      self.ballvx := sgn(self.ballvx) * (abs(self.ballvx)
                     - abs(self.ballvx) * frict);
      self.ballvy := sgn(self.ballvy) * (abs(self.ballvy)
                     - abs(self.ballvy) * frict);

      if (keypressed) and (readkey = #32) then
      begin
         Exec := -1;
         exit;
      end;
   end;

   Exec := 0;
end;

constructor TField.Create(const source: string; const Engine: TEngine);
var
   i, j: word;
   ch: char;
   input: text;

begin
   with Self do
   begin
      attempt := 0;
      Stick.Create('images\stick.bmp', 10, 10, -1, -1);
      Ball.Create('images\ball.bmp', 100, 100, -1, -1);
      Box.Create('images\box.bmp', 1, 1, -1, -1);
      Stone.Create('images\stone.bmp', 1, 1, -1, -1);
      Grass.Create('images\grass.bmp', 1, 1, -1, -1);
      Water.Create('images\water.bmp', 1, 1, -1, -1);
      Hole.Create('images\hole.bmp', 10, 10, -1, -1);

      Up.Create('images\up.bmp', 10, 10, -1, -1);
      Down.Create('images\down.bmp', 10, 10, -1, -1);
      Right.Create('images\right.bmp', 10, 10, -1, -1);
      Left.Create('images\left.bmp', 10, 10, -1, -1);

      Up_h.Create('images\up_h.bmp', 10, 10, -1, -1);
      Down_h.Create('images\down_h.bmp', 10, 10, -1, -1);
      Right_h.Create('images\right_h.bmp', 10, 10, -1, -1);
      Left_h.Create('images\left_h.bmp', 10, 10, -1, -1);
   end;

   assign(input, source);
   reset(input);
   for j := 0 to fieldmaxy do
   begin
      for i := 0 to fieldmaxx do
      begin
         read(input, self.map[i, j]);
         case self.map[i, j] of
            'u':
            with Self.Up do
            begin
               SetXY(20 * i, 20 * j);
               Draw(Engine);
            end;
            'd':
            with Self.Down do
            begin
               SetXY(20 * i, 20 * j);
               Draw(Engine);
            end;
            'r':
            with Self.Right do
            begin
               SetXY(20 * i, 20 * j);
               Draw(Engine);
            end;
            'l':
            with Self.Left do
            begin
               SetXY(20 * i, 20 * j);
               Draw(Engine);
            end;
            's':
            with Self.Stone do
            begin
               SetXY(20 * i, 20 * j);
               Draw(Engine);
            end;
            'g':
            with Self.Grass do
            begin
               SetXY(20 * i, 20 * j);
               Draw(Engine);
            end;
            'w':
            with Self.Water do
            begin
               SetXY(20 * i, 20 * j);
               Draw(Engine);
            end;
             'b':
             with Self.Box do
            begin
               SetXY(20 * i, 20 * j);
               Draw(Engine);
            end;
             'h':
             with Self do
            begin
               Grass.SetXY(20 * i, 20 * j);
               Grass.Draw(Engine);
               Hole.SetXY(20 * i, 20 * j);
               Hole.Draw(Engine);
            end;
         end;
      end;
      readln(input);
   end;
   readln(input, self.ballx, self.bally);
   Self.Ball.SetXY(round(self.ballx), round(self.bally));
   Self.Stick.SetXY(round(self.ballx), round(self.bally));

   Self.Ball.SaveBack(Engine);
   Self.Ball.Draw(Engine);

   close(input);
end;

procedure TField.MoveStick;
var
   ch: char;
   newx, newy: word;
   stickx, sticky: integer;

begin
   ch := #0;
   newx := round(self.ballx);
   newy := round(self.bally);
   with Self.Stick do
   begin
      SetXY(newx div 2, newy);
      SaveBack(Engine);
      Draw(Engine);
   end;

   while (ButtonPressed <> 1) do
   with Self.Stick do
   begin
      getmousexy(newx, newy);
      if (keypressed) then
         ch := readkey;
      if (newx div 2 <> GetX) or (newy <> GetY) then
      begin
         PutBack(Engine);
         SetXY(newx div 2, newy);
         SaveBack(Engine);
         Draw(Engine);
      end;
   end;
   stickx := newx div 2;
   sticky := newy;
   Self.Stick.PutBack(Engine);

   with Self do
   begin
      ballvx := (ballx + Ball.GetWidth / 2 - stickx);
      ballvx := abs(ballvx) * sgn(ballvx) * koef;
      ballvy := (bally + Ball.GetHeight / 2 - sticky - Stick.GetHeight);
      ballvy := abs(ballvy) * sgn(ballvy) * koef;
   end;
end;

destructor TField.Destroy;
begin
   with Self do
   begin
      Stick.Destroy;
      Ball.Destroy;
      Box.Destroy;
      Stone.Destroy;
      Grass.Destroy;
      Water.Destroy;
      Hole.Destroy;
      Up.Destroy;
      Down.Destroy;
      Left.Destroy;
      Right.Destroy;
   end;
end;

end.
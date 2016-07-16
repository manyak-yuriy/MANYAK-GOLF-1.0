{Yuriy Manyak, KA-23, IASA}
uses crt, sprt, Fields, Dlg, Score;

const
   scoredest = 'user\score.res';

type
   PField = ^TField;   {to prevent stack overflow}

procedure ShowTitle(const Engine: TEngine; flag: boolean);
var
   Sprite: TSprite;

begin
   Engine.Init('user\title.bmp');
   Sprite.Create('user\title.bmp', 70, 30, -1, -1);
   if (flag) then
      Engine.SetEmptyPal;
   Sprite.Draw(Engine);
   if (flag) then
      Engine.Smooth
   else
      Engine.SmoothDying;
   if (flag) then
      readkey;
   Sprite.Destroy;

   if (true) then
      BackGr(Engine);
   Engine.Finish;
end;

function PlayLevel(mapnumb: integer; const Engine: TEngine): integer;
var
   Sprite: TSprite;
   result: integer;
   Fieldp: PField;

begin
   if (mapnumb in [1..6]) then
   begin
      Engine.Init('images\c5.bmp');
      Fieldp := new(PField, Create('maps\map_' + inttostr(mapnumb) + '.txt', Engine));
      repeat
         result := Fieldp^.Exec(Engine);
      until (result <> 0);
      dispose(Fieldp, Destroy);
   end;

   case result of
      -1:  {lost or close and wants to continue - show menu}
      begin
         Engine.InitPal('user\lost.bmp');
         Sprite.Create('user\lost.bmp', 1, 1, -1, -1);
         Sprite.Draw(Engine);
         readkey;
         Sprite.Destroy;
         Engine.Finish;
         PlayLevel := -1;
      end
      else {has result}
      begin
         Engine.InitPal('user\won.bmp');
         Sprite.Create('user\won.bmp', 60, 0, -1, -1);
         Sprite.SetTransC(-1);
         Sprite.Draw(Engine);
         readkey;
         Sprite.Destroy;
         Engine.Finish;
         PlayLevel := result;
      end;
   end;
end;


function GetMapNumber(const Dialog: TDefaultDialog): integer;
var
   state: boolean;
begin
   Dialog.Init(state);
   GetMapNumber := Dialog.Execute;
end;

var
   Dialog: TDefaultDialog;
   state: boolean;
   mapnumb, result: integer;
   name: string;

   Engine: TEngine;
   Hint: TSprite;

   GameScores: TScoreContainer;

begin
   GameScores.Create(scoredest);

   ShowTitle(Engine, true);
   mapnumb := GetMapNumber(Dialog);

   while (mapnumb <> -1) do
   begin
      while (mapnumb = 7) do
      begin
         ShowTitle(Engine, true);
         mapnumb := GetMapNumber(Dialog);
      end;

      case (mapnumb) of
         -1:
            break;
         0:
         begin
            mapnumb := 1;
            result := PlayLevel(mapnumb, Engine);
         end;
         1..6:
            result := PlayLevel(mapnumb, Engine);
         11..16:
         begin
            GameScores.OutPut(mapnumb - 10);
            readkey;
            result := -1;
         end;
      end;

      case result of
         -1: {lost or closed and would continue}
           mapnumb := GetMapNumber(Dialog);
         else {has a result > 0}
         begin
            GameScores.Add(mapnumb, result);
            if (mapnumb = 6) then
               mapnumb := GetMapNumber(Dialog)
            else
               inc(mapnumb);
         end;
      end;
   end;
   ShowTitle(Engine, false);
   GameScores.Destroy(scoredest);
end.

{Exec:
0 - continue
-1 - lose
>0 - result}
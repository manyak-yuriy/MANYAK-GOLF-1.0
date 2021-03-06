{Yuriy Manyak, KA-23, IASA}
unit Dlg;

interface

uses graph, crt, mouse, envr;

const
   num_of_menus = 2;

   backcolor = black;
   backfillcolor = lightblue;

type
   TDefaultDialog = object
     private
        Menu: array[1..num_of_menus] of PMenu;
        currmenu: integer;
        cursorx, cursory: word;
     public
        constructor Init(var result: boolean);
        function Execute: integer;
        destructor Destroy;
   end;

implementation

   constructor TDefaultDialog.Init(var result: boolean);
   var
      gm, gd: integer;
      errcode: integer;

   begin
      detectgraph(gm, gd);
      initgraph(gm, gd, '');
      errcode := graphresult;

      if (errcode = grok) and (InitMouse) then
      begin
         setbkcolor(backcolor);
         setcolor(backfillcolor);
         setfillstyle(1, backfillcolor);
         bar(1, 1, getmaxx, getmaxy);

         Menu[1] := new(PMenu, Create(210, 130, 200, 310, 'MAIN'));
         Menu[1]^.AddButton(28, 55, -1, -1, 'New Game');
         Menu[1]^.AddButton(40, 105, -1, -1, 'Levels');
         Menu[1]^.AddButton(40, 155, -1, -1, 'Scores');
         Menu[1]^.AddButton(47, 205, -1, -1, 'Title');
         Menu[1]^.AddButton(55, 255, -1, -1, 'Quit');
         Menu[1]^.Show;
         currmenu := 1;

         Menu[2] := new(PMenu, Create(150, 100, 320, 250, 'Levels'));
         Menu[2]^.AddButton(20, 50, -1, -1, 'Level 1');
         Menu[2]^.AddButton(20, 90, -1, -1, 'Level 2');
         Menu[2]^.AddButton(20, 130, -1, -1, 'Level 3');
         Menu[2]^.AddButton(170, 50, -1, -1, 'Level 4');
         Menu[2]^.AddButton(170, 90, -1, -1, 'Level 5');
         Menu[2]^.AddButton(170, 130, -1, -1, 'Level 6');
         Menu[2]^.AddButton(20, 200, -1, -1, 'Back');

         ShowMouse;

         result := true;
      end
      else
         result := false;

   end;

   function TDefaultDialog.Execute: integer;
   var
      selected: integer;
      ch: char;
      isscoremenu: boolean;

   begin
      ch := #0;
      while (true) do
      begin
         if (keypressed) then
            ch := readkey
         else
            ch := #0;
         while keypressed do
            ch := readkey;

         GetMouseXY(cursorx, cursory);
         Menu[currmenu]^.SolveFrame(ch, cursorx, cursory);
         selected := 0;
         if (ButtonPressed = 1) then
            selected := Menu[currmenu]^.CatchClick(cursorx, cursory);
         if (selected = 0) then
            selected := Menu[currmenu]^.CatchEnter(ch);

         if (selected <> 0) then
         case currmenu of
            1:
               case selected of
                  1:
                  begin
                     Menu[1]^.Hide;
                     Self.Destroy;
                     Execute := 0;
                     exit;
                  end;
                  2:   {open level menu}
                  begin
                     Menu[1]^.Hide;
                     Menu[2]^.Show;
                     currmenu := 2;
                     isscoremenu := false;
                  end;
                  3:   {!!!open level - score menu}
                  begin
                     Menu[1]^.Hide;
                     Menu[2]^.Show;
                     currmenu := 2;
                     isscoremenu := true;
                  end;
                  4:   {Show title of author}
                  begin
                     Menu[1]^.Hide;
                     Self.Destroy;
                     Execute := 7;
                     exit;
                  end;
                  5:                 {exit}
                  begin
                     Menu[1]^.Hide;
                     Self.Destroy;
                     Execute := -1;
                     exit;
                  end;
               end;
            2:
               case selected of
                  1..6:                {choose level}
                  begin
                     Menu[2]^.Hide;
                     Self.Destroy;
                     case (isscoremenu) of
                        false: Execute := selected;
                        true: Execute := selected + 10;
                     end;
                     exit;
                  end;
                  7:                    {return to main menu}
                  begin
                     Menu[2]^.Hide;
                     Menu[1]^.Show;
                     currmenu := 1;
                  end;
               end;
         end;
      end;
   end;

   destructor TDefaultDialog.Destroy;
   var
      i: integer;
   begin
      for i := 1 to num_of_menus do
         if (Menu[i] <> NIL) then
            dispose(Menu[i]);
      closegraph;
      HideMouse;
   end;

end.
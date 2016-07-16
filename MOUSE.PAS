{Yuriy Manyak, KA-23, IASA}
unit mouse;
interface
   function InitMouse: boolean;
   function ButtonNumb: byte;
   procedure ShowMouse;
   procedure HideMouse;
   procedure GetMouseXY(var koordX, koordY: word);
   function ButtonPressed: byte;
   {--------
    ButtonPressed:
    1 - left button
    2 - right button
    3 - left and right
    4 - mouse wheel
    5 - left button and wheel
    6 - right button and wheel
    7 - right and left and wheel
   ---------}
   function MousePressed: boolean;
   procedure GotoMouseXY(x, y: word);
   function GetClickNum(button: word; var x, y: word): word;
   {-------
    GetClickNum:
    needs $X+
    button = 0 - left button
    button = 1 - right button
    button = 2 - mouse wheel
    --------}
   procedure LimHor(max, min: word);
   procedure LimVer(max, min: word);

implementation

  function InitMouse: boolean;
  var
     ResultRegAX: word;
  begin
     asm
       mov ax,$00
       int $33
       mov ResultRegAX,ax
     end;
     If (ResultRegAX = $FFFF) then
        InitMouse := true
     else InitMouse := false;
  end;

  function ButtonNumb: byte;
  var
     ResultRegBX: word;
  begin
     asm
        mov ax,$00
        int $33
        mov ResultRegBX,bx
     end;
     ButtonNumb := ResultRegBX;
  end;

  procedure ShowMouse; assembler;
  asm
     mov ax,$01
     int $33
  end;

  procedure HideMouse; assembler;
  asm
     mov ax,$02
     int $33
  end;

  procedure GetMouseXY(var koordX, koordY: Word);
  var
    ResultCX, ResultDX: word;
  begin
     asm
        mov ax,$03
        int $33
        mov ResultCX,CX
        mov ResultDX,DX
     end;
     KoordX := ResultCX;
     KoordY := ResultDX
  end;

  function ButtonPressed: byte;
  var
     rbl:byte;
  begin
     asm
        mov ax,$03
        int $33
        mov rbl,bl
     end;
     ButtonPressed := rbl
  end;

  function MousePressed: boolean;
  var
     resultbx:word;
  begin
     asm
        mov ax, $03
        int $33
        mov resultbx,bx
     end;
     MousePressed := (resultbx <> 0);
  end;

  procedure GotoMouseXY(x,y:word); assembler;
  asm
     mov ax,$04
     mov cx,x
     mov dx,y
     int $33
  end;

function GetClickNum(button: word; var x,y: word): word;
var
   number,ResultCX,ResultDX: word;
begin
   asm
      mov ax,$05
      mov bx,button
      int $33
      mov ResultCX,cx
      mov ResultDX,dx
      mov number,bx
   end;
   GetClickNum := number;
   x := ResultCX;
   y := ResultDX;
end;


procedure LimHor(max, min: word); assembler;
asm
   mov ax,$07
   mov cx,min
   mov dx,max
   int $33;
end;

procedure LimVer(max, min: word); assembler;
asm
   mov ax,$08
   mov cx,min
   mov dx,max
   int $33;
end;

end.
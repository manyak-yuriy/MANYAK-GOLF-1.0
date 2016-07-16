{Yuriy Manyak, KA-23, IASA}
unit BMP;

interface
const
   palsize = 256;
type
   BMPHeader = record
      filetype: word;
      filesize: longint;
      reserved1: word;
      reserved2: word;
      offbits: longint;
      structsize: longint;
      width: longint;
      height: longint;
      planes: word;
      bits: word;
      compression: longint;
      imagesize: longint;
      pixpermeterX: longint;
      pixpermeterY: longint;
      usedcol: longint;
      importcol: longint;
      Pal: array[0..palsize - 1, 0..3] of byte;
  end;

implementation

end.
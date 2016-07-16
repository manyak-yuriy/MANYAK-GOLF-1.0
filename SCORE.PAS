unit Score;

interface

const
   levelnumb = 6;
   scorenumb = 5;

type
   TScoreRecord = record
       value: integer;
       name: string;
   end;

   TLevelScores = array[1..scorenumb] of TScoreRecord;

   TScoreContainer = object
      private
         Scores: array[1..levelnumb] of TLevelScores;
      public
         constructor Create(const filedest: string);
         function Add(level, value: integer): boolean;
         procedure SavetoFile(const filedest: string);
         procedure OutPut(level: integer);
         destructor Destroy(const filedest: string); virtual;
   end;

implementation

   procedure TScoreContainer.OutPut(level: integer);
   var
      index: integer;
   begin
      index := 1;
      while (index <= scorenumb) do
      with (Self.Scores[level, index]) do
         if (value <> 0) then
         begin
            writeln(index, ' position: ');
            writeln(name, ' : ', value, ' attempts.');
            writeln('---------------');
            inc(index);
         end
         else
            break;
      if (index = 1) then
         writeln('Nobody tried to play this level.');
   end;

   constructor TScoreContainer.Create(const filedest: string);
   var
      f: file of TScoreRecord;
      level, index: integer;
   {$I-}
   begin
      assign(f, filedest);
      reset(f);
      if (IoResult <> 0) then
      begin
         for level := 1 to scorenumb do
            for index := 1 to levelnumb do
            with self.Scores[level, index] do
            begin
               value := 0;
               name := '';
            end;
         Self.SavetoFile(filedest);
      end else
      begin
         for level := 1 to levelnumb do
            for index := 1 to scorenumb do
               read(f, Self.Scores[level, index]);
         close(f);
      end;
   end;
   {$I+}

   procedure TScoreContainer.SavetoFile(const filedest: string);
   var
      f: file of TScoreRecord;
      level, index: integer;
   begin
      assign(f, filedest);
      rewrite(f);
      for level := 1 to levelnumb do
            for index := 1 to scorenumb do
               write(f, Self.Scores[level, index]);
      close(f);
   end;

   function TScoreContainer.Add(level, value: integer): boolean;
   var
      index, i: integer;
      name: string;

   begin
      index := 1;
      while (index <= scorenumb) and (self.Scores[level, index].value <> 0)
      and (self.Scores[level, index].value <= value) do
         inc(index);
      if (index > scorenumb) then
         Add := false
      else
      begin
         writeln('Congratulations!');
         writeln('You have reached ', index, ' position!');
         writeln('Your attempts: ', value);
         write('Your name: ');
         readln(name);
         for i := scorenumb downto index + 1 do
         begin
            self.Scores[level, i].value := self.Scores[level, i - 1].value;
            self.Scores[level, i].name := self.Scores[level, i - 1].name;
         end;
         self.Scores[level, index].value := value;
         self.Scores[level, index].name := name;
         Add := true;
      end;
   end;

   destructor TScoreContainer.Destroy(const filedest: string);
   begin
      Self.SavetoFile(filedest);
   end;


end.
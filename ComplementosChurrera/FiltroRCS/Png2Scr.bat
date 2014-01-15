@echo off
if "%2"=="" (
  echo usage: %0 ^<input.png^> ^<output.scr^>
) else (
  PosterizeZX %1 temp.png
  Png2Rcs temp.png temp.rcs
  rcs -i temp.rcs %2
  del temp.png temp.rcs
)
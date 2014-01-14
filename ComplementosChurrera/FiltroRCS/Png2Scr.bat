@echo off
if "%2"=="" (
  echo usage: %0 ^<input.png^> ^<output.scr^>
) else (
  PosterizeZX %1 temp.png
  Png2Rcs temp.png temp.rcs
  if exist "%2" del %2
  rcs -d temp.rcs %2
  del temp.png temp.rcs
)
@echo off
color 0a
@echo on
echo BUILDING GAME
lime build html5 -final -Dng
echo ZIPPING
cd export
7z a -tzip -r swag release\html5\bin
start .
start https://www.newgrounds.com/projects/games/5004545
pause
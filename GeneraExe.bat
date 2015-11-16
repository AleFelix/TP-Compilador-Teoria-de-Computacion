del intermedia.txt
A:\Flex\bin\flex Prueba_Lexico.l
A:\Flex\bin\bison -dyv sintactico.y
pause
c:\MinGW\bin\gcc.exe lex.yy.c y.tab.c -o TPFinal.exe
pause
TPfinal.exe PruebaEjemplo.txt
del lex.yy.c
del y.tab.c
del y.output
del y.tab.h
del TPFinal.exe

pause

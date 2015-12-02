del intermedia.txt

c:\GnuWin32\bin\flex lexico.l

c:\GnuWin32\bin\bison -dyv sintactico.y

pause

c:\MinGW\bin\gcc.exe lex.yy.c y.tab.c -o TPFinal.exe

pause

TPfinal.exe Prueba.txt

del lex.yy.c

del y.tab.c

del y.output

del y.tab.h

del TPFinal.exe

pause

c:\MinGW\bin\gcc.exe -g Generador_Assembler.c -o GenerarASMDebug.exe

pause

c:\MinGW\bin\gdb.exe -ex run -ex q GenerarASMDebug.exe

del GenerarASMDebug.exe

pause
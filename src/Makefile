# This makefile should work for Linux/OSX/unix-y things as long as 
# you've got the mxmlc compiler in your PATH.

OUT = STATIClyMAD.swf
OUT_ED = Editor.swf
OUT_TABLE = table.swf

OPTS = -static-link-runtime-shared-libraries=true -use-direct-blit=true
CC = mxmlc

all: main ed table
	
main: levels
	${CC} Main.as -o ${OUT} ${OPTS}
ed:
	${CC} EditorMain.as -o ${OUT_ED} ${OPTS} 
clean: 
	rm ${OUT} ${OUT_ED}

levels:
	python LevelCompiler.py

table:
	${CC} LevelTableBuilder.as -o ${OUT_TABLE} ${OPTS}
	

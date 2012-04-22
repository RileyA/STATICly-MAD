# This makefile should work for Linux/OSX/unix-y things as long as 
# you've got the mxmlc compiler in your PATH.

OUT = STATIClyMAD.swf
OPTS = -static-link-runtime-shared-libraries=true
CC = mxmlc

main:
	${CC} Main.as -o ${OUT} ${OPTS}
clean: 
	rm ${OUT}

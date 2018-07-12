module functions.resolve;
import bldso : decompiler;
import opcodes : opcode;

void callfunc(decompiler dec) {

}

void bootup(decompiler dec) {
	dec.handlers[opcode.OP_CALLFUNC_RESOLVE] = &callfunc;
	dec.handlers[opcode.OP_CALLFUNC] = &callfunc;
}




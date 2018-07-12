module maths.cmps;
import bldso : decompiler;
import opcodes;

void cmphandler(decompiler dec) {

}

void bootup(decompiler dec) {
	dec.handlers[opcode.OP_CMPEQ] = &cmphandler;
	dec.handlers[opcode.OP_CMPGR] = &cmphandler;
	dec.handlers[opcode.OP_CMPLE] = &cmphandler;
	dec.handlers[opcode.OP_CMPNE] = &cmphandler;
	dec.handlers[opcode.OP_CMPLT] = &cmphandler;
}


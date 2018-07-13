module maths.binops;
import bldso : decompiler;
import opcodes : opcode;
import utilities : popOffStack;

void bin_or(decompiler dec) {

}

void bin_bitor(decompiler dec) {

}

void bin_not(decompiler dec) {

}

void bin_xor(decompiler dec) {

}

void bin_and(decompiler dec) {

}

void bin_bitand(decompiler dec) {

}

void bin_shl(decompiler dec) {

}

void bin_shr(decompiler dec) {

}

void bootup(decompiler dec) {
	dec.handlers[opcode.OP_SHL] = &bin_shl;
	dec.handlers[opcode.OP_SHR] = &bin_shr;
	dec.handlers[opcode.OP_OR] = &bin_or;
	dec.handlers[opcode.OP_BITOR] = &bin_bitor;
	dec.handlers[opcode.OP_XOR] = &bin_xor;
	dec.handlers[opcode.OP_AND] = &bin_and;
	dec.handlers[opcode.OP_BITAND] = &bin_bitand;
	dec.handlers[opcode.OP_NOT] = &bin_not;
	dec.handlers[opcode.OP_NOTF] = &bin_not;
}





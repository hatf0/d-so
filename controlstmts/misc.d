module controlstmts.misc;
import bldso : decompiler;
import opcodes : opcode;

void ts_return(decompiler dec) {

}

void ts_break(decompiler dec) { 

}

void bootup(decompiler dec) {

	dec.handlers[opcode.OP_RETURN] = &ts_return;
	dec.handlers[opcode.OP_BREAK] = &ts_break;
}



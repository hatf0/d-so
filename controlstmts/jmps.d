module controlstmts.jmps;
import bldso : decompiler;
import opcodes : opcode;

void jmpifnot(decompiler dec) {

}

void jmpiffnot(decompiler dec) {

}

void jmpifnot_np(decompiler dec) {
    version(Debug) {
	import utilities : addTabulation;
	dec.fi.outputFile.writeln(addTabulation("//JMPIFNOT_NP"));
    }

}

void jmpif(decompiler dec) {
    dec.i++;
}

void jmpiff(decompiler dec) {
    assert(0, "unfinished");
}

void jmpif_np(decompiler dec) {
    version(Debug) {
	import utilities : addTabulation;
	dec.fi.outputFile.writeln(addTabulation("//JMPIF_NP"));
    }

}

void jmp(decompiler dec) {

}

void bootup(decompiler dec) {
	dec.handlers[opcode.OP_JMPIFNOT] = &jmpifnot;
	dec.handlers[opcode.OP_JMPIFFNOT] = &jmpiffnot;
	dec.handlers[opcode.OP_JMPIFNOT_NP] = &jmpifnot_np;
	dec.handlers[opcode.OP_JMPIF] = &jmpif;
	dec.handlers[opcode.OP_JMPIFF] = &jmpiff;
	dec.handlers[opcode.OP_JMPIF_NP] = &jmpif_np;
	dec.handlers[opcode.OP_JMP] = &jmp;
}

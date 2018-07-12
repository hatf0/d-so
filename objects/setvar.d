module objects.setvar;
import bldso : decompiler;
import opcodes : opcode;

void savefield(decompiler dec) {

}

void bootup(decompiler dec) {
	dec.handlers[opcode.OP_SAVEFIELD_STR] = &savefield;
	dec.handlers[opcode.OP_SAVEFIELD_FLT] = &savefield;
}



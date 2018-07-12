module objects.getvar;
import bldso : decompiler;
import opcodes : opcode;

void loadfield(decompiler dec) {

}

void bootup(decompiler dec) {
	dec.handlers[opcode.OP_LOADFIELD_UINT] = &loadfield;
	dec.handlers[opcode.OP_LOADFIELD_STR] = &loadfield;
	dec.handlers[opcode.OP_LOADFIELD_FLT] = &loadfield;
}



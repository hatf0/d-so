module functions.decl;
import bldso : decompiler;
import opcodes : opcode;

void func_decl(decompiler dec) {

}

void bootup(decompiler dec) {
	dec.handlers[opcode.OP_FUNC_DECL] = &func_decl;
}


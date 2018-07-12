module objects.creation;
import bldso : decompiler;
import opcodes : opcode;

void create_object(decompiler dec) {

}

void add_object(decompiler dec) {

}

void end_object(decompiler dec) {

}

void bootup(decompiler dec) {
	dec.handlers[opcode.OP_CREATE_OBJECT] = &create_object;
	dec.handlers[opcode.OP_END_OBJECT] = &end_object;
	dec.handlers[opcode.OP_ADD_OBJECT] = &add_object;
}

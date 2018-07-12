module typeconvs.t_uint;
import opcodes : opcode;
import bldso : decompiler;

void uint_to_str(decompiler dec) {

}
void uint_to_none(decompiler dec) {

}

void bootup(decompiler dec) {
	dec.handlers[opcode.OP_UINT_TO_NONE] = &uint_to_none;
	dec.handlers[opcode.OP_UINT_TO_STR] = &uint_to_str;
}

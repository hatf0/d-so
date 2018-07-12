module typeconvs.t_string;
import opcodes : opcode;
import bldso : decompiler;

void str_to_flt(decompiler dec) {

}

void str_to_uint(decompiler dec) {

}

void str_to_none(decompiler dec) {

}

void advance_str_comma(decompiler dec) {

}

void advance_str_nul(decompiler dec) {

}

void advance_str(decompiler dec) {

}

void advance_str_appendchar(decompiler dec) {

}

void rewind_str(decompiler dec) {

}

void terminate_rewind_str(decompiler dec) {

}


void bootup(decompiler dec) {
	dec.handlers[opcode.OP_STR_TO_NONE] = &str_to_none;
	dec.handlers[opcode.OP_STR_TO_UINT] = &str_to_uint;
	dec.handlers[opcode.OP_STR_TO_FLT] = &str_to_flt;
	dec.handlers[opcode.OP_ADVANCE_STR_COMMA] = &advance_str_comma;
	dec.handlers[opcode.OP_ADVANCE_STR_APPENDCHAR] = &advance_str_nul;
	dec.handlers[opcode.OP_ADVANCE_STR_NUL] = &advance_str_appendchar;
	dec.handlers[opcode.OP_ADVANCE_STR] = &advance_str;
	dec.handlers[opcode.OP_REWIND_STR] = &rewind_str;
	dec.handlers[opcode.OP_TERMINATE_REWIND_STR] = &terminate_rewind_str;
}

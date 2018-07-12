module typeconvs.t_uint;
import opcodes : opcode;
import bldso : decompiler;
import utilities : popOffStack, addTabulation;

void uint_to_str(decompiler dec) {
	dec.stacks.s_s ~= popOffStack(dec.stacks.i_s);

}
void uint_to_none(decompiler dec) {
	if(dec.stacks.l_s[2] == opcode.OP_END_OBJECT) {
		dec.fi.outputFile.writeln(addTabulation(popOffStack(dec.stacks.i_s), dec.indentation));
	}
	else {
		popOffStack(dec.stacks.i_s);
	}
}

void uint_to_flt(decompiler dec) {
	dec.stacks.f_s ~= popOffStack(dec.stacks.i_s);
}

void bootup(decompiler dec) {
	dec.handlers[opcode.OP_UINT_TO_NONE] = &uint_to_none;
	dec.handlers[opcode.OP_UINT_TO_STR] = &uint_to_str;
	dec.handlers[opcode.OP_UINT_TO_FLT] = &uint_to_flt;
}

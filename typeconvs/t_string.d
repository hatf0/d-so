module typeconvs.t_string;
import opcodes : opcode;
import bldso : decompiler;
import utilities : popOffStack, addTabulation, string_op;

void str_to_flt(decompiler dec) {
	dec.stacks.f_s ~= popOffStack(dec.stacks.s_s);
}

void str_to_uint(decompiler dec) {
	dec.stacks.i_s ~= popOffStack(dec.stacks.s_s);
}

void str_to_none(decompiler dec) {
	if(dec.stacks.l_s[2] == opcode.OP_CALLFUNC_RESOLVE || (dec.stacks.l_s[2] == opcode.DECOMPILER_ENDIF && dec.stacks.l_s[2] == opcode.OP_CALLFUNC_RESOLVE))
	{
		string writeOut = addTabulation(popOffStack(dec.stacks.s_s), dec.indentation); 
		if(writeOut[writeOut.length - 1] != ';') {
			writeOut ~= ";";
		}
		dec.fi.outputFile.writeln(writeOut);
	}
	else {
		popOffStack(dec.stacks.s_s);
	}

}

void advance_str_comma(decompiler dec) {
	dec.stacks.s_s ~= popOffStack(dec.stacks.s_s) ~ ",";
}

void advance_str_nul(decompiler dec) {

}

void advance_str(decompiler dec) {

}

void advance_str_appendchar(decompiler dec) {
	dec.stacks.s_s ~= popOffStack(dec.stacks.s_s) ~ cast(char)dec.fi.code[dec.i];
	dec.i++;
}

void rewind_str(decompiler dec) {
	if(dec.fi.code[dec.i] == opcode.OP_SETCURVAR_ARRAY || dec.fi.code[dec.i] == opcode.OP_SETCURVAR_ARRAY_CREATE) {
		string arrayIndex = popOffStack(dec.stacks.s_s);
		dec.stacks.s_s ~= popOffStack(dec.stacks.s_s) ~ "[" ~ arrayIndex ~ "]";
	}
	else {
		string rhs = popOffStack(dec.stacks.s_s);
		string lhs = popOffStack(dec.stacks.s_s);
		char rawOp = lhs[lhs.length - 1];
		string op = string_op(rawOp);
		if(op != "") {
			dec.stacks.s_s ~= lhs[0..lhs.length - 1] ~ " " ~ op ~ " " ~ rhs;
		}
		else if(rawOp == ',') {
			dec.stacks.s_s ~= lhs ~ rhs;
		}
		else {
			dec.stacks.s_s ~= lhs ~ " @ " ~ rhs;
		}

	}

		
}

void terminate_rewind_str(decompiler dec) {

}

void compare_str(decompiler dec) {
	string rhs = popOffStack(dec.stacks.s_s);
	string lhs = popOffStack(dec.stacks.s_s);
	dec.stacks.i_s ~= lhs ~ " $= " ~ rhs; 
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
	dec.handlers[opcode.OP_COMPARE_STR] = &compare_str;

}

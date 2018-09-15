module variables.savevar;
import bldso : decompiler;
import opcodes : opcode;
import utilities : addTabulation;

void savevar(ref decompiler dec) {

	string rhs;
	if(dec.status.currentOpcode == opcode.OP_SAVEVAR_UINT) {
		rhs = dec.stacks.i_s[dec.stacks.i_s.length - 1];
	}
	else if(dec.status.currentOpcode == opcode.OP_SAVEVAR_STR) {
		rhs = dec.stacks.s_s[dec.stacks.s_s.length - 1];
	}
	else {
		rhs = dec.stacks.f_s[dec.stacks.f_s.length - 1];
	}

	dec.fi.outputFile.writeln(addTabulation(dec.status.current_variable ~ " = " ~ rhs, dec.indentation));
}


void setcurvar(ref decompiler dec) {
	dec.status.current_variable = dec.get_string(dec.fi.code[dec.i], false);
	dec.i++;
}

void bootup(ref decompiler dec) {
	dec.handlers[opcode.OP_SAVEVAR_FLT] = &savevar;
	dec.handlers[opcode.OP_SAVEVAR_STR] = &savevar;
	dec.handlers[opcode.OP_SAVEVAR_UINT] = &savevar;
	dec.handlers[opcode.OP_SETCURVAR] = &setcurvar;
	dec.handlers[opcode.OP_SETCURVAR_CREATE] = &setcurvar;
}




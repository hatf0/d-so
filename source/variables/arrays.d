module variables.arrays;
import bldso : decompiler;
import utilities : popOffStack;
import opcodes : opcode;

void setcurvar_array(ref decompiler dec) {
	dec.status.current_variable = popOffStack(dec.stacks.s_s); 
}

void setcurfield_array(ref decompiler dec) {
	dec.status.current_field ~= "[" ~ popOffStack(dec.stacks.s_s) ~ "]";
}

void bootup(ref decompiler dec) {
	dec.handlers[opcode.OP_SETCURFIELD_ARRAY] = &setcurfield_array;
	dec.handlers[opcode.OP_SETCURVAR_ARRAY_CREATE] = &setcurvar_array;
	dec.handlers[opcode.OP_SETCURVAR_ARRAY] = &setcurvar_array;
}


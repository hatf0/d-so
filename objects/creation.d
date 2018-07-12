module objects.creation;
import bldso : decompiler;
import opcodes : opcode;
import utilities : popOffStack;

void create_object(decompiler dec) {
	import std.algorithm : remove;
	string parentObject = dec.get_string(dec.fi.code[dec.i], false);
	int isDataBlock = dec.fi.code[dec.i + 1], failJump = dec.fi.code[dec.i + 2];
	string[] arguments = dec.stacks.a_s[dec.stacks.a_s.length - 1];
	string constructor = "new " ~ arguments[0] ~ "(" ~ arguments[1] ~ ") {\n";
	dec.stacks.i_s ~= constructor;
	dec.status.enteredObjCreation = true;
	dec.i += 3;
	dec.stacks.a_s.remove(dec.stacks.a_s.length - 1);
}

void add_object(decompiler dec) {
	dec.i++;
}

void end_object(decompiler dec) {
	dec.indentation--;
	dec.i++;
	string objectCreation = popOffStack(dec.stacks.i_s);
	objectCreation ~= "};";
	dec.status.enteredObjCreation = false;
	dec.stacks.i_s ~= objectCreation;

}

void setcurobject_new(decompiler dec) {
	dec.status.current_object = "";
}


void bootup(decompiler dec) {
	dec.handlers[opcode.OP_SETCUROBJECT_NEW] = &setcurobject_new;
	dec.handlers[opcode.OP_CREATE_OBJECT] = &create_object;
	dec.handlers[opcode.OP_END_OBJECT] = &end_object;
	dec.handlers[opcode.OP_ADD_OBJECT] = &add_object;
}

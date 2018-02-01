module bldso;
import std.stdio;
import std.conv;
import std.array;
import core.exception;

enum opcodes {
	FILLER0,
	OP_ADVANCE_STR_NUL,
	OP_UINT_TO_STR,
	OP_UINT_TO_NONE,
	FILLER1,
	OP_ADD_OBJECT,
	FILLER2,
	OP_CALLFUNC_RESOLVE,
	OP_FLT_TO_UINT,
	OP_FLT_TO_STR,
	OP_STR_TO_NONE_2,
	OP_LOADVAR_UINT,
	OP_SAVEVAR_STR,
	OP_JMPIFNOT,
	OP_SAVEVAR_FLT,
	OP_LOADIMMED_UINT,
	OP_LOADIMMED_FLT,
	OP_LOADIMMED_IDENT,
	OP_TAG_TO_STR,
	OP_LOADIMMED_STR,
	OP_ADVANCE_STR_APPENDCHAR,
	OP_TERMINATE_REWIND_STR,
	OP_ADVANCE_STR,
	OP_CMPLE,
	OP_SETCURFIELD,
	OP_SETCURFIELD_ARRAY,
	OP_JMPIF_NP,
	OP_JMPIFF,
	OP_JMP,
	OP_BITOR,
	OP_SHL,
	OP_SHR,
	OP_STR_TO_NONE,
	OP_COMPARE_STR,
	OP_CMPEQ,
	OP_CMPGR,
	OP_CMPNE, 
	OP_OR,
	OP_STR_TO_UINT,
	OP_SETCUROBJECT,
	OP_PUSH_FRAME,
	OP_REWIND_STR,
	OP_LOADFIELD_UINT_2,
	OP_CALLFUNC,
	OP_LOADVAR_STR,
	OP_LOADVAR_FLT,
	OP_SAVEFIELD_FLT,
	OP_LOADFIELD_FLT,
	OP_MOD,
	OP_LOADFIELD_UINT,
	OP_JMPIFFNOT,
	OP_JMPIF,
	OP_SAVEVAR_UINT,
	OP_SUB,
	OP_MUL,
	OP_DIV,
	OP_NEG,
	FILLER3,
	OP_STR_TO_FLT,
	OP_END_OBJECT,
	OP_CMPLT,
	OP_BREAK,
	OP_SETCURVAR_CREATE,
	OP_SETCUROBJECT_NEW,
	OP_NOT,
	OP_NOTF,
	OP_SETCURVAR,
	OP_SETCURVAR_ARRAY,
	OP_ADD,
	OP_SETCURVAR_ARRAY_CREATE,
	OP_JMPIFNOT_NP,
	OP_AND,
	OP_RETURN,
	OP_XOR,
	OP_CMPGE,
	OP_LOADFIELD_STR,
	OP_SAVEFIELD_STR,
	OP_BITAND,
	OP_ONESCOMPLEMENT,
	OP_ADVANCE_STR_COMMA,
	OP_PUSH,
	OP_FLT_TO_NONE,
	OP_CREATE_OBJECT,
	OP_FUNC_DECL
}

enum opcodes_meta {
	DECOMPILER_ENDFUNC = 0x1111
}

enum CallTypes {
	FunctionCall, //A regular call. May have a namespace.
	ObjectCall, //Object and/or MethodCall
	ParentCall, //idk dude
	FunctionDecl //Something I just added in for shits and giggles tbh
}	

File curFile;

void decompile(char[] global_st, char[] function_st, double[] global_ft, double[] function_ft, int[] code, int[] lbptable, string dso_name) {
	import std.algorithm, std.string;
	writeln("Code length: ", code.length);
	int i = 0;
	bool create_folders = false;
	int indentation_level = 0;
	bool enteredFunction = false;
	string[] string_stack;
	int[] int_stack;
	double[] float_stack;
	string[] arguments;

	string constructPrettyFunction(string fnName, string fnNamespace, string[] argv, CallTypes callType = CallTypes.FunctionCall) {
		string retVal = "";
		if(fnNamespace != "") {
			retVal ~= fnNamespace ~ "::" ~ fnName;
		}
		else {
			retVal ~= fnName;
		}
		retVal ~= "(";
		if(argv.length == 0) {
			retVal ~= ")";
		}
		return retVal;
	}
	string get_string(int offset, bool fuck = enteredFunction) {
		//writeln()
		char[] blehtable;
		if(!fuck) {
			blehtable = global_st[offset..global_st.length];		
		}
		else {
			blehtable = function_st[offset..function_st.length];
		}


		int endPartOfString = cast(int)countUntil(blehtable, "\x00");
		//writeln("End portion of string: ", endPartOfString);
		//writeln("Attempt to slice out the string: ", blehtable[0..endPartOfString]);
		char[] slicedString = blehtable[0..endPartOfString];
		return text(slicedString.ptr);
	}

	string addTabulation(string previous) {
		string retVal = "";
		for(int l = 0; l < indentation_level; l++) {
			retVal ~= "\t";
		}
		retVal ~= previous;
		return retVal;
	}

	int fileExtension = cast(int)countUntil(dso_name, ".cs.dso");
	string file_name_with_fixed_ext = dso_name[0..fileExtension] ~ ".cs";
	//writeln(dso_name[0..fileExtension]);
	curFile = File(file_name_with_fixed_ext, "w");
	while(i < code.length) {
		int opcode = code[i];
		i++;
		try {
			switch(opcode) {
				case opcodes.OP_FUNC_DECL: {
					string fnName = get_string(code[i]);
					string fnNamespace = get_string(code[i + 1]);
					if(code[i + 1] == 0) {
						fnNamespace = "";
					}
					string fnPackage = get_string(code[i + 2]);
					int has_body, fnEndLoc, argc;
					has_body = code[i + 3];
					fnEndLoc = code[i + 4];
					argc = code[i + 5];
					string[] argv;
					int whatWasThere = code[fnEndLoc];
					//code.insertBefore(fnEndLoc, opcodes_meta.DECOMPILER_ENDFUNC);
					code.insertInPlace(fnEndLoc, opcodes_meta.DECOMPILER_ENDFUNC);
					writeln("New function");
					//code[fnEndLoc] = opcodes_meta.DECOMPILER_ENDFUNC;
					writeln("fnName: ", fnName, " fnNamespace: ", fnNamespace, " fnPackage: ", fnPackage, " has_body: ", has_body, " fnEndLoc: ", fnEndLoc, " argc ", argc);
					//writeln(global_st[code[i]]);
					//writeln(code[ip]);
					//writeln("Code end loc: ", fnEndLoc, " code size: ", code.length);
					//writeln("Thing at code end loc: ", code[fnEndLoc]);
					enteredFunction = true;
					if(code[fnEndLoc] == opcodes_meta.DECOMPILER_ENDFUNC) {
						writeln("fnEndLoc inserted successfully");
					}
					if(code[fnEndLoc + 1] == whatWasThere) {
						writeln("OPCode directly after is saved..");
					}
					//writeln("Found a function declaration");
					for(int q = 0; q < argc; q++) {
						argv ~= get_string(code[i + 6 + q]);
					//	argv ~= text(function_st[code[i + 6 + q]]);
					}
					curFile.write("function " ~ constructPrettyFunction(fnName, fnNamespace, argv) ~ " {\n");
					indentation_level++;
					//writeln(constructPrettyFunction(fnName, fnNamespace, argv));
					i += 6 + argc;
					//i = fnEndLoc - 1;
					writeln(argv);
					break;
				}

				case opcodes_meta.DECOMPILER_ENDFUNC: { //our metadata that we inserted
					writeln("encountered endfunc at ", i - 1);
					code = code.remove(i - 1); //we encountered it, now delete it because offsets are fucky
					indentation_level--; //tabs or spaces??
					for(int b = 0; b < indentation_level; b++) {
						curFile.write("\t");
					}
					curFile.write("}\n");
					writeln("code at pos: ", code[i - 1]);
					enteredFunction = false;
					i--;
					break;
				}

				case opcodes.OP_CALLFUNC_RESOLVE, opcodes.OP_CALLFUNC: {
					int call_type = code[i + 2];
					//writeln("Got call type");
					//writeln(code[i], " ", enteredFunction ? function_st.length : global_st.length);
					string fnName = get_string(code[i], false);
					//writeln("Got fnName");
					string fnNamespace = "";
					if(code[i + 1]) {
						fnNamespace = get_string(code[i + 1], false);
					}
					string_stack ~= constructPrettyFunction(fnName, fnNamespace, arguments, cast(CallTypes)call_type);
					i += 3;
					break;
				}

				case opcodes.OP_RETURN: {
					//writeln("return ", string_stack.length);
					//writeln(string_stack[string_stack.length]);
					string writeOut = addTabulation("");
					writeOut ~= "return";
					if(string_stack.length != 0) {
						string ret = string_stack[string_stack.length - 1];
						string_stack.popBack();
						writeOut ~= " " ~ ret ~ ";";
					}
					else {
						writeOut ~= ";";
					}

					if(i != code.length && code[i] != opcodes_meta.DECOMPILER_ENDFUNC) {
						curFile.write(writeOut ~ "\n");
					}
					break;
				}

				case opcodes.OP_CREATE_OBJECT {
					string parent = get_string(code[i], false);
					int isDatablock = code[i + 1], failJump = code[i + 2];
				}

				default: {
					break;
				//writeln("Unhandled");
				}
			}
		}
		catch(RangeError) {
			writeln("Encountered a very bad error.. at ip: ", i - 1);
			writeln("Opcode here is: ", code[i - 1]);
			//writeln(code[i + 2]);
			curFile.close();
			writeln(function_st.length);
			return;
		}
	}
	writeln(string_stack);
	curFile.close();
	//writeln("todo");
}
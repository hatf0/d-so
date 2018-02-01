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
	DECOMPILER_ENDFUNC = 0x1000
}

File curFile;

void decompile(char[][] global_st, char[][] function_st, double[] global_ft, double[] function_ft, int[] code, int[] lbptable) {
	for(int i = 0; i < code.length; i++) {
		int ip = i;
		i++;
		switch(code[ip]) {
			case opcodes.OP_FUNC_DECL: {
				string fnName = text(global_st[code[i]]);
				string fnNamespace = text(global_st[code[i + 1]]);
				if(code[i + 1] == 0) {
					fnNamespace = "";
				}
				string fnPackage = text(global_st[code[i + 2]]);
				int has_body, fnEndLoc, argc;
				has_body = code[i + 3];
				fnEndLoc = code[i + 4];
				argc = code[i + 5];
				string[] argv;
				//code.insertBefore(fnEndLoc, opcodes_meta.DECOMPILER_ENDFUNC);
				try {
					code.insertInPlace(fnEndLoc, opcodes_meta.DECOMPILER_ENDFUNC);
				}
				catch(RangeError) {
					writeln("Tried to insert at ", fnEndLoc, " while code size is ", code.length);
				}
				//writeln("New function");
				//code[fnEndLoc] = opcodes_meta.DECOMPILER_ENDFUNC;
				//writeln("fnName: ", fnName, " fnNamespace: ", fnNamespace, " fnPackage: ", fnPackage, " has_body: ", has_body, " fnEndLoc: ", fnEndLoc, " argc ", argc);
				//writeln(global_st[code[i]]);
				//writeln(code[ip]);
				//writeln("Code end loc: ", fnEndLoc, " code size: ", code.length);
				//writeln("Thing at code end loc: ", code[fnEndLoc]);
				//writeln("Found a function declaration");
				for(int q = 0; q < argc; q++) {
					argv ~= text(function_st[code[i + 6 + q]]);
				}
				writeln(argv);
			}

			default: {
				writeln("Unhandled");
			}
		}
	}
	//writeln("todo");
}
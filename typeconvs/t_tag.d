module typeconvs.t_tag;
import opcodes : opcode;
import bldso : decompiler;

void tag_to_str(decompiler dec) {
    import utilities : popOffStack;
    import std.string : replace;
    dec.stacks.s_s ~= popOffStack(dec.stacks.s_s).replace("\"", "'");

}

void bootup(decompiler dec) {
	dec.handlers[opcode.OP_TAG_TO_STR] = &tag_to_str;
}

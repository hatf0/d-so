module typeconvs.t_tag;
import opcodes : opcode;
import bldso : decompiler;

void tag_to_str(decompiler dec) {

}

void bootup(decompiler dec) {
	dec.handlers[opcode.OP_TAG_TO_STR] = &tag_to_str;
}

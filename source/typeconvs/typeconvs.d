module typeconvs.typeconvs;
import typeconvs.t_float;
import typeconvs.t_string;
import typeconvs.t_uint;
import typeconvs.t_tag;
import bldso : decompiler;

void registerAll(ref decompiler dec) {
	typeconvs.t_float.bootup(dec);
	typeconvs.t_uint.bootup(dec);
	typeconvs.t_string.bootup(dec);
	typeconvs.t_tag.bootup(dec);
}


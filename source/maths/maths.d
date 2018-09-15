module maths.maths;
import bldso : decompiler;
import maths.binops;
import maths.ops;
import maths.cmps;

void registerAll(ref decompiler dec) {
	maths.binops.bootup(dec);
	maths.ops.bootup(dec);
	maths.cmps.bootup(dec);
}

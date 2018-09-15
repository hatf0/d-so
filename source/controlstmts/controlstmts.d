module controlstmts.controlstmts;
import bldso : decompiler;
import controlstmts.jmps;
import controlstmts.push;
import controlstmts.misc;

void registerAll(ref decompiler dec) {
	controlstmts.jmps.bootup(dec);
	controlstmts.push.bootup(dec);
	controlstmts.misc.bootup(dec);
}




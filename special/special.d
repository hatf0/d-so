module special.special;
import bldso : decompiler;
import special.dechandlers;

void registerAll(decompiler dec) {
    special.dechandlers.bootup(dec);
}


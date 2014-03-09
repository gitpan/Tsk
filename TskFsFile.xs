#define PERL_NO_GET_CONTEXT
#ifdef __cplusplus
extern "C" {
    #endif
    #include "EXTERN.h"
    #include "perl.h"
    #include "XSUB.h"
    #include "ppport.h"
    #ifdef __cplusplus
}
#endif

#include "tsk/libtsk.h"
#include <stdlib.h>
#include <stdio.h>
#include <iostream>
#include <string>

class TskFsMeta;

MODULE = Tsk::Fs::File     PACKAGE = Tsk::Fs::File 

PROTOTYPES: DISABLE

TskFsFile*
TskFsFile::new(TSK_FS_FILE* a_fsFile)

TskFsMeta*
TskFsFile::getMeta()
    CODE:
        const char *CLASS="Tsk::Fs::Meta";
        RETVAL = THIS->getMeta();
        /*SvREFCNT_dec(RETVAL);*/
    OUTPUT:
        RETVAL

TskFsName*
TskFsFile::getName()
    CODE:
        const char *CLASS="Tsk::Fs::Name";
        RETVAL = THIS->getName();
    OUTPUT:
        RETVAL

void
TskFsFile::close()

void
TskFsFile::DESTROY()

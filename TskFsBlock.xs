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
#include <csignal>
#include <stdio.h>
#include <iostream>
#include <string>

MODULE = Tsk::Fs::Block     PACKAGE = Tsk::Fs::Block 

PROTOTYPES: DISABLE

TskFsBlock*
TskFsBlock::new()

uint8_t
TskFsBlock::open(TskFsInfo * a_fs, TSK_DADDR_T a_addr)

SV*
TskFsBlock::getBuf()
    CODE:
        const char *buf = THIS->getBuf();
        RETVAL = newSVpv(buf,strlen(buf)+1);
    OUTPUT:
        RETVAL

TSK_DADDR_T
TskFsBlock::getAddr()

TSK_FS_BLOCK_FLAG_ENUM
TskFsBlock::getFlags()

void
TskFsBlock::DESTROY()


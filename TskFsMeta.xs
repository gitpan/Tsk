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


MODULE = Tsk::Fs::Meta     PACKAGE = Tsk::Fs::Meta 

PROTOTYPES: DISABLE

SV*
nop(self)
    SV* self
    PPCODE:
        printf("test\n");

TSK_OFF_T
TskFsMeta::getSize()


TSK_FS_META_TYPE_ENUM
TskFsMeta::getType()

TSK_FS_META_FLAG_ENUM
TskFsMeta::getFlags()
 
TSK_INUM_T
TskFsMeta::getAddr()

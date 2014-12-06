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

# file time attributes

time_t
TskFsMeta::getMTime()

uint32_t
TskFsMeta::getMTimeNano()

time_t
TskFsMeta::getATime()

uint32_t
TskFsMeta::getATimeNano()

time_t
TskFsMeta::getCTime()

uint32_t
TskFsMeta::getCTimeNano()

time_t
TskFsMeta::getCrTime()

uint32_t
TskFsMeta::getCrTimeNano()

time_t
TskFsMeta::getDTime()

uint32_t
TskFsMeta::getDTimeNano()

time_t
TskFsMeta::getBackUpTime()

uint32_t
TskFsMeta::getBackUpTimeNano()

void
TskFsMeta::DESTROY()

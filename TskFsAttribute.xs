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
#include <string.h>
#include <iostream>
#include <string>


MODULE = Tsk::Fs::Attribute     PACKAGE = Tsk::Fs::Attribute 

PROTOTYPES: DISABLE

const char*
TskFsAttribute::getName()

TSK_OFF_T
TskFsAttribute::getSize()

TSK_FS_ATTR_TYPE_ENUM
TskFsAttribute::getType()

SV*
TskFsAttribute::read(SV* svOff, SV* svLen)
    CODE:
        long off = SvIV(svOff);
        long len = SvIV(svLen);
        printf("[XS] len=%ld\n", len);
        TSK_OFF_T sz = THIS->getSize();
        if(off < sz && len <= sz) {
            char *buffer = (char*)malloc(len+1);
            int cnt = THIS->read(off,buffer,len,(TSK_FS_FILE_READ_FLAG_ENUM)0);
            printf("[XS] read=%d\n",cnt);
            if(cnt == -1) {
                Safefree(buffer);
                RETVAL = &PL_sv_undef;
            } else {
                buffer[cnt] = '\0';
                RETVAL = newSVpv(buffer,cnt);
            };
            free(buffer);
        } else {
            RETVAL = &PL_sv_undef;
        };
    OUTPUT:
        RETVAL


void
TskFsAttribute::DESTROY()
    CODE:
        delete THIS;


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
#include <string.h>

MODULE = Tsk::Vs::Info     PACKAGE = Tsk::Vs::Info

PROTOTYPES: DISABLE

TskVsInfo*
TskVsInfo::new()

void
TskVsInfo::close()

long
TskVsInfo::getBlockSize()

TskVsPartInfo*
TskVsInfo::getPart(int i)
    CODE:
        const char *CLASS="Tsk::Vs::Part::Info";
        RETVAL = const_cast<TskVsPartInfo* >(THIS->getPart(i));
    OUTPUT:
        RETVAL


int
TskVsInfo::getPartCount()

int
TskVsInfo::open(TskImgInfo* img_info, TSK_DADDR_T a_offset, TSK_VS_TYPE_ENUM a_type)

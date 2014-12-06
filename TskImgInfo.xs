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
/*typedef class TskImgInfo Tsk_Img_Info;*/



MODULE = Tsk::Img::Info     PACKAGE = Tsk::Img::Info 

PROTOTYPES: DISABLE

TskImgInfo*
TskImgInfo::new()

int
TskImgInfo::open(char* a_image, TSK_IMG_TYPE_ENUM a_type, unsigned int a_ssize)

void
TskImgInfo::DESTROY()

long
TskImgInfo::getPointer()
    CODE:
        RETVAL=(long)THIS;
    OUTPUT:
        RETVAL

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
/*typedef class TskFsInfo Tsk_Img_Info;*/



MODULE = Tsk::Fs::Info     PACKAGE = Tsk::Fs::Info 

PROTOTYPES: DISABLE

TskFsInfo*
TskFsInfo::new()

int
TskFsInfo::open(TskImgInfo *a_img_info,TSK_OFF_T a_offset, TSK_FS_TYPE_ENUM a_ftype)

void
TskFsInfo::close()
 
long
TskFsInfo::getRootINum()

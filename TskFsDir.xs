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


MODULE = Tsk::Fs::Dir     PACKAGE = Tsk::Fs::Dir 

PROTOTYPES: DISABLE

TskFsDir*
TskFsDir::new()

int
TskFsDir::open(TskFsInfo* a_fs_info, TSK_INUM_T a_addr)

long
TskFsDir::getSize()

TskFsFile*
TskFsDir::getFile(int a_idx)
    CODE:
	const char *CLASS = "Tsk::Fs::File";
        RETVAL = THIS->getFile(a_idx);
    OUTPUT:
        RETVAL

void
TskFsDir::close()

void
TskFsDir::DESTROY()

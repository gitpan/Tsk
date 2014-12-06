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
/*typedef class TskFsInfo Tsk_Img_Info;*/


MODULE = Tsk::Fs::Dir     PACKAGE = Tsk::Fs::Dir 

PROTOTYPES: ENABLE

TskFsDir*
TskFsDir::new()

int
TskFsDir::open(TskFsInfo* a_fs_info, TSK_INUM_T a_addr)


long
TskFsDir::getMetaAddr()
    CODE:
        RETVAL = THIS->getMetaAddr();
    OUTPUT:
        RETVAL

long
TskFsDir::getSize()

void
TskFsDir::getFile(int a_idx)
    PPCODE:
        TskFsFile *f = THIS->getFile(a_idx);
        if(f) {
            SV* sv = NEWSV(0,0);
            SV* svf = newRV_noinc(sv);
            sv_setref_pv(svf,(char*)"Tsk::Fs::File",(void*)f);
            ST(0) = svf;
            PUTBACK;
            XSRETURN(1);
        } else {
            delete f;
            XPUSHs(&PL_sv_undef);
        };

void
TskFsDir::close()



TskFsFile *
TskFsDir::getFsFile()
    PPCODE:
        TskFsFile *f = const_cast<TskFsFile *>(THIS->getFsFile());
        if(f) {
            SV* sv = NEWSV(0,0);
            SV* svf = newRV_noinc(sv);
            sv_setref_pv(svf,(char*)"Tsk::Fs::File",(void*)f);
            XPUSHs(svf);
        } else {
            delete f;
            XPUSHs(&PL_sv_undef);
        }

void
TskFsDir::DESTROY()
    CODE:
        //sv_reftype
        /*printf("dealloc=%ld package=%s\n",THIS,"Tsk::Fs::Dir");*/
        delete THIS;

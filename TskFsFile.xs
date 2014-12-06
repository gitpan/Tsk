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

class TskFsMeta;
class TskFsAttribute;

MODULE = Tsk::Fs::File     PACKAGE = Tsk::Fs::File 

PROTOTYPES: DISABLE

TskFsFile*
TskFsFile::new()

TskFsMeta*
TskFsFile::getMeta()
    PPCODE:
        TskFsMeta *f = THIS->getMeta();
        if(f) {
            SV* sv = NEWSV(0,0);
            SV* svf = newRV_noinc(sv);
            sv_setref_pv(svf,(char*)"Tsk::Fs::Meta",(void*)f);
            XPUSHs(svf);
        } else {
            delete f;
            XPUSHs(&PL_sv_undef);
        }


int
TskFsFile::open(TskFsInfo* a_fs_info,TskFsFile* a_fs_file,TSK_INUM_T a_addr)
    CODE:
        if(a_fs_file==NULL) {
            RETVAL = THIS->open(a_fs_info,NULL,a_addr);
        } else {
            RETVAL = THIS->open(a_fs_info,reinterpret_cast<TskFsFile *>(a_fs_file), a_addr);
        };
    OUTPUT:
        RETVAL


long
TskFsFile::getSize()
    CODE:
        long l_size = THIS->getMeta()->getSize();
        printf("[DBG] xs file size=%ld\n",l_size);
        RETVAL = l_size;
    OUTPUT:
        RETVAL

SV*
TskFsFile::read(SV* svOff, SV* svLen)
    CODE:
        long off = SvIV(svOff);
        long len = SvIV(svLen);
        TSK_OFF_T sz = THIS->getMeta()->getSize();
        if(off < sz) {
            char *buffer = (char*)malloc(len+1);
            int cnt = THIS->read(off,buffer,len,(TSK_FS_FILE_READ_FLAG_ENUM)0);
            if(cnt == -1) {
                Safefree(buffer);
                RETVAL = &PL_sv_undef;
            } else {
                buffer[cnt] = '\0';
                RETVAL = newSVpv(buffer,strlen(buffer)+1);
            };
        } else {
            RETVAL = &PL_sv_undef;
        };
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


# 
# Getting filename from either the TskFsName or the TskFsMeta
# data structure
# 

SV*
TskFsFile::getFileName()
    CODE:
        TskFsName* tsk_fs_name = NULL;
        tsk_fs_name = THIS->getName();
        if(tsk_fs_name && tsk_fs_name->getName()) {
            char * str_retval = const_cast<char*>(tsk_fs_name->getName());
            SV* sv_retval = newSVpv(str_retval,strlen(str_retval));
            RETVAL = sv_retval;
        } else {
            TskFsMeta* tsk_fs_meta = NULL;
            tsk_fs_meta = THIS->getMeta();
            if(tsk_fs_meta && tsk_fs_meta->getName2Count() > 0) {
                const TskFsMetaName* tsk_fs_meta_name = tsk_fs_meta->getName2(0);
                if(tsk_fs_meta_name) {
                    TskFsMetaName* meta_name = const_cast<TskFsMetaName *>(tsk_fs_meta_name);
                    if(meta_name) {
                        const char* str_name = meta_name->getName();
                        if(str_name) {
                            char * str_retval = const_cast<char*>(str_name);
                            SV* sv_retval = newSVpv(str_retval,strlen(str_retval));
                            RETVAL = sv_retval;
                        };
                        delete meta_name;
                    } else {
                        RETVAL = &PL_sv_undef;
                    };
                }else {
                    RETVAL = &PL_sv_undef;
                };
            }else {
                RETVAL = &PL_sv_undef;
            };
            delete tsk_fs_meta;
        };
        delete tsk_fs_name;
    OUTPUT:
        RETVAL



void
TskFsFile::DESTROY()
    CODE:
        THIS->close();
        delete THIS;


int
TskFsFile::getAttrSize()


# TODO: add both 1-arg and 3-arg forms (by checking arity)

TskFsAttribute*
TskFsFile::getAttr(int a_idx)
    PPCODE:
        const TskFsAttribute *a_const = THIS->getAttr(a_idx);
        TskFsAttribute *a = const_cast<TskFsAttribute* >(a_const);
        if(a) {
            SV* sv = NEWSV(0,0);
            SV* svf = newRV_noinc(sv);
            sv_setref_pv(svf,(char*)"Tsk::Fs::Attribute",(void*)a);
            XPUSHs(svf);
        } else {
            delete a;
            XPUSHs(&PL_sv_undef);
        }



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


MODULE = Tsk::Fs::Name     PACKAGE = Tsk::Fs::Name 

PROTOTYPES: DISABLE

# TskFsName*
# TskFsName::new()
# 
const char*
TskFsName::getName()
#
# void
# TskFsName::DESTROY()

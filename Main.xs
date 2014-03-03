#define PERL_NO_GET_CONTEXT
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "ppport.h"

#define stack_fix(directive) do { \
    PUSHMARK(SP); \
    PUTBACK; \
    directive; \
    SPAGAIN; \
    PUTBACK; \
} while(0)

XS(boot_Tsk__Exp);
XS(boot_Tsk__Img__Info);
XS(boot_Tsk__Vs__Info);
XS(boot_Tsk__Vs__Part__Info);
XS(boot_Tsk__Fs__Info);
XS(boot_Tsk__Fs__File);
XS(boot_Tsk__Fs__Dir);
XS(boot_Tsk__Fs__Meta);
XS(boot_Tsk__Fs__Name);
XS(boot_Tsk__Stack);



MODULE = Tsk PACKAGE = Tsk
BOOT:
stack_fix(boot_Tsk__Fs__Meta(aTHX_ cv));
stack_fix(boot_Tsk__Img__Info(aTHX_ cv));
stack_fix(boot_Tsk__Vs__Info(aTHX_ cv));
stack_fix(boot_Tsk__Vs__Part__Info(aTHX_ cv));
stack_fix(boot_Tsk__Fs__Info(aTHX_ cv));
stack_fix(boot_Tsk__Fs__Dir(aTHX_ cv));
stack_fix(boot_Tsk__Fs__File(aTHX_ cv));
stack_fix(boot_Tsk__Fs__Name(aTHX_ cv));
stack_fix(boot_Tsk__Stack(aTHX_ cv));
stack_fix(boot_Tsk__Exp(aTHX_ cv));



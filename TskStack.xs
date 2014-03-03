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

class TskStack {
    TSK_STACK *s;
    public:
        TskStack() {
            s = tsk_stack_create();
        };
        ~TskStack() {
            tsk_stack_free(s);
        };
        void push(uint64_t k) {
            tsk_stack_push(s,k);
        };
        void pop() {
            tsk_stack_pop(s);
        };
        long top() {
            return s->top;
        };
        uint8_t find(uint64_t k) {
            return tsk_stack_find(s,k);
        };
        size_t length() {
            return s->len;
        };
};


MODULE = Tsk::Stack     PACKAGE = Tsk::Stack 

PROTOTYPES: DISABLE

TskStack*
TskStack::new()

void
TskStack::DESTROY()

void
TskStack::push(long k)

void
TskStack::pop()

int
TskStack::find(long k)

long
TskStack::length()

long
TskStack::top()

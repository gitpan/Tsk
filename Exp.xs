#define PERL_NO_GET_CONTEXT
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "ppport.h"
#include "tsk/libtsk.h"
#include <stdlib.h>
#include <stdio.h>
#include <iostream>
#include <string>

/*
 * Experimental XS
 *
 */



static uint8_t
procDir(TskFsInfo * fs_info, TSK_STACK * stack,
    TSK_INUM_T dir_inum, const char *path)
{
    TskFsDir *fs_dir = new TskFsDir();
    size_t i;
    char *path2 = NULL;
    char *buf = NULL;

    // open the directory
    if ((fs_dir->open(fs_info, dir_inum)) == 1) {
        fprintf(stderr, "Error opening directory: %" PRIuINUM "\n",
            dir_inum);
        tsk_error_print(stderr);
        return 1;
    }

    /*std::cout<<fs_dir->getName();*/

    /* These should be dynamic lengths, but this is just a sample program.
     * Allocate heap space instead of stack to prevent overflow for deep
     * directories. */
    if ((path2 = (char *) malloc(4096)) == NULL) {
        return 1;
    }

    if ((buf = (char *) malloc(2048)) == NULL) {
        free(path2);
        return 1;
    }

    // cycle through each entry
    for (i = 0; i < fs_dir->getSize(); i++) {
        TskFsFile *fs_file;
        TSK_OFF_T off = 0;
        size_t len = 0;


        // get the entry
        if ((fs_file = fs_dir->getFile(i)) == NULL) {
            fprintf(stderr,
                "Error getting directory entry %" PRIuSIZE
                " in directory %" PRIuINUM "\n", i, dir_inum);
            tsk_error_print(stderr);

            free(path2);
            free(buf);
            return 1;
        }

        /* Ignore NTFS System files */
        if ((TSK_FS_TYPE_ISNTFS(fs_file->getFsInfo()->getFsType())) &&
            (const_cast<TskFsName *>(fs_file->getName())->getName()[0] == '$')) {
            printf("===>Ignored NTFS filesystem\n");
            fs_file->close();
            continue;
        }

        // make sure it's got metadata and not only a name
        if (fs_file->getMeta()) {
            ssize_t cnt;

            printf("====> Found File -> %s \n", fs_file->getName()->getName());

            // read file contents
            if (fs_file->getMeta()->getType() == TSK_FS_META_TYPE_REG) {
                int myflags = 0;
                TSK_OFF_T fSize = fs_file->getMeta()->getSize();
                for (off = 0; off < fSize; off += len) {
                    if (fSize - off < 2048)
                        len = (size_t) (fSize - off);
                    else
                        len = 2048;

                    cnt = fs_file->read(off, buf, len,
                        (TSK_FS_FILE_READ_FLAG_ENUM) myflags);
                    if (cnt == -1) {
                        // could check tsk_errno here for a recovery error (TSK_ERR_FS_RECOVER)
                        fprintf(stderr, "Error reading %s file: %s\n",
                            ((fs_file->getName()->getFlags()
                                     & TSK_FS_NAME_FLAG_UNALLOC)
                                || (fs_file->getMeta()->getFlags()
                                     & TSK_FS_META_FLAG_UNALLOC)) ?
                            "unallocated" : "allocated",
                            fs_file->getName()->getName());
                        tsk_error_print(stderr);
                        break;
                    }
                    else if (cnt != (ssize_t) len) {
                        fprintf(stderr,
                            "Warning: %" PRIuSIZE " of %" PRIuSIZE
                            " bytes read from %s file %s\n", cnt, len,
                            ((fs_file->getName()->getFlags()
                                    & TSK_FS_NAME_FLAG_UNALLOC)
                                || (fs_file->getMeta()->getFlags()
                                    & TSK_FS_META_FLAG_UNALLOC)) ?
                            "unallocated" : "allocated",
                            fs_file->getName()->getName());
                    }

                    // do something with the data...
                }
            }

            // recurse into another directory (unless it is a '.' or '..')
            else if (fs_file->getMeta()->getType() == TSK_FS_META_TYPE_DIR) {
                if (TSK_FS_ISDOT(fs_file->getName()->getName()) == 0) {

                    // only go in if it is not on our stack
                    if (tsk_stack_find(stack, fs_file->getMeta()->getAddr()) == 0) {
                        // add the address to the top of the stack
                        tsk_stack_push(stack, fs_file->getMeta()->getAddr() );

                        snprintf(path2, 4096, "%s/%s", path,
                            fs_file->getName()->getName());
                        if (procDir(fs_info, stack, fs_file->getMeta()->getAddr(),
                                path2)) {
                            fs_file->close();
                            fs_dir->close();
                            free(path2);
                            free(buf);
                            return 1;
                        }

                        // pop the address
                        tsk_stack_pop(stack);
                    }
                }
            }
        }
        fs_file->close();
    }
    fs_dir->close();

    free(path2);
    free(buf);
    return 0;
}

static uint8_t
procFs(TskImgInfo * img_info, TSK_OFF_T start)
{
    TskFsInfo *fs_info = new TskFsInfo();
    TSK_STACK *stack;

    /* Try it as a file system */
    if ((fs_info->open(img_info, start, TSK_FS_TYPE_DETECT)) == 1)
    {
        fprintf(stderr,
            "Error opening file system in partition at offset %" PRIuOFF
            "\n", start);
        tsk_error_print(stderr);

        /* We could do some carving on the volume data at this point */

        return 1;
    }

    // create a stack to prevent infinite loops
    stack = tsk_stack_create();

    // Process the directories
    if (procDir(fs_info, stack, fs_info->getRootINum(), "")) {
        fprintf(stderr,
            "Error processing file system in partition at offset %" PRIuOFF
            "\n", start);
        delete fs_info;
        return 1;
    }

    tsk_stack_free(stack);

    /* We could do some analysis of unallocated blocks at this point...  */

    delete fs_info;
    return 0;
}

static uint8_t
procVs(TskImgInfo * img_info, TSK_OFF_T start)
{
    TskVsInfo *vs_info = new TskVsInfo();

    // Open the volume system
    if ((vs_info->open(img_info, start, TSK_VS_TYPE_DETECT)) == 1) {
        if (tsk_verbose)
            fprintf(stderr,
                "Error determining volume system -- trying file systems\n");

        /* There was no volume system, but there could be a file system */
        tsk_error_reset();
        if (procFs(img_info, start)) {
            return 1;
        }
    }
    else {
        fprintf(stderr, "Volume system open, examining each\n");

        // cycle through the partitions
        printf("Found Parts => %d\n", vs_info->getPartCount());
        for (TSK_PNUM_T i = 0; i < vs_info->getPartCount(); i++) {
            const TskVsPartInfo *vs_part;

            printf("Partition Detected !\n");
            if ((vs_part = vs_info->getPart(i)) == NULL) {
                fprintf(stderr, "Error getting volume %" PRIuPNUM "\n", i);
                continue;
            }

            // ignore the metadata partitions
            if (const_cast<TskVsPartInfo *>(vs_part)->getFlags() & TSK_VS_PART_FLAG_META)
                continue;

            // could do something with unallocated volumes
            else if (const_cast<TskVsPartInfo *>(vs_part)->getFlags() & TSK_VS_PART_FLAG_UNALLOC) {

            }
            else {
                printf("==> Processing file system\n");
                if (procFs(img_info,
                    const_cast<TskVsPartInfo *>(vs_part)->getStart() * vs_info->getBlockSize())) {
                    // We could do more fancy error checking here to see the cause 
                    // of the error or consider the allocation status of the volume...
                    tsk_error_reset();
                }
            }
        }
        vs_info->close();
    }
    return 0;
}

/*
 *XS(boot_Tsk__Exp)
 *{
 *}
 */

MODULE = Tsk::Exp   PACKAGE = Tsk::Exp


SV*
open_disk(self,path)
  SV* self
  SV* path
  CODE:
    HV  *__hv_self = (HV*) SvRV(self);
    /*
     *SV  *__path = SvPV(path, path_len);
     *hv_store(__hv_self,"key1",4,newSViv(13),0);
     */

    /*SV **prop_sv = hv_fetch(__hv_self,"img_info",8,0);*/
    STRLEN path_len;
    char *path_str;
    path_str = SvPV(path,path_len);
    printf("keyval = %s\n", path_str);

    TskImgInfo *img_info = new TskImgInfo();
    img_info->open((const TSK_TCHAR *) path_str, TSK_IMG_TYPE_DETECT, 0);
    if (img_info == NULL) {
        fprintf(stderr, "Error opening file\n");
        /*tsk_error_print(stderr);*/
        croak("");
        exit(1);
    }
    if (procVs(img_info, 0)) {
        tsk_error_print(stderr);
        delete img_info;
        exit(1);
    }
  
    RETVAL = NULL;
  OUTPUT:
    RETVAL


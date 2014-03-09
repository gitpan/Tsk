use strict;
use warnings;
use Test::More qw/no_plan/;
use Data::Dumper;
use Devel::Peek;
BEGIN { use_ok('Tsk::Fs::Info'); };
use Tsk::Img::Info;
use Tsk::Fs::Info;
use Tsk::Fs::Dir;
use Tsk::Fs::File;
use Tsk::Stack;
use Digest::MD5 qw/md5_hex/;
use Devel::Symdump;

# Invariant type of $fs_file
my $inv_fs_file = 1;
# Invariant type of $fs_dir
my $inv_fs_dir  = 1;

# TskFsFile namespace functions
my $h_namespace = { map { ($_ => 1) } (Devel::Symdump->functions("Tsk::Fs::File")) };
ok($h_namespace->{"Tsk::Fs::File::new"} == 1, "::new method present");
ok($h_namespace->{"Tsk::Fs::File::getName"} == 1, "::getName method present");
ok($h_namespace->{"Tsk::Fs::File::getMeta"} == 1, "::getMeta method present");

#my $path = "test_image.dsk";
my $path = "testdata/testimage001.001";
my $img_info = Tsk::Img::Info->new();
$img_info->open($path,$TSK_IMG_TYPE_DETECT,0);

my @file_list = ();

sub procFs {
    my ($fs_info,$stack,$dir_inum,$path) = @_;

    my $fs_dir = Tsk::Fs::Dir->new();
    $fs_dir->open($fs_info,$dir_inum);
    my $fs_dir_sz = $fs_dir->getSize();
    $inv_fs_dir &= (ref($fs_dir) eq "Tsk::Fs::Dir");

    for(my $i=0;$i<$fs_dir_sz;$i++) {
        my $fs_file = $fs_dir->getFile($i);
        my $fs_meta = $fs_file->getMeta();
        my $fs_name = $fs_file->getName();
        $inv_fs_file &= (ref($fs_file) eq "Tsk::Fs::File");

        if($fs_meta) {
            my $type = $fs_meta->getType();
            my $str_name;

            if($fs_name) {
                $str_name = $fs_name->getName();
            };
            if($str_name =~ /^\$/) {
                # ignore NTFS System files
                $fs_file->close();
                next;
            };

            next if $str_name eq "." || $str_name eq "..";
            if(      $type == $TSK_FS_META_TYPE_DIR) {
                if($stack->find($fs_meta->getAddr())==0) {
                    $stack->push($fs_meta->getAddr());
                    my $path2 = $path."/".$str_name;
                    #print "$path2/$str_name\n";
                    push @file_list, "$path2/$str_name";
                    if(procFs($fs_info,$stack,$fs_meta->getAddr(),$path2)) {
                        $fs_file->close();
                        $fs_dir->close();
                        return 1;
                    };
                    $stack->pop();
                };
            } elsif( $type == $TSK_FS_META_TYPE_REG) {
                push @file_list, "$path/$str_name";
                #print "$path/$str_name\n";
            };
        };
        $fs_file->close();
    };
    $fs_dir->close();
    return 0;
};

my $fs_info = Tsk::Fs::Info->new();
$fs_info->open($img_info, 65536, $TSK_FS_TYPE_DETECT);
#$fs_info->open($img_info, , $TSK_FS_TYPE_DETECT);
my $dir_inum = $fs_info->getRootINum();
my $stack = Tsk::Stack->new();

push @file_list,"/";
procFs($fs_info,$stack,$dir_inum,"");

my @sorted_file_list = sort { $a cmp $b } @file_list;
my $md5_file_list = md5_hex(join("||",@sorted_file_list));
is($md5_file_list, "4aec1a061bb37a8770907654eeb254a0", "file list MD5 looks good");

#ok($dir_inum==5,"5 inodes");
ok($inv_fs_file == 1, "Invariant I");
ok($inv_fs_dir  == 1, "Invariant II");

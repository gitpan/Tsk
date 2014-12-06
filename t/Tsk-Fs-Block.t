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

my $path = "testdata/testimage001.001";
my $img_info = Tsk::Img::Info->new();
$img_info->open($path,$TSK_IMG_TYPE_DETECT,0);
my $fs_info = Tsk::Fs::Info->new();
$fs_info->open($img_info, 65536, $TSK_FS_TYPE_DETECT);

my $first_blk = $fs_info->getFirstBlock();
my $last_blk  = $fs_info->getLastBlock();
is($first_blk , 0    , "First block check");
is($last_blk  , 1534 , "Last block check");


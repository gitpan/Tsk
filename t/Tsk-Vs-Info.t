use strict;
use warnings;
use Test::More qw/no_plan/;
use Data::Dumper;
BEGIN { use_ok('Tsk::Vs::Info'); };
use Tsk::Img::Info;
use Tsk::Vs::Info;

#my $path = "test_image.dsk";
my $path = "./testdata/testimage001.001";
my $img_info = Tsk::Img::Info->new();
$img_info->open($path,$TSK_IMG_TYPE_DETECT,0);
ok(defined($img_info),"Tsk::Img::Info object was defined");
my $vs_info = Tsk::Vs::Info->new();
ok(defined($vs_info),"Tsk::Vs::Info object was defined");

my $c_meta    = 0;
my $c_unalloc = 0;
my $c_valid   = 0;
if($vs_info->open($img_info, 0, $TSK_VS_TYPE_DETECT) == 1) {
    ok(defined($vs_info->getPartCount()),"return value of Tsk::Vs::Info::getPartCount was defined");
    ok($vs_info->getPartCount() == 0, "There was no volume system in the disk image");
} else {
    for(my $i = 0; $i < $vs_info->getPartCount(); $i++) {
        my $vs_part = $vs_info->getPart($i);
        my $start  = $vs_part->getStart() * $vs_info->getBlockSize();
        my $flags = $vs_part->getFlags();
        #print "part=$vs_part start=$start\n";
        if($flags & $TSK_VS_PART_FLAG_META) {
            $c_meta++;
        } elsif($flags & $TSK_VS_PART_FLAG_UNALLOC) {
            $c_unalloc++;
        } else {
            $c_valid++;
        };
    };
};

ok($c_meta    == 1 ,"1 meta filesystem"    );
ok($c_unalloc == 2 ,"2 unalloc filesystems");
ok($c_valid   == 1 ,"1 valid filesystem"   );

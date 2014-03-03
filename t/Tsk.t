use strict;
use warnings;
use Test::More qw/no_plan/;
BEGIN { use_ok('Tsk'); };



my $flag = 0;
$flag |= $TSK_FS_META_FLAG_ALLOC;
$flag |= $TSK_FS_META_FLAG_USED ;

my @flags_on_list = describe_flag($flag,qr/TSK_FS_META_FLAG/);
my $h = { map { $_ => 1 } @flags_on_list };

ok(@flags_on_list == 2            , "describe_flag test1");
ok($h->{'$TSK_FS_META_FLAG_ALLOC'}, "describe_flag test2");
ok($h->{'$TSK_FS_META_FLAG_USED'} , "describe_flag test3");



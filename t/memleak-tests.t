use strict;
use warnings;
use constant HAS_LEAKTRACE => eval{ require Test::LeakTrace };
use Test::More 
    HAS_LEAKTRACE 
        ? qw/no_plan/
        : (skip_all => 'Test::LeakTrace is required for memory leak tests.');
use Test::LeakTrace;

ok(1);
# currently disabled
exit(0);


no_leaks_ok {
    use Tsk;
    use Tsk::Fs::Iterator;
    my $path = "testdata/testimage001.001";
    my $o = Tsk::Fs::Iterator->new($path, 65536);
    while(my $f = $o->next()) {
        if($f->{fs_file}) {
            print $f->{name}."\n";
            #my $sz = $f->{fs_file}->getSize();
        };
    };
} "using iterators doesn\'t produce any leaks";


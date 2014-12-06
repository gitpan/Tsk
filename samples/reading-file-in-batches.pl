#!/usr/bin/env perl
use strict;
use warnings;
use lib './lib';
use lib './blib/arch/auto/Tsk';
use Tsk;
use Tsk::Fs::Iterator2;
use Devel::Peek;
my $iter = Tsk::Fs::Iterator2->new("./testdata/testimage001.001");
my $chunk_size = 40;

## Overview: Finding the file "NEWS.txt" in the test image
## and reading it in chunks of 40 bytes.

OUTER:
while(my $file = $iter->next()) { 
    next unless ref($file) eq "Tsk::Fs::File";
    my $name = $file->getFileName();
    my $size = $file->getSize();
    if($name eq "NEWS.txt") {
        my $start = 0;
        my $end   = $chunk_size;
        while($start <= $size) {
            if($end > $size){
                $end = $size;
            };
            my $bytes_to_read = ($end-$start+1);
            my $chunk = $file->read($start, $bytes_to_read);
            $chunk =~ s/\n/[EOL]/;
            print "[CHUNK] $chunk\n";
            ($start,$end) = ($end+1,$end+$chunk_size);
        };
        ## the file has been found and read, so we end the loop
        last OUTER;
    }
}

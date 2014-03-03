#!/usr/bin/env perl
use 5.012005;
use ExtUtils::MakeMaker;
use Carp;

my $SLEUTHKIT_HEADERS = "$ENV{PWD}/sleuthkit-4.1.2/";
my $SLEUTHKIT_LIBS    = "$ENV{PWD}/sleuthkit-4.1.2/tsk/.libs";

`cd $SLEUTHKIT_HEADERS; ./configure ; make;`;

if(!-f "$SLEUTHKIT_LIBS/libtsk.so") {
    croak "[ERROR] Please compile sleuthkit first";
};

my $CC = "g++ -g";
WriteMakefile(
    NAME              => 'Tsk',
    VERSION_FROM      => 'lib/Tsk.pm', # finds $VERSION
    PREREQ_PM         => {}, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/Tsk.pm', # retrieve abstract from module
       AUTHOR         => 'Stefan Petrea <stefan@garage-coding.com>') : ()),
    CCFLAGS           => " ",
    LDFLAGS           => "  -Wl,-Bstatic",
    LIBS              => ["-L$SLEUTHKIT_LIBS -ltsk -lstdc++"], # e.g., '-lm'
    #LINKTYPE          => 'static',
    #XSOPT             => "-C++ -nolinenumbers",
    XSOPT             => "-C++",
    DEFINE            => '-DDEBUG', # e.g., '-DHAVE_SOMETHING',
    CC                => $CC,
    BUILD_REQUIRES    => {
            'ExtUtils::MakeMaker' => 6.48,
            'ExtUtils::XSpp'      => 0.1602,
            'Devel::Symdump'      => 2.11,
            'Digest::MD5'         => 2.53,
            'Devel::Peek'         => undef,
    },
    XS                => {
        "Main.xs"          => "Main.c",
        "Exp.xs"           => "Exp.c",
        "TskFsName.xs"     => "TskFsName.c",
        "TskFsMeta.xs"     => "TskFsMeta.c",
        "TskFsFile.xs"     => "TskFsFile.c",
        "TskFsInfo.xs"     => "TskFsInfo.c",
        "TskFsDir.xs"      => "TskFsDir.c",
        "TskVsInfo.xs"     => "TskVsInfo.c",
        "TskVsPartInfo.xs" => "TskVsPartInfo.c",
        "TskImgInfo.xs"    => "TskImgInfo.c",
        "TskStack.xs"      => "TskStack.c",
    },
    INC               => "-I$SLEUTHKIT_HEADERS -I.", # e.g., '-I. -I/usr/include/other'
    OBJECT            => '$(O_FILES)', 
    TYPEMAPS          => ['perlobject.map'],
);

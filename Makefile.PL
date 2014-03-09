#!/usr/bin/env perl
use 5.012005;
use ExtUtils::MakeMaker;
use Carp;

#my $PBREWPATH         = "$ENV{PERLBREW_ROOT}/perls/$ENV{PERLBREW_PERL}/lib";
my $SLEUTHKIT_BASE    = "$ENV{PWD}/sleuthkit-4.1.2/";
my $SLEUTHKIT_HEADERS =  $SLEUTHKIT_BASE;
my $LIBEWF_BASE       = "$ENV{PWD}/libewf";
my $SLEUTHKIT_LIBS    = "$ENV{PWD}/sleuthkit-4.1.2/tsk/.libs";
my $AFFLIB_BASE       = "$ENV{PWD}/AFFLIBv3";
my $AFFLIB_DEPDIR     = "$ENV{PWD}/AFFLIBv3/sandbox";

######################
# Build dependencies #
######################

my $deps_build = qq{
  cd $LIBEWF_BASE;
      make clean;
      rm Makefile;
      ./configure;
      make;
      ln -s libewf/.libs lib;
  cd ..;
  echo "===========================";
  cd $AFFLIB_BASE;
      make clean;
      rm Makefile;
      ./bootstrap.sh;
      ./configure;
      make;
      mkdir sandbox;
      cd sandbox;
          ln -s ../lib include;
          ln -s ../lib/.libs lib;
      cd ..
  cd ..;
  echo "===========================";
  cd $SLEUTHKIT_BASE; 
      make clean;
      rm Makefile;
      ./configure --with-libewf=$LIBEWF_BASE --with-afflib=$AFFLIB_DEPDIR; 
  make;
};

system($deps_build);

if(!-f "$SLEUTHKIT_LIBS/libtsk.so") {
    croak "[ERROR] Please compile sleuthkit first";
};

my $CC = "g++";
WriteMakefile(
    NAME              => 'Tsk',
    VERSION_FROM      => 'lib/Tsk.pm', 
    PREREQ_PM         => {}, 
    ($] >= 5.005 ?     
      (ABSTRACT_FROM  => 'lib/Tsk.pm',
       AUTHOR         => 'Stefan Petrea <stefan@garage-coding.com>') : ()),
    #LIBS              => ["-L$SLEUTHKIT_LIBS -L$PBREWPATH -ltsk -lstdc++"], # e.g., '-lm'
    LIBS              => ["-L$SLEUTHKIT_LIBS -ltsk -lstdc++"], # e.g., '-lm'
    #LINKTYPE          => 'static',
    #XSOPT             => "-C++ -nolinenumbers",
    XSOPT             => "-C++",
    DEFINE            => '-DDEBUG', # e.g., '-DHAVE_SOMETHING',
    OPTIMIZE          => '-O0 -g',
    CC                => $CC,
    CCFLAGS           => "-Wall",
    #LDDLFLAGS          => "-DDEBUG -O0 -g -shared -Wl,-rpath $SLEUTHKIT_LIBS",
    LDDLFLAGS          => "-DDEBUG -O0 -g -shared",
    BUILD_REQUIRES    => {
            'ExtUtils::MakeMaker' => 6.48,
            'ExtUtils::XSpp'      => 0.1602,
            'Devel::Symdump'      => 2.11,
            'Digest::MD5'         => 2.53,
            #'Devel::Peek'         => undef,
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

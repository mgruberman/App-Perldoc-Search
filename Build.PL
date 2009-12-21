#!/usr/bin/perl
use strict;
use 5.006;
use warnings;
use Module::Build;
my $build = Module::Build->new(
    module_name => 'App::Perldoc::Search',
    license => 'perl',
    build_requires => {
        'Test::More' => 0,
        'IPC::Run' => 0,
    },
    requires => {
        # Core
        'perl' => '5.6.0',
        'strict' => 0,
        'warnings' => 0,
        'Module::Build' => 0,
        'File::Find' => 0,
        'Getopt::Long' => 0,
        'Pod::Usage' => 0,
        'IO::File' => 0,
        'IO::Seekable' => 0,

        # CPAN
    },
    scripts => [qw[
        script/perldoc-search
    ]],
);
$build->create_build_script;

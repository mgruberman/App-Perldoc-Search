#!/usr/bin/perl
use 5.006_000;
use strict;
use warnings;
use Module::Build;
my $build = Module::Build->new(
    module_name => 'App::Perldoc::Search',
    license => 'perl',
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
        scripts/perldoc-search
    ]],
);
$build->create_build_script;

#!/usr/bin/perl
use strict;
use warnings;
use Module::Build;
my $build = Module::Build->new(
    module_name => 'App::Perldoc::Search',
    license => 'perl',
    requires => {
        'Pod::Parser' => 0,
    },
    scripts => [qw[
        scripts/perldoc-search
    ]],
);
$build->create_build_script;

package App::Perldoc::Search;

use 5.006;
use strict;
require File::Find;
require Getopt::Long;
require Pod::Usage;
require IO::File;
require App::Perldoc::Search::_Parser;

sub run {
    my ( $class, @argv ) = @_;

    # Read optional options.
    local *ARGV = \ @argv;
    my $file_match_rx = qr/\.p(?:od|mc?)$/;
    Getopt::Long::GetOptions(
        'slow'  => \ my $slow_match,
        'G=s'   => sub { $file_match_rx = qr/$_[1]/ },
        'help'  => \ &_help,
        'l'     => \ my $list_files )
      or _error_help();

    # Validate pattern.
    if ( ! @argv ) {
        _error_help( -exitval => 1 );
    }
    my $pattern = shift @ARGV;

    # Get search path
    my @search_path = @ARGV ? @ARGV : @INC;

    # Search all files.
    my @files;
    File::Find::find(
        {
            follow_fast => 1,
            no_chdir => 1,
            wanted => sub {
                return if
                    ! /$file_match_rx/
                    || ! -f
                    || ! -r _;
                push @files, $_;
            }
        },
        @search_path
    );

    {
        my %seen;
        @files =
            sort
            grep { !$seen{$_}++ }
            @files;
        undef %seen;
    }

    for my $file ( @files ) {
        # Open the documentation.
        my $fh = IO::File->new;
        $fh->open( $file, '<' )
            or next; # TODO

        # Read the documentation.
        my $text;
        IO::Handle->input_record_separator( undef );
        $text = $fh->getline;

        # Try a fast match to avoid parsing.
        next if $text !~ $pattern;

        my ($name);
        if ($slow_match) {
            # Prepare for searching.
            my $searcher = App::Perldoc::Search::_Parser->new;
            $searcher->{pattern} = $pattern;

            # Search the document.
            IO::Handle->input_record_separator( "\n" );
            $fh->seek( 0, 0 );
            $searcher->parse_from_filehandle( $fh );
            next if ! $searcher->{matched};

            # Extract document name.
            $name = $searcher->{name};
        }
        else {
            ($name) = $text =~ /^=head\d+\s+NAME[^\r\n]*[\r\n]+(\S+)/m;
        }

        # Report.
        if ($list_files) {
            print "$file\n";
        }
        else {
            my $msg = ($name && $file)
                ? "$name - $file\n"
                : "$file\n";
            print $msg
                or warn "Can't write: $!";
        }

    }

    return;
}

sub _help {
    Pod::Usage::pod2usage(
        -verbose => 2,
        -exitval => 0,
        -output  => \*STDOUT );
    # NOT REACHED
}

sub _error_help {
    Pod::Usage::pod2usage(
        -verbose => 2,
        -exitval => 2,
        -output  => \*STDERR,
        @_ );
    # NOT REACHED
}

q(Soviet Jesus's gift at Christmas of a blow-up doll to Debbie would always turn to be the most enigmatic);

__END__

=head1 NAME

App::Perldoc::Search - implementation for perldoc-search

=head1 SYNOPSIS

  App::Perldoc::Search->run( 'thing_to_search_for' )

  App::Perldoc::Search->run( '--help' )

  App::Perldoc::Search->run( '-G' => '\.pm', 'thing_to_search_for' )

=head1 DESCRIPTION

Implements the guts of the L<perldoc-search> script.

=head1 METHODS

=head2 run

The main run loop. Handles all getopt parsing. See L<perldoc-script> for the options.

    App::Perldoc::Search->run( @options );

=head2 _help()

Prints the manual and exits

=head2 _error_help()

Prints the manual to STDERR and exits with 2.

=head1 COPYRIGHT & LICENSE

Copyright 2009, 2011 Josh ben Jore, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=head1 SOURCE AVAILABILITY

This source is in Github: L<git://github.com/jbenjore/app-perldoc-search.git>

=head1 AUTHOR

Josh Jore

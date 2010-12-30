#!/usr/bin/env perl
use strict;
use warnings;
use 5.010000;
use FindBin;
use lib "$FindBin::Bin/../lib";
use lib "$FindBin::Bin/../ext/Games-Lacuna-Client/lib";
use lib "$FindBin::Bin/../ext/IO-Prompter/lib";
use Games::Lacuna::MUD;
use Getopt::Long;
use Pod::Usage;

my $cfg_file = "$ENV{HOME}/.le-mudrc";
my $man      = 0;
my $help     = 0;

GetOptions(
    'cfg=s'  => \$cfg_file,
    'help|?' => \$help,
    'man'    => \$man,
) or pod2usage(2);
pod2usage(1) if $help;
pod2usage( -verbose => 2 ) if $man;
pod2usage("Did not provide a config file")
  unless ( $cfg_file and -e $cfg_file );

Games::Lacuna::MUD->new( cfg_file => $cfg_file )->run;

__END__

=head1 NAME

le-mud - a MUD like client for Lacuna Expanse

=head1 SYNOPSIS

le-mud [options] 

Options:
  -cfg [file]      the config file
  -help            brief help message
  -man             full documentation

=head1 OPTIONS

=over 8

=item B<-cfg>

Config for Games::Lacuna::Client

=item B<-help>

Print a brief help message and exits.

=item B<-man>

Prints the manual page and exits.

=back

=head1 DESCRIPTION

This is a MUD-like client for Lacuna Expanse.

=cut

package Games::Lacuna::MUD;
use 5.12.2;

# ABSTRACT: A Text Based Client for Lacuna Expanse

use Moose 1.0;
use Module::Refresh 0.13;
use IO::Prompter 0.001001;

use Games::Lacuna::Client;
use Games::Lacuna::Client::PrettyPrint;
use Games::Lacuna::MUD::Container;

use Games::Lacuna::MUD::Building;
use Try::Tiny;

BEGIN { $Games::Lacuna::Client::PrettyPrint::ansi_color = 1; }

sub new_mud_client {
    shift;
    Games::Lacuna::MUD::Container->new(@_)->mud_client;
}

has config => (
    isa      => 'Games::Lacuna::MUD::Container',
    is       => 'ro',
    required => 1,
    handles  => {
        get_planet => 'get_planet',
        client     => 'web_client',
    }
);

has refresher => (
    default => sub      { Module::Refresh->new },
    handles => { reload => 'refresh' },
);

after reload => sub { say 'Modules Refreshed' };

has empire => (
    isa      => 'Games::Lacuna::MUD::Empire',
    is       => 'ro',
    required => 1,
);

has current_planet => (
    isa      => 'Games::Lacuna::MUD::Planet',
    is       => 'ro',
    writer   => '_current_planet',
    required => 1,
    handles  => {
        show_planet_status => 'show_status',
        show_planet_map    => 'show_map',
        planet_try_command => 'try_command',
    },
);

sub switch_planet {
    my ($self) = @_;
    my $menue = { reverse %{ $self->empire->planets } };
    my $pid = prompt( 'Planet: ', '-number', -menu => $menue, '-v' );
    $self->_current_planet( $self->get_planet($pid) );
    $self->show_planet_map;
    $self->show_planet_status;
}

has current_building => (
    isa       => 'Games::Lacuna::MUD::Building',
    is        => 'ro',
    writer    => '_current_building',
    clearer   => '_clear_building',
    predicate => 'has_current_building',
    handles   => { building_try_command => 'try_command', }
);

sub _get_building_display_name {
    return "$_[0]->{name} ($_[0]->{level})";
}

sub switch_building {
    my $self    = shift;
    my $planet  = $self->current_planet;
    my $pid     = $planet->id;
    my $details = $planet->buildings;
    my $menue   = {
        map { _get_building_display_name( $details->{$_} ) => $_ }
          keys %$details
    };
    my $bid  = prompt( 'Building: ', '-number', -menu => $menue, '-v' );
    my $url  = $details->{$bid}->{url};
    my $type = Games::Lacuna::Client::Buildings::type_from_url($url);
    my $data = $self->client->building(
        id   => $bid,
        type => $type
    )->view()->{building};

    my $building = try {
        Games::Lacuna::MUD::Building->with_traits($type)->new(
            id       => $bid,
            raw_data => $data
        );
    }
    catch {
        Games::Lacuna::MUD::Building->new(
            id       => $bid,
            raw_data => $data
        );
    };
    $self->_current_building($building);
    $self->show_building_status;
}

sub leave_building {
    my $self = shift;
    $self->_clear_building;
    $self->show_planet_map;
    $self->show_planet_status;
}

sub show_building_status {
    my $self = shift;
    $self->has_current_building
      ? $self->current_building->show_status
      : say 'No building selected.';
}

sub try_command {
    my $self = shift;
    given (shift) {
        when (qr/^go building$/)    { $self->switch_building }
        when (qr/^leave building$/) { $self->leave_building }
        when (qr/^go planet?$/)     { $self->switch_planet }
        when (qr/^reload$/)         { $self->reload }
        when (qr/^help$/)           { $self->help }
        when (qr/^xyzzy$/)          { say 'Nothing happens' }
        default                     { return; }
    }
    return 1;
}

sub run {
    my ($self) = @_;
    $self->show_planet_map;
    $self->show_planet_status;
    my $planet = $self->current_planet->name;
    my $id     = $self->current_planet->id;

    while ( prompt( "$planet: ", '-h', -fail => qr/^q(?:uit)?$/ ) ) {
        try {
            given ($_) {
                when ( $self->has_current_building ) {
                    continue unless $self->building_try_command($_);
                }
                when ( $self->planet_try_command($_) ) { }
                when ( $self->try_command($_) )        { }
                default { say "Command $_ not recognized. Try again." }
            }
        }
        catch {
            say "Something went wrong: $_";
        };
        $planet = $self->current_planet->name;
    }
    say 'Goodbye';
}
1;
__END__

package Games::Lacuna::Client::MUD;
use 5.12.2;

use Moose;
use Games::Lacuna::Client;
use Games::Lacuna::Client::PrettyPrint;
use Games::Lacuna::MUD::SpeciesStats;
use Games::Lacuna::MUD::PlanetData;
use Games::Lacuna::MUD::BuildingData;
use Module::Refresh;
use Try::Tiny;
use IO::Prompter;

has cfg_file => (
    isa      => 'Str',
    is       => 'ro',
    required => 1,
);

has refresher => (
    default => sub      { Module::Refresh->new },
    handles => { reload => 'refresh' },
);

after reload => sub { say 'Modules Refreshed' };

has client => (
    isa     => 'Games::Lacuna::Client',
    is      => 'ro',
    lazy    => 1,
    builder => '_build_client'
);

sub _build_client { Games::Lacuna::Client->new( cfg_file => shift->cfg_file ) }

has empire_data => (
    isa     => 'Games::Lacuna::MUD::SpeciesStats',
    is      => 'ro',
    builder => '_build_empire_data',
);

sub _build_empire_data {
    my ($self) = @_;
    my $data = $self->client->empire->view_species_stats();
    Games::Lacuna::MUD::SpeciesStats->new( raw_data => $data );
}

has current_planet => (
    isa     => 'Games::Lacuna::MUD::PlanetData',
    is      => 'ro',
    writer  => '_current_planet',
    lazy    => 1,
    builder => '_build_current_planet',
    handles => {
        show_planet_status     => 'show_status',
        show_planet_map        => 'show_map',
        show_production_report => 'show_production_report',
        planet_try_command     => 'try_command',
    },
);

sub _build_current_planet {
    my ($self) = @_;
    my $pid = $self->empire_data->home_planet_id;
    $self->_pid_to_planet($pid);
}

sub _pid_to_planet {
    my ( $self, $pid ) = @_;
    my $data = $self->client->body( id => $pid )->get_buildings();
    Games::Lacuna::MUD::PlanetData->new( id => $pid, raw_data => $data );
}

sub switch_planet {
    my ($self) = @_;
    my $menue = { reverse %{ $self->empire_data->planets } };
    my $pid = prompt( '-number', -menu => $menue, '-v' );
    $self->_current_planet( $self->_pid_to_planet($pid) );
    $self->look;
}

has current_building => (
    isa       => 'Games::Lacuna::MUD::BuildingData',
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
    my $bid  = prompt( '-number', -menu => $menue, '-v' );
    my $url  = $details->{$bid}->{url};
    my $type = Games::Lacuna::Client::Buildings::type_from_url($url);
    my $data = $self->client->building(
        id   => $bid,
        type => $type
    )->view()->{building};
    my $building =
      Games::Lacuna::MUD::BuildingData->new( id => $bid, raw_data => $data );
    $self->_current_building($building);
    $self->show_building_status;
}

sub leave_building {
    my $self = shift;
    $self->_clear_building;
    $self->look;
}

sub show_building_status {
    my $self = shift;
    $self->has_current_building
      ? $self->current_building->show_status
      : say 'No building selected.';
}

sub help { say 'Commands: map, status, go, look, reload, quit' }

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
    $self->look;
    while ( my $method = prompt( 'command: ', '-h', -fail => qr/^q(?:uit)?$/ ) )
    {
        try {
            given ($method) {
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
        }
    }
    say 'Goodbye';
}
1;
__END__

package Games::Lacuna::Client::MUD;
use 5.12.2;

use Moose;
use Games::Lacuna::Client;
use Games::Lacuna::Client::PrettyPrint;
use Games::Lacuna::MUD::SpeciesStats;
use Games::Lacuna::MUD::CurrentPlanet;

use IO::Prompt;

has cfg_file => (
    isa      => 'Str',
    is       => 'ro',
    required => 1,
);

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
    isa     => 'Games::Lacuna::MUD::CurrentPlanet',
    is      => 'ro',
    writer  => '_current_planet',
    lazy    => 1,
    builder => '_build_current_planet'
);

sub _build_current_planet {
    my ($self) = @_;
    my $pid = $self->empire_data->home_planet_id;
    $self->_pid_to_planet($pid);
}

sub _pid_to_planet {
    my ( $self, $pid ) = @_;
    my $data = $self->client->body( id => $pid )->get_buildings();
    Games::Lacuna::MUD::CurrentPlanet->new( raw_data => $data );
}

sub switch_planet {
    my ($self) = @_;
    my $menue = { reverse %{ $self->empire_data->planets } };
    my $pid = prompt( -menu => $menue ) + 0;
    $self->_current_planet( $self->_pid_to_planet($pid) );
    $self->look;
}

sub look {
    my $self   = shift;
    my $planet = $self->current_planet;
    Games::Lacuna::Client::PrettyPrint::show_status( $planet->status );
}

sub run {
    my ($self) = @_;
    $self->look;
    while ( my $method = prompt('command: ') ) {
        given ($method) {
            when (qr/(?:g|go)/)   { $self->switch_planet }
            when (qr/(?:l|look)/) { $self->look }
            when (qr/(?:q|quit)/) { say 'Goodbye'; return; }
            when (qr/(?:h|help)/) { say 'HELP TEXT' }
            default               { say 'Command not recognized.' }
        }
    }
}
1;
__END__

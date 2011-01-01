package Games::Lacuna::MUD::Empire;
use 5.12.2;
use Moose;

use Games::Lacuna::Client::Governor;

has config => (
    isa      => 'Games::Lacuna::MUD::Container',
    is       => 'ro',
    required => 1,
    handles  => { client => 'web_client', }
);

has raw_data => (
    isa      => 'HashRef',
    required => 1,
    traits   => ['Hash'],
    handles  => {
        _build_species => [ 'get', 'species' ],
        _build_status  => [ 'get', 'status' ],
    },
);

has species => (
    isa     => 'HashRef',
    lazy    => 1,
    builder => '_build_species',
    traits  => ['Hash'],
    handles => { get_species_property => ['get'], },
);

has status => (
    isa     => 'HashRef',
    lazy    => 1,
    builder => '_build_status',
    traits  => ['Hash'],
    handles => { _build_empire => [ 'get', 'empire' ], },
);

has empire => (
    isa     => 'HashRef',
    is      => 'ro',
    lazy    => 1,
    builder => '_build_empire',
    traits  => ['Hash'],
    handles => {
        _build_planets => [ get => 'planets' ],
        home_planet_id => [ get => 'home_planet_id' ],
    }
);

has planets => (
    is      => 'HashRef',
    is      => 'ro',
    lazy    => 1,
    builder => '_build_planets',
    traits  => ['Hash'],
    handles => { planet_names => 'values', }
);

sub ship_report {
    my $self = shift;

    my $governor =
      Games::Lacuna::Client::Governor->new( $self->client,
        { colony => { _default_ => { priorities => ['ship_report'] } } } );
    $governor->run();
}

sub try_command {
    my $self = shift;
    given (shift) {
        when (qr/^ship report$/) { $self->ship_report }
        default                  { return; }
    }
    return 1;
}

1;
__END__

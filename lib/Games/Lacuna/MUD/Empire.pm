package Games::Lacuna::MUD::Empire;
use Moose;

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

1;
__END__

package Games::Lacuna::MUD::CurrentPlanet;
use Moose;

has raw_data => (
    isa      => 'HashRef',
    required => 1,
    traits   => ['Hash'],
    handles  => {
        _build_status    => [ 'get', 'status' ],
        _build_body      => [ 'get', 'body' ],
        _build_buildings => [ 'get', 'buildings' ],
    },
);

has status => (
    isa     => 'HashRef',
    lazy    => 1,
    builder => '_build_status',
    traits  => ['Hash'],
    handles => { status => [ 'get', 'body' ], },
);

has body => (
    isa     => 'HashRef',
    lazy    => 1,
    builder => '_build_body',
    traits  => ['Hash'],
    handles => { surface_image => [ 'get', 'surface_image' ] },
);

has buildings => (
    isa     => 'HashRef',
    lazy    => 1,
    is      => 'ro',
    builder => '_build_buildings',
    traits  => ['Hash'],
    handles => {},
);

1;
__END__

package Games::Lacuna::MUD::Planet;
use 5.12.2;
use Moose;
use Games::Lacuna::Client::PrettyPrint;

has id => ( isa => 'Str', is => 'ro', required => 1, );

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
        _raw_status      => [ 'get', 'status' ],
        _build_body      => [ 'get', 'body' ],
        _build_buildings => [ 'get', 'buildings' ],
    },
);

has status => (
    isa     => 'HashRef',
    lazy    => 1,
    is      => 'ro',
    builder => '_build_status',
    traits  => ['Hash'],
    handles => { name => [ 'get' => 'name' ] }
);

sub _build_status { shift->_raw_status->{body} }

has body => (
    isa     => 'HashRef',
    lazy    => 1,
    builder => '_build_body',
    traits  => ['Hash'],
    handles => { surface_image => [ 'get', 'surface_image' ] },
);

around surface_image => sub {
    my ( $next, $self ) = ( shift, shift );
    my $surface_image = $self->$next(@_);
    $surface_image =~ s/^surface-//g;
    return $surface_image;
};

has buildings => (
    isa     => 'HashRef',
    lazy    => 1,
    is      => 'ro',
    builder => '_build_buildings',
    traits  => ['Hash'],
    handles => {},
);

sub show_status {
    my $self = shift;
    Games::Lacuna::Client::PrettyPrint::show_status( $self->status );
}

sub show_map {
    my $self = shift;
    Games::Lacuna::Client::PrettyPrint::surface( $self->surface_image,
        $self->buildings );
}

sub show_production_report {
    say 'Not Implemented Yet';
    return;
    my $self   = shift;
    my $planet = $self->current_planet;
    my $pid    = $planet->id;

    my $details = $planet->buildings;
    for my $bid ( keys %{ $details->{$pid} } ) {
        my $url  = $details->{$pid}->{$bid}->{url};
        my $type = Games::Lacuna::Client::Buildings::type_from_url($url);
        $details->{$pid}->{$bid}->{details} =
          $self->client->building( id => $bid, type => $type )->view()
          ->{building};
    }
}

sub try_command {
    my $self = shift;
    given (shift) {
        when (qr/^planet status$/) { $self->show_status }
        when (qr/^planet map$/)    { $self->show_map }
        when (qr/^look$/)          { $self->show_map; $self->show_status }
        when (qr/^dump$/)          { say $self->dump }
        default                    { return; }
    }
    return 1;
}

1;
__END__

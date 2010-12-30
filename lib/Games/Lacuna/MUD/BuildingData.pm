package Games::Lacuna::MUD::BuildingData;
use 5.12.2;
use Moose;

with 'Games::Lacuna::MUD::Templates';

has id => ( isa => 'Str', is => 'ro', required => 1, );

has raw_data => (
    isa      => 'HashRef',
    is       => 'bare',
    required => 1,
    traits   => ['Hash'],
    handles  => {
        name        => [ 'get', 'name' ],
        level       => [ 'get', 'level' ],
        food_hour   => [ 'get', 'food_hour' ],
        ore_hour    => [ 'get', 'ore_hour' ],
        water_hour  => [ 'get', 'water_hour' ],
        energy_hour => [ 'get', 'energy_hour' ],
    },
);

sub show_status {
    my $self = shift;
    $self->process_template( \<<'END_TEMPLATE', { obj => $self } );
    [% obj.name %] ([% obj.level %])
    Current Production
    Food: [% obj.food_hour %]/h
    Ore:  [% obj.ore_hour %]/h
    Water: [% obj.water_hour %]/h
    Energy: [% obj.energy_hour %]/h
END_TEMPLATE
    say '';
}

1;
__END__

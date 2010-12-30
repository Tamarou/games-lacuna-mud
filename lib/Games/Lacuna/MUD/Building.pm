package Games::Lacuna::MUD::Building;
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
        name                => [ 'get', 'name' ],
        level               => [ 'get', 'level' ],
        food_hour           => [ 'get', 'food_hour' ],
        ore_hour            => [ 'get', 'ore_hour' ],
        water_hour          => [ 'get', 'water_hour' ],
        energy_hour         => [ 'get', 'energy_hour' ],
        waste_hour          => [ 'get', 'waste_hour' ],
        work                => [ 'get', 'work' ],
        _build_upgrade_data => [ 'get', 'upgrade' ],
    },
);

has upgrade_data => (
    isa        => 'HashRef',
    is         => 'bare',
    lazy_build => 1,
    traits     => ['Hash'],
    handles    => {
        can_upgrade        => [ 'get', 'can' ],
        no_upgrade_reason  => [ 'get', 'reason' ],
        upgrade_production => [ 'get', 'production' ],
    },
);

sub show_status {
    my $self = shift;
    $self->process_template( \<<'END_TEMPLATE', { obj => $self } );
    [% obj.name %] ([% obj.level %])
    Current Production
    Food:   [% obj.food_hour +%]/h
    Ore:    [% obj.ore_hour +%]/h
    Water:  [% obj.water_hour +%]/h
    Energy: [% obj.energy_hour +%]/h
    Waste:  [% obj.waste_hour +%]/h

    [% IF obj.can_upgrade %]
    Upgrade Cost
    [TBA]
    
    Upgrade Capacity
    [TBA]
    [% ELSE %]
    [% obj.no_upgrade_reason.1 %]
    [% END %]
    
    [% IF obj.work %]
    Working: [% obj.work.seconds_remaining %]s remaining
    [% END %]
    
END_TEMPLATE
    say '';
}

sub try_command {
    my $self = shift;
    given (shift) {
        when (qr/^building status$/) { $self->show_status }
        when (qr/^look$/)            { $self->show_status }
        when (qr/^dump$/)            { say $self->dump }
        default                      { return; }
    }
    return 1;
}

1;
__END__

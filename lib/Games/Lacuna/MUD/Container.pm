package Games::Lacuna::MUD::Container;
use Moose;
use Bread::Board;
extends qw(Bread::Board::Container);

use Games::Lacuna::MUD::Empire;
use Games::Lacuna::MUD::Planet;

has '+name' => ( default => 'Games::Lacuna::MUD::Client' );

has cfg_file => (
    isa      => 'Str',
    is       => 'ro',
    required => 1,
);

sub BUILD {
    my $self = shift;

    container $self => as {
        service cfg_file => $self->cfg_file;

        service config => (
            lifecycle => 'Singleton',
            class     => __PACKAGE__,
            block     => sub { $self },
        );

        service lacuna_client => (
            lifecycle    => 'Singleton',
            class        => 'Games::Lacuna::Client',
            dependencies => { cfg_file => depends_on('cfg_file') },
        );

        service mud_client => (
            lifecycle    => 'Singleton',
            class        => 'Games::Lacuna::MUD',
            dependencies => {
                config         => depends_on('config'),
                empire         => depends_on('empire'),
                current_planet => depends_on('home_planet'),
            },
        );

        service home_planet => (
            class => 'Games::Lacuna::MUD::Planet',
            block => sub {
                my $s   = shift;
                my $c   = $s->parent;
                my $pid = $c->resolve( service => 'empire' )->home_planet_id;
                $c->resolve(
                    service    => 'planet',
                    parameters => { id => $pid },
                );
            },
        );

        service planet => (
            class => 'Games::Lacuna::MUD::Planet',
            block => sub {
                my $s      = shift;
                my $c      = $s->parent;
                my $client = $c->resolve( service => 'lacuna_client' );
                my $data =
                  $client->body( id => $s->param('id') )->get_buildings();
                Games::Lacuna::MUD::Planet->new(
                    id       => $s->param('id'),
                    raw_data => $data,
                    config   => $c->resolve( service => 'config' ),
                );
            },
            parameters => { id => { isa => 'Str' }, }
        );

        service empire => (
            lifecycle => 'Singleton',
            class     => 'Games::Lacuna::MUD::Empire',
            block     => sub {
                my $s      = shift;
                my $c      = $s->parent;
                my $client = $c->resolve( service => 'lacuna_client' );
                my $data   = $client->empire->view_species_stats();
                Games::Lacuna::MUD::Empire->new(
                    config   => $c->resolve( service => 'config' ),
                    raw_data => $data,
                );
            },

        );
    }
}

sub web_client { shift->resolve( service => 'lacuna_client' ) }
sub mud_client { shift->resolve( service => 'mud_client' ) }

sub get_planet {
    shift->resolve( service => 'planet', parameters => { id => shift } );
}
1;
__END__

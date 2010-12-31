package Games::Lacuna::MUD::Config;
use Moose;
use Bread::Board;
extends qw(Bread::Board::Container);

has '+name' => ( default => 'Games::Lacuna::MUD::Client' );

has cfg_file => (
    isa      => 'Str',
    is       => 'ro',
    required => 1,
);

sub BUILD {
    my $self = shift;

    container $self => as {
        service cfg_file      => $self->cfg_file;
        service lacuna_client => (
            lifecycle    => 'Singleton',
            class        => 'Games::Lacuna::Client',
            dependencies => { cfg_file => depends_on('cfg_file') },
        );

        service mud_client => (
            lifecycle    => 'Singleton',
            class        => 'Games::Lacuna::MUD',
            dependencies => {
                client => depends_on('lacuna_client'),
                empire => depends_on('empire_data'),
            },
        );

        service empire_data => (
            lifecycle => 'Singleton',
            class     => 'Games::Lacuna::MUD::Empire',
            block     => sub {
                my $s = shift;
                my $c = $s->parent;
                my $data =
                  $c->resolve(service => 'lacuna_client')->empire->view_species_stats();
                Games::Lacuna::MUD::Empire->new( raw_data => $data );
            },

        );
    }
}

1;
__END__

package Games::Lacuna::MUD::Building::Shipyard;
use 5.12.2;
use Moose::Role;

requires 'try_command';

sub show_build_queue { say 'Not yet implemented.' }

around 'try_command' => sub {
    my ( $next, $self, $cmd ) = @_;
    given ($cmd) {
        when (qr/xyzzy/) { $self->show_build_queue }
        default          { return $self->$next($cmd) }
    }
    return 1;
};

1;
__END__

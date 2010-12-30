package Games::Lacuna::MUD::Templates;
use Moose::Role;
use Template::Tiny;

has template_engine => (
    isa     => 'Template::Tiny',
    default => sub { Template::Tiny->new( TRIM => 1 ) },
    handles => { process_template => 'process' }
);

1;
__END__

# Games::Lacuna::MUD

This is a functional proof of concept of a Text Based client for 
[Lacuna Expanse](http://lacunaexpanse.com/). It depends heavily on
[Games::Lacuna::Client](http://github.com/tsee/Games-Lacuna-Client).

As of this writing the client is read-only because I haven't implemented any
of the commands that send changes back to the server. Things will get fleshed
out as I have time, or as patches roll in.

## Screen Shot

<a href="https://skitch.com/perigrin/r8ft8/173x36"><img src="https://img.skitch.com/20101230-q9qftqfyy9hnegdp6g59tse9cr.jpg" alt="Screen Shot" /></a>


## Getting Started

This is still in developer release mode, we may never get beyond that. If you'd like to get started with Games::Lacuna::MUD simply do the following.

On a box with Perl 5.12.2 installed download a copy of this Games::Lacuna::MUD
either by cloning it or downloading a
[tarball](https://github.com/stevan/Jackalope/tarball/master).

If you've never installed a CPAN distribution before, you'll need a configured
CPAN client. I happen to like CPAN minus because it has good defaults, and can
self-install from the web.

    > curl -L http://cpanmin.us | perl - --self-upgrade 

Make sure you have Dist::Zilla installed, this will make installing the dependencies easier.

    > cpanm Dist::Zill

Once Dist::Zilla is installed simply do the following to install the dependencies required for Games::Lacuna::MUD

    > dzil listdeps | cpanm

Once the dependencies are installed you will need to have a developer API
Key that you can acquire from 
[this site](https://us1.lacunaexpanse.com/apikey).

With the developer key you can create a configuration file for Games::Lacuna::Client. 

    ---
    api_key: [KEY]
    empire_name: [EMPIRE]
    empire_password: "[PASSWORD]"
    server_uri: https://us1.lacunaexpanse.com/

Save this as `$HOME/.le-mudrc` and you can start the MUD client with the following

    > perl bin/le-mud.pl

Have fun!

## Commands

Some basic MUD commands work: look, go planet, go building, leave building, quit

Beyond this the commands are still rudimentary. There is no help system
because I wasn't happy with the on that I had and haven't come up with a slick
way of integrating a cross cutting concern like that. You are free of course
to view the source.


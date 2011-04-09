use strictures 1;
use FindBin;
use lib "$FindBin::Bin/../lib";
use IRCTurtle;
use Getopt::Long::Descriptive;
my ( $opt, $usage ) = describe_options(
    '%c %o <some-arg>',
    [ 'host|h=s', "the host to connect to" ],
    [ 'nick|n=s', "nick,alias" ],
    [ 'channel|c=s', "channel to join" ],
    [ 'help',      "print usage message and exit" ],
);

print( $usage->text ), exit if $opt->help;

my $turtle = IRCTurtle->new(
    host    => $opt->host,
    nick    => $opt->nick,
    channel => $opt->channel,
);
$turtle->launch;

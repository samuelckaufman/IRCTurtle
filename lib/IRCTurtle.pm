package IRCTurtle;
use Moose;
use IO::Async::Loop;
use Net::Async::IRC;
with 'Role::UnixSocket';
use constant {
    JOIN => 'JOIN',
    PRIVMSG => 'PRIVMSG'
};
has loop => (
    is => 'ro',
    lazy => 1,
    default => sub { IO::Async::Loop->new }
);
has irc => (
    is => 'ro',
    builder => '_build_irc',
    lazy => 1
);
has nick => (
    is => 'ro',
    required => 1,
);
has host => (
    is => 'ro',
    required => 1,
);

has channel => (
    is => 'ro',
    required => 1,
);
sub socket_callback {
    my($self,$str) = @_;
    chomp($str);
    $self->irc->send_message( PRIVMSG, undef, $self->channel, $str );
}
sub _build_irc {
    my $self = shift;
    my $nick = $self->nick;
    my $irc = Net::Async::IRC->new(
        on_message_text => sub {
            my ( $irc, $message, $hints ) = @_;
            print "$hints->{prefix_name} says: $hints->{text}\n";
            return unless $hints->{text} =~ /^$nick:/;
            my ($text) = $hints->{text} =~ /^$nick:(.*?)$/;
            $irc->send_message( PRIVMSG, undef, $self->channel, $text );
        }
    );
    $self->loop->add($irc);
    $irc;
}
sub launch {
    my $self = shift;
    $self->irc->login(
        nick => $self->nick,
        host => $self->host,
        on_login => sub {
            $self->irc->send_message( JOIN, undef, $self->channel );
        },
    );
    $self->loop->loop_forever;
}
1;

__END__
# ABSTRACT: Git commit watcher

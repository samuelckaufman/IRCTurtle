package Role::UnixSocket;
use Moose::Role;
use IO::Async::Listener;
use IO::Async::Loop;

has socket_location => (
    is => 'ro', 
    required => 1,
);

has loop => (
    is => 'ro',
    default => sub {
        IO::Async::Loop->new
    }
);

has listener => (
    is => 'ro',
    builder => '_build_listener'
);

requires 'socket_callback';

sub _build_loop {
    my $self = shift;
}

sub _build_listener {
  my $self = shift;
  unlink($self->socket_location);
  my $loop = $self->loop;
  my $listener = IO::Async::Listener->new(
    on_stream => sub {
        my( undef, $stream ) = @_;
        $stream->configure(
            on_read => sub {
                my(undef, $buffref, $eof) = @_;
                $self->socket_callback($$buffref) if $$buffref;
                $$buffref = "";
                return 0;
            }
        );
        $loop->add($stream);
    }
  );
  $loop->add($listener);
  $listener->listen(addr => {
    family => "unix",
    socktype => "stream",
    path => $self->socket_location,
  },
  on_listen_error => sub {
    die @_;
  }
  
  );
  $listener;
}
no Moose::Role;
1;
__END__
#ABSTRACT: Provide an easy to use role for communicating via sockets.

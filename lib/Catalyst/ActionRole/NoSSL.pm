package  Catalyst::ActionRole::NoSSL;

use Moose::Role;
use namespace::autoclean;

our $VERSION = '0.01';

=head1 NAME

Catalyst::ActionRole::NoSSL - Force an action to be plain.

=head1 SYNOPSIS

  package MyApp::Controller::Foo;

  use parent qw/Catalyst::Controller::ActionRole/;

  sub bar : Local Does('RequireSSL') { ... }
  sub bar : Local Does('NoSSL') { ... }
   
=cut

around execute => sub {
  my $orig = shift;
  my $self = shift;
  my ($controller, $c) = @_;
  if($c->req->secure) {
    my $uri = $c->req->uri;
    $uri->scheme('http');
    $c->res->redirect( $uri );
  } else {
    $self->$orig( @_ );
  }
};

1;

=head1 AUTHOR

Simon Elliott E<cpan@papercreatures.com>

=head1 CONTRIBUTORS

Andy Grundman, <andy@hybridized.org> for the original RequireSSL Plugin

=head1 BUGS

=head1 COPYRIGHT & LICENSE

Copyright 2009 by Simon Elliott

This program is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

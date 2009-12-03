package Catalyst::ActionRole::RequireSSL;

use Moose::Role;
use namespace::autoclean;

our $VERSION = '0.01';

=head1 NAME

Catalyst::ActionRole::RequireSSL - Force an action to be secure only.

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
  my $internal = $c->engine->isa("Catalyst::Engine::HTTP");
  if ($c->req->method eq "POST") {
    $c->error("Cannot secure request on POST") 
  }
  unless(
    $internal ||
    $c->req->secure ||
    $c->req->method eq "POST") {
    my $uri = $c->req->uri;
    $uri->scheme('https');
    $c->res->redirect( $uri );
  } else {
    $c->log->warn("Would've redirected to secure") if $internal;
    $self->$orig( @_ );
  }
};

1;

=head1 AUTHOR

Simon Elliott E<cpan@papercreatures.com>

=head1 THANKS

Andy Grundman, <andy@hybridized.org> for the original RequireSSL Plugin
t0m (Tomas Doran), zamolxes (Bogdan Lucaciu)

=head1 BUGS

=head1 COPYRIGHT & LICENSE

Copyright 2009 by Simon Elliott

This program is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

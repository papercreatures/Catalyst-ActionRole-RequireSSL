package Catalyst::ActionRole::RequireSSL;

use Moose::Role;
with 'Catalyst::ActionRole::RequireSSL::Roles';
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
  
  unless(defined $c->config->{require_ssl}->{disabled}) {
    $c->config->{require_ssl}->{disabled} = 
      $c->engine->isa("Catalyst::Engine::HTTP") ? 1 : 0;
  }
  #use Data::Dumper;warn Dumper($c->action);
  if ($c->req->method eq "POST" && !$c->config->{require_ssl}->{ignore_on_post}) {
    $c->error("Cannot secure request on POST") 
  }

  unless(
    $c->config->{require_ssl}->{disabled} ||
    $c->req->secure ||
    $c->req->method eq "POST" ||
    !$self->check_chain($c)
    ) {
    my $uri = $c->req->uri;
    $uri->scheme('https');
    $c->res->redirect( $uri );
  } else {
    $c->log->warn("Would've redirected to SSL") 
      if $c->config->{require_ssl}->{disabled};
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

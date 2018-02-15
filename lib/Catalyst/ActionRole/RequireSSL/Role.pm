package Catalyst::ActionRole::RequireSSL::Role;

use Moose::Role;
use namespace::autoclean;
our $VERSION = '0.07';

=head1 NAME

Catalyst::ActionRole::RequireSSL::Role - Roles.

=head1 SYNOPSIS

=cut

my @ignore_chain = qw/Catalyst::ActionRole::NoSSL Catalyst::ActionRole::RequireSSL/;

=head1 METHODS

=head2 check_chain($c)

check we are most relevant action

=cut

sub check_chain {
  my ($self,$c) = @_;
  return $c->config->{require_ssl}->{path_cache}->{$c->action->private_path}
    eq $self->private_path
      if $c->config->{require_ssl}->{path_cache}->{$c->action->private_path};
  if($c->action->can('chain')) {
    foreach my $action (reverse @{$c->action->chain}) {
      foreach my $role (@{$action->attributes->{Does}}) {
        if(grep {$role eq $_} @ignore_chain ) {
          $c->config->{require_ssl}->{path_cache}->{$action->private_path}
            = $action->private_path;
          return $action->private_path eq $self->private_path;
        }
      }
    }
  }
  return 1;
}

1;

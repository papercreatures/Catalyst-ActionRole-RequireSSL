package Catalyst::ActionRole::RequireSSL::Roles;

use Moose::Role;
use namespace::autoclean;
use List::MoreUtils qw/any/;

our $VERSION = '0.01';

has ignore_chain => (
  isa => 'ArrayRef',
  is  => 'rw',  
  default =>  sub { [qw/Catalyst::ActionRole::NoSSL Catalyst::ActionRole::RequireSSL/] }, 
);

#check we are most relevant action
sub check_chain {
  my ($self,$c) = @_;
  return $c->stash->{require_ssl}->{skip_to} eq $self->private_path
    if defined $c->stash->{require_ssl}->{skip_to};
  foreach my $action (reverse @{$c->action->chain}) {
    foreach my $role (@{$action->attributes->{Does}}) {
      if(grep {$role eq $_} @{$self->ignore_chain} ) {
        $c->stash->{require_ssl}->{skip_to} = $action->private_path;
        return $action->private_path eq $self->private_path;
      }
    }
  }  
  return 1;
}

1;
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

sub check_chain {
  my ($self,$c) = @_;
  return $c->stash->{require_ssl}->{skip_to} ne $c->action->private_path
    if defined $c->stash->{require_ssl}->{skip_to};
  foreach my $action (reverse @{$c->action->chain}) {
#    use Data::Dumper;warn Dumper($action->attributes);
    foreach my $role (@{$action->attributes->{Does}}) {
      if(grep {$role eq $_} @{$self->ignore_chain} ) {
        $c->stash->{require_ssl}->{skip_to} = $action->private_path;
        return 1;
      }
    }
  }  
  return 0;
}

1;
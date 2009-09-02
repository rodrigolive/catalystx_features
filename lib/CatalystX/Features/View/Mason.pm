package CatalystX::Features::View::Mason;

use strict;
use warnings;
use base 'Catalyst::View::Mason';

sub new {
    my ($self, $app, $arguments) = @_;
    $arguments->{comp_root} = [ [ 'root'   => $app->config->{root} ] ];
    foreach my $feature ( $app->features ) {
        push( @{ $arguments->{comp_root} }, [ $feature->id => $feature->root ] );
    }
    $self->next::method($app, $arguments);
}

1;

package CatalystX::Features::View::TT;

use strict;
use warnings;
use base 'Catalyst::View::TT';

sub new {
    my ($self, $app, $arguments) = @_;
    $arguments->{INCLUDE_PATH} = ref $self->config->{INCLUDE_PATH} eq 'ARRAY'
                            ? $self->config->{INCLUDE_PATH}
                            : [];
    foreach my $feature ( $app->features ) {
        push( @{ $arguments->{INCLUDE_PATH} }, $feature->root );
    }
    $self->next::method($app, $arguments);
}

1;


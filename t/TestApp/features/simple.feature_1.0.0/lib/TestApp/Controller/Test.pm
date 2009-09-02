package TestApp::Controller::Test;

use strict;
use warnings;
use parent 'Catalyst::Controller';

#
# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in MyApp.pm
#
__PACKAGE__->config->{namespace} = 'test';

=head1 NAME

Test::Controller::Root - Root Controller for Test

=head1 DESCRIPTION

[enter your description here]

=head1 METHODS

=cut

=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    # Hello World
	use Data::Dumper;
    $c->response->body( 'in Test feature with config: ' . Dumper $c->config->{feature_stuff} );
}

sub hello :Local {
    my ( $self, $c ) = @_;

    # Hello World
    $c->response->body( 'in Test feature' );

}

sub mason:Local {
    my ( $self, $c ) = @_;
	$c->stash->{template} = 'src/test.mas';
	$c->forward('View::Mason');	
}

sub tt:Local {
    my ( $self, $c ) = @_;
	$c->stash->{template} = 'src/test.tt';
	$c->forward('View::TT');	
}

sub default :Path {
    my ( $self, $c ) = @_;
    $c->response->body( 'Page not found' );
    $c->response->status(404);
}

=head2 end

Attempt to render a view, if needed.

=cut

sub end : ActionClass('RenderView') {}

=head1 AUTHOR

Rodrigo de Oliveira

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;

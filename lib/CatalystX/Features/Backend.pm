package CatalystX::Features::Backend;
use Moose;
use Path::Class;

has 'include_path' => ( is => 'rw', isa => 'ArrayRef' );
has 'features'     => ( is => 'rw', isa => 'HashRef', default => sub { {} } );
has 'app'          => ( is => 'ro', isa => 'Any', required=>1 );

*list = \&_array;

with 'CatalystX::Features::Role::Backend';

sub init {
    my $self = shift;
    for my $home ( @{ $self->include_path || [] } ) {
        my @features = _find_features($home);
        foreach my $feature_path (@features) {

            my $feature_class = $self->app->config->{feature_class}
              || 'CatalystX::Features::Feature';

            # init feature
			eval "require $feature_class";
            my $feature = $feature_class->new(
                {
                    path    => "$feature_path",
                    backend => $self,
                }
            );

            $self->_push_feature($feature);
        }
    }
}

sub _find_features {
    my $home = shift;
    my @features =
      grep { -d $_ } map { Path::Class::dir($_) } glob $home . '/*';
    return @features;
}

sub _push_feature {
    my ( $self, $new_feature ) = @_;

    foreach my $feature_name ( keys %{ $self->features } ) {
        my $feature = $self->features->{$feature_name};
        if ( $feature->name eq $new_feature->name ) {
            if ( $feature->version_number > $new_feature->version_number ) {
                return;
            }
        }
    }
    $self->features->{ $new_feature->name } = $new_feature;
}

sub config {
    my $self = shift;
    return $self->app->config->{$CatalystX::Features::config_key};
}

sub _array {
    my $self = shift;
    return map { $self->features->{$_} } keys %{ $self->features };
}

sub get {
    my $self = shift;
    return $self->features->{shift};
}

sub me {    #TODO
    my $self = shift;

    # get the callers' package

    # then find the file path for the package

    # then find the feature object from this path
}

1;

__END__

=pod 

=head1 NAME

CatalystX::Features::Backend - All the dirty work is done here

=head1 SYNOPSIS

	my $backend = $c->features;

	$backend->config; # my config 

	$backend->list; # a list of features

=head1 METHODS

=head2 $c->features->config()

Returns the config hash part related to L<CatalystX::Features>.

=head2 $c->features->init()

Initializes the backend, searching for features and creating
L<CatalystX::Features::Feature> instances for them.

=head2 $c->features->list()

Returns an array with instances of all loaded features. If they have not
changed via config, they'll be instances of the L<CatalystX::Features::Feature>
 class.

=head2 $c->features->get( $feature_name ) 

Get the object instance of a given feature name.

=head2 $c->features->me()

Not implemented yet. Coming soon.

=head1 TODO 

=over

=item A $c->features->me method which can be called from within a feature to get it's own instance.

=back

=head1 AUTHORS

    Rodrigo de Oliveira (rodrigolive), C<rodrigolive@gmail.com>

=head1 LICENSE

This library is free software. You can redistribute it and/or modify it under
the same terms as Perl itself.

=cut


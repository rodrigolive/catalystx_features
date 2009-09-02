package CatalystX::Features::Backend;
use Moose;
use Path::Class;
use CatalystX::Features::Feature;

our $VERSION = '0.10';

has 'include_path' => ( is=>'rw', isa=>'ArrayRef' );
has 'features' => ( is=>'rw', isa=>'HashRef', default=>sub{{}} );

sub init {
    my $self = shift;
    for my $home ( @{ $self->include_path || [] } ) {
        my @features = _find_features($home); 
        foreach my $feature_path ( @features ) {
            my $feature = new CatalystX::Features::Feature({
                path=>"$feature_path",
            });
            $self->push_feature( $feature );
        }
    }
}

sub _find_features {
    my $home = shift; 
    my @features = grep { -d $_ } map { Path::Class::dir($_) } glob $home.'/*';
    return @features;
}

sub push_feature {
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

sub array {
    my $self = shift;
    return map { $self->features->{$_} } keys %{ $self->features };
}

1;


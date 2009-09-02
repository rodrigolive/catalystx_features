package CatalystX::Features::Feature;
use Moose;
use Path::Class;
use Catalyst::Utils;

has 'id' => ( is=>'rw', isa=>'Str' );
has 'name' => ( is=>'rw', isa=>'Str' );
has 'version' => ( is=>'rw', isa=>'Str', default=>'1.0.0' );
has 'path' => ( is=>'rw', isa=>'Str', trigger=> \&build_args );

has 'root' => ( is=>'rw', isa=>'Str' );
has 'lib' => ( is=>'rw', isa=>'Str' );
has 't' => ( is=>'rw', isa=>'Str' );

with 'CatalystX::Features::Role::Feature';  # the interface role, after all the 'has'

sub build_args {
    my ($self, $value ) = @_;
    my $path = $self->path; 
    my $full_path = Path::Class::dir( $path ); 
    my $id = $full_path->relative( $full_path->parent )->stringify;
    my ($name,$version) = ( $id =~ /^(.*?)[_|-](.*?)$/ );
    $self->id( $id );
    $self->name( $name || $id );
    $version && $self->version( $version );

    $self->root( Path::Class::dir( $self->path . "/root" )->stringify );
    $self->lib( Path::Class::dir( $self->path . "/lib" )->stringify );
    $self->t( Path::Class::dir( $self->path . "/t" )->stringify );
}

sub version_number {
    my $self = shift;
    my $version = $self->version;
    if( $version =~ /\./ ) {
        my $number;
        foreach my $part ( split /\./, $version ) {
            $number .= sprintf("%03d", $part );
        }
        return $number;
    } else {
        return $version;
    }
}

=head1 NAME

CatalystX::Features::Feature - Class that represents a single feature.

=head1 VERSION

version 0.10

=head1 SYNOPSIS

    foreach my $feature( $c->features ) {
        $c->log->info( $feature->name );  # $feature methods declared here
    }

=head1 DESCRIPTION

This is the object you get when you list features with $c->features.

=head1 METHODS

=head2 $c->id

For a feature directory of "my.feature_1.0", the id part is "my.feature_1.0".

=head2 $c->name

For a feature directory of "my.feature_1.0", the name is "my.feature".

=head2 $c->version

For a feature directory of "my.feature_1.0", the version is "1.0".

=head2 $c->version_number

A version long integer that can be compared easily. For a feature directory of "my.feature_1.2.3", the version number equals 001002003.

=head1 TODO

=head2 Change the base class name thru config

Not everyone want to have this object as a base class for their features. There is a role (interface) already created in case you want to create your own class from scratch.

=head1 AUTHORS

Rodrigo de Oliveira (rodrigolive), C<rodrigolive@gmail.com>

=head1 COPYRIGHT & LICENSE

        Copyright (c) 2009 the aforementioned authors. All rights
        reserved. This program is free software; you can redistribute
        it and/or modify it under the same terms as Perl itself.

=cut 

1;

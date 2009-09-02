package CatalystX::Features;
use warnings;
use strict;
use Carp;
use base qw/Class::Accessor::Fast Class::Data::Inheritable/;
use MRO::Compat;
use Class::Inspector;
use Path::Class;
use CatalystX::Features::Backend;

our $VERSION = '0.10';

sub features_setup {
    my $c = shift;

    my $config = $c->config;

    unless( defined $c->config->{features}->{backend} ) {
        $config->{features}->{home} ||= [ Path::Class::dir($config->{home} . "/features")->stringify ];
        my $backend = new CatalystX::Features::Backend({ include_path=>$config->{features}->{home} });
        $backend->init;
        $c->config->{features}->{backend} = $backend;
		$c->log_features_table;
    }
}

sub setup {
    my $c = shift;
    $c->next::method(@_);

    $c->features_setup;
    
    return $c;
}

sub features {
    my $c = shift;

    $c->features_setup;

    return $c->config->{features}->{backend}->array;
}

sub log_features_table {
    my $c = shift;
    my $table = <<"";
Features Loaded:
.----------------------------------------+------------------------+----------.
| Home                                   | Name                   | Version  |
+----------------------------------------+------------------------+----------+

    foreach my $feature ( $c->features ) {
        $table .= sprintf("| %-38s ", $feature->id );
        $table .= sprintf("| %-22s ", $feature->name );
        $table .= sprintf("| %-8s |\n", $feature->version );

        # change INC
        push @INC, $feature->lib;
    }

    $table .= <<"";
.-----------------------------------------------------------------+----------.

    $c->log->debug( $table )
		if $c->debug;
}

=head1 NAME

CatalystX::Features - Merges different application directories into your app.

=head1 VERSION

version 0.10

=head1 SYNOPSIS

	package MyApp;
	use Catalyst qw/-Debug
                +CatalystX::Features
                +CatalystX::Features::Plugin::ConfigLoader
                +CatalystX::Features::Plugin::Static::Simple/;

=head1 DESCRIPTION

The idea fo this module is to make it easier to spread out outside of the main application directory, in the spirit of Eclipse features and Ruby on Rails plugins. 

It's mainly useful if you're working on a large application with distinct isolated features that are not tightly coupled with the main app and could be pulled off or eventually reused somewhere else. 

It also comes handy in a large project, with many developers working on specific application parts. And, say, you wish to split the functionality in diretories, or just want to keep them out of the application core files. 

=head1 USAGE

=list Create a directory under your app home named /features

=list Each feature home dir should be named something like:

	/features/my.demo.feature_1.0.0

It's a split on underscore "_", the first part is the feature name, the second is the feature version.

If a higher version of a feature is found, that's the one to be used, the rest is ignored
- a feature without a version is ok, it will be the highest version available - good for local dev and pushing to a repository.
- a debug box is printed on startup, so you can check which version is running:

	[debug] Features Loaded:
	.----------------------------------------+------------------------+----------.
	| Home                                   | Name                   | Version  |
	+----------------------------------------+------------------------+----------+
	| simple.feature_1.0.0                   | simple.feature         | 1.0.0    |
	.-----------------------------------------------------------------+----------.


=head1 CONFIGURATION

=head2 home

Let's you set a list of directories where your features are located. It expects full paths.

	<CatalystX::Features>
		home /opt/myapp_features
		home /somewhere/else
	</CatalystX::Features>

Defaults to:

	MyApp/features

=head1 METHODS

=head2 $c->features

Returns an array of loaded features, which are instances of the L<CatalystX::Features::Feature> class.

=head1 TODO

=head2 Check dependencies among features. 
=head2 Deploy PAR/ZIP files automatically. 

=head1 AUTHORS

Rodrigo de Oliveira (rodrigolive), C<rodrigolive@gmail.com>

=head1 COPYRIGHT & LICENSE

        Copyright (c) 2009 the aforementioned authors. All rights
        reserved. This program is free software; you can redistribute
        it and/or modify it under the same terms as Perl itself.

=cut




1;

package CatalystX::Features;
use warnings;
use strict;

use Carp;
use MRO::Compat;
use Class::Inspector;
use Path::Class;
use CatalystX::Features::Backend;

our $config_key = 'CatalystX::Features';

sub features_setup {
    my $c = shift;

    my $config = $c->config->{$config_key};

    unless ( defined $config->{backend} ) {

        $config->{home} ||=
          [ Path::Class::dir( $c->config->{home} . "/features" )->stringify ];

        my $backend_class = $config->{backend}
          || 'CatalystX::Features::Backend';

        my $backend = $backend_class->new(
            {
                include_path => $config->{home},
                app          => $c,
            }
        );
        $backend->init;
        $c->config->{$config_key}->{backend} = $backend;
        $c->_log_features_table;
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

    return $c->config->{$config_key}->{backend};
}

sub _log_features_table {
    my $c     = shift;
    my $table = <<"";
Features Loaded:
.----------------------------------------+------------------------+----------.
| Home                                   | Name                   | Version  |
+----------------------------------------+------------------------+----------+

    foreach my $feature ( $c->features->list ) {
        $table .= sprintf( "| %-38s ",   $feature->id );
        $table .= sprintf( "| %-22s ",   $feature->name );
        $table .= sprintf( "| %-8s |\n", $feature->version );
    }

    $table .= <<"";
.-----------------------------------------------------------------+----------.

    $c->log->debug( $table . "\n" )
      if $c->debug;
}

1;

__END__

=pod

=head1 NAME

CatalystX::Features - Merges external directories into your app

=head1 SYNOPSIS

   package MyApp;

   use Catalyst qw/
         +CatalystX::Features
         +CatalystX::Features::Lib
         +CatalystX::Features::Plugin::ConfigLoader
         +CatalystX::Features::Plugin::Static::Simple
         ...
         /;

=head1 DESCRIPTION

This module tries to make it easier to spread out outside of the main
application directory, in the spirit of Eclipse features and Ruby on Rails
plugins.

It's mainly useful if you're working on a large application with distinct,
isolated features that are not tightly coupled with the main app and could be
pulled off or eventually reused somewhere else.

It also comes handy in a large project, with many developers working on
specific application parts. And, say, you wish to split the functionality in
diretories, or just want to keep them out of the application core files.

=head1 USAGE

=head2 1) Create a directory under your app home named /features

   mkdir /MyApp/features/

=head2 2) Each feature home dir should be named something like:

   /MyApp/features/my.demo.feature_1.0.0

The folder name is split at the underscore C<_>, the left part becomes the
feature name, the right one, the feature version.

It can also split on a dash C<->, allowing the feature to be named like
C<Feature-0.9123>, which can be useful for dropping something from, say, CPAN.

The dots on the feature name are just sassy stuff. They are absolutely optional.

=head2 3) Recreate your application structure under the feature directory. 


   /MyApp/features/my.demo.feature_1.0.0
      /lib
      /root
      /t

Files under /root will only be picked up by supported plugins and views. The
rest will probably be ignored. Check the distribution directory for supported
plugins and views.

Files under /lib will be included in @INC (if L<CatalystX::Features::Lib> is
used). That means your Controllers, Models and Views (and DBIC::Schema) will be
loaded as if they were under the main directory.

=head2 4) Extend your app yourself!

Don't sit there waiting for a plugin for your favorite View to come out. Just write
your own. Use the force and check the source of some of the plugins in this
distribution, ie. L<CatalystX::Features::View::Mason>.

Really, writing a "feature" enabled application is really simple. Usually you
inherit from a well-known View or Plugin, then trap the initialization code
(C<setup()> or C<new()>) and push the array of loaded features into some sort
of path list.

   foreach my $feature ( $c->features->list ) {

      my $path_to_root = $feature->root;

      # make that path reach the config object for the View

      push @{  $c->config->{View::Bzerk}->{include_path} }, $path_to_root;

   }

=head2 5) Change MyApp.pm to inherit the ::Plugins and ::Views you need, then fire it up.

A debug box will be printed on startup, so you can check which version of each feature
has been loaded:

   [debug] Features Loaded:
   .----------------------------------------+------------------------+----------.
   | Home                                   | Name                   | Version  |
   +----------------------------------------+------------------------+----------+
   | simple.feature_1.0.0                   | simple.feature         | 1.0.0    |
   .-----------------------------------------------------------------+----------.

=head1 RULES AND CAVEATS

=head2 Feature versions

=over

=item * If a higher version of a feature is found, that's the one to be used, the rest
is ignored 

=item * A feature without a version is ok, it will be the highest version
available. That's good for commiting to source control, where you don't want version numbers on directories.

=back

=head2 Merging

=over 

=item * Merging rules are left in the open right now.
If duplicate files are found between two features, or a
feature and the main app, maybe the one in the feature will have precedence. Maybe not. 

=item * But the idea is to give precedence to the feature,
which is "rewriting" the main app.  

=item * On the other hand, there are cases where the main app
wants to force down the rules to the features. I prefer 
a "stronger" feature. After all, features are app novelties, thus the precedence.

=item * Check each plugin for details on how its merge is done.
For instance, L<CatalystX::Features::Plugin::ConfigLoader> will merge
directly into the main app's config file, overwriting whatever comes across its path.

=back

=head2 "Cascading" 

If your feature is called myfeature, and inside there's a Controller called C<Test>, the 
registered url *will not* be:

   /myfeature/test/*

But:

	/test/*

Just like if it were stowed under the main app /lib dir.

=head1 CONFIGURATION

=head2 home

Let's you set a list of directories where your features are located. It expects
 full paths.

   <CatalystX::Features>
      home /opt/myapp_features
      home /somewhere/else
   </CatalystX::Features>

Defaults to:

   MyApp/features

=head2 backend_class

Sets an alternative class to use as a backend. The default is
L<CatalystX::Features::Backend>.

   <CatalystX::Features>
      backend_class MyApp::Features
   </CatalystX::Features>

=head2 feature_class

Sets an alternative class to represent a single feature. The default is
L<CatalystX::Features::Feature>. This class should implement the role
L<CatalystX::Features::Role::Feature>.

   <CatalystX::Features>
      feature_class MyApp::Feature
   </CatalystX::Features>

=head1 EXAMPLES

For a simple app example, try taking a look at C<t/TestApp> in the distribution
tarball.

=head1 METHODS

=head2 $c->features

Returns the feature backend object.

=head2 $c->features->list

Returns an array of loaded features, which are instances of the
L<CatalystX::Features::Feature> class.

=head2 $c->setup

The plugin setup method. Loads features and prints the feature configuration
table.

=head2 $c->features_setup

Does the dirty setup work. Called from various
C<CatalystX::Features::Plugin::*> to make sure features are loaded.

=head1 TODO

These things here, and many, many more that I can't recall right now.

=over 4

=item * Check dependencies among features. 

=item * More plugins.

=item * Deploy PAR/ZIP files automatically. 

=item * Delayed initialization into INC

=back

=head1 BUGS

This is running in production right now somewhere in the corporate limbo.
It has behaved so far. 

=head1 AUTHORS

    Rodrigo de Oliveira (rodrigolive), C<rodrigolive@gmail.com>

=head1 LICENSE

This library is free software. You can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

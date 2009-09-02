package CatalystX::Features::Plugin::ConfigLoader;
use warnings;
use strict;
use Carp;
use base qw/Catalyst::Plugin::ConfigLoader/; 
use MRO::Compat;

our $VERSION = '0.10';

sub find_files {
    my $c = shift;
    my @files = $c->next::method(@_);

    my $appname = ref $c || $c;

    foreach my $feature ( $c->features ) {
        my $suffix = Catalyst::Utils::env_value( $appname, 'CONFIG_LOCAL_SUFFIX' )
            || $c->config->{ 'Plugin::ConfigLoader' }->{ config_local_suffix }
            || 'local';

        my @normal = map { $feature->name.".".$_ }  @{ Config::Any->extensions };
        my @local = map { $feature->name."_${suffix}.".$_ }  @{ Config::Any->extensions };
        push @files, map { Path::Class::dir($feature->path, $_)->stringify } @normal, @local;
    }
    return @files;
}

1;


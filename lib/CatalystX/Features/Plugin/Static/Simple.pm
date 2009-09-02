package CatalystX::Features::Plugin::Static::Simple;
use warnings;
use strict;
use Carp;
use parent qw/Catalyst::Plugin::Static::Simple/; 
use MRO::Compat;

our $VERSION = '0.10';

sub setup {
    my $c = shift;
    $c->next::method(@_);

    my $config = $c->config;

    foreach my $feature ( $c->features ) {
        # change static paths
        push( @{ $config->{static}->{include_path} }, $feature->root );
    }
    return $c;
}

1;

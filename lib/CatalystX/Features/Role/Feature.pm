package CatalystX::Features::Role::Feature;
use Moose::Role;

requires 'id';
requires 'name';
requires 'version';
requires 'path';
requires 'version_number';
requires qw/root lib t/;

1;

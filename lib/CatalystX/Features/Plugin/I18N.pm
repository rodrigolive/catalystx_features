package CatalystX::Features::Plugin::I18N;
use strict;
use warnings;
use parent 'Catalyst::Plugin::I18N';
use MRO::Compat;

our $VERSION = '0.10';

sub setup {
    my $c = shift;

    $c->next::method(@_);

    my $appname = ref $c || $c;

    foreach my $feature ( $c->features ) {
        my $path = Path::Class::dir( $feature->lib, $appname, 'I18N' );

        my $pattern = File::Spec->catfile($path, '*.[pm]o');
        $pattern =~ s{\\}{/}g; # to counter win32 paths

        my $subclass = $Catalyst::Plugin::I18N::options{Subclass} || 'I18N' ;

        eval <<"";
            package $appname\::$subclass;
            Locale::Maketext::Lexicon->import({ '*' => [Gettext => '$pattern' ] });

        if ($@) {
            $c->log->error(qq/Couldn't initialize i18n "$appname\::I18N", "$@"/);
        }
        else {
            $c->log->debug(qq/Initialized i18n "$appname\::I18N"/) if $c->debug;
        }
    
    }
}

1;

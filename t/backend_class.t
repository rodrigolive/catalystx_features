use strict;
use warnings;
use Test::More;

use FindBin;
use lib "$FindBin::Bin/lib/TestAppBackendClass/lib";

use_ok 'Catalyst::Test', 'TestApp';

{
    my ($resp,$c) = ctx_request('/');

    isa_ok( $c->features, 'TestBackendClass' );
}

done_testing;


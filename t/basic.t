use strict;
use warnings;
use Test::More tests => 3;
use B::Deparse;

use FindBin;
use lib "$FindBin::Bin/TestApp/lib";

use Catalyst::Test 'TestApp';

{
	my $c = new TestApp();
	my $features = $c->features;
	ok( ref $features, 'there are features' );

    ok(
        grep( m{/TestApp/root/static/main.js$},
            $c->path_to( 'root', 'static', 'main.js' ) ),
        'normal path_to works'
    );

	my @list = $c->features->list;
	is( scalar @list, 5, 'five features' );
}

# not ready yet
#{
#    my $resp = request('/test/init');
#    is($resp->content, 'value: 99', 'feature main module init');
#}

done_testing;

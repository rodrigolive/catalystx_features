use strict;
use warnings;
use Test::More tests => 2;
use B::Deparse;

use FindBin;
use lib "$FindBin::Bin/TestApp/lib";

use Catalyst::Test 'TestApp';

{
	my $c = new TestApp();
	my $features = $c->features;
	ok( ref $features, 'there are features' );

	my @list = $c->features->list;
	is( scalar @list, 5, 'five features' );
}

# not ready yet
#{
#    my $resp = request('/test/init');
#    is($resp->content, 'value: 99', 'feature main module init');
#}

done_testing;

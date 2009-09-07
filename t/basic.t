use strict;
use warnings;
use Test::More tests => 9;
use B::Deparse;

use FindBin;
use lib "$FindBin::Bin/TestApp/lib";

use Catalyst::Test 'TestApp';

{
    my $resp = request('/loc');
    is($resp->content, 'tontoculo', 'basic localization');
}

{
    my $resp = request('/test/loc');
    is($resp->content, 'chungo', 'feature localization');
}

{
    my $resp = request('/static/main.js');
    is($resp->content, "static stuff\n", 'basic static simple');
}

{
    my $resp = request('/static/feature.html');
    is($resp->content, "feature body\n", 'feature static simple');
}

{
    my $resp = request('/test/mason');
    is($resp->content, 'mason running', 'feature mason template');
}

{
    my $resp = request('/test/tt');
    is($resp->content, 'in feature tt', 'feature tt template');
}

{
    my $resp = request('/test/foo');
    is($resp->content, 'bar', 'feature config value test');
}

{
    my $resp = request('/main');
    is($resp->content, 'in main tt', 'basic tt template' );
}

{
    my $resp = request('/main_to_test');
    is($resp->content, 'in feature tt', 'forward from main app to a feature template');
}

# not ready yet
#{
#    my $resp = request('/test/init');
#    is($resp->content, 'value: 99', 'feature main module init');
#}

done_testing;

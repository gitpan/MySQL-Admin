use strict;
use warnings;
use HTML::Window qw(:all);
my %parameter = ( path   => "cgi-bin/templates",
                  server => "http://localhost", );
set_closeable(1);
set_moveable(1);
set_resizeable(0);
set_class('sidebar');
set_style('lze');
set_title('Test');
set_collapse(1);
initWindow( \%parameter );
my $h1 = windowHeader();
my $h2 = windowFooter();
use Test::More tests => 3;
ok( length($h1) > 0 );
ok( length($h2) > 0 );
ok( length($h1) > length($h2) );

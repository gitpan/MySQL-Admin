#use lib qw(lib/);
use strict;
use vars qw($lang);
use Test::More tests => 2;
use MySQL::Admin::Translate;
loadTranslate("cgi-bin/config/translate.pl");
*lang = \$MySQL::Admin::Translate::lang;
ok( $lang->{de}{firstname} eq 'Vorname' );
ok( $lang->{en}{username}  eq 'User' );

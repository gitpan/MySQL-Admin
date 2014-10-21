use HTML::Editor qw(:all);

$ENV{HTTP_ACCEPT_LANGUAGE} = "de";
my %parameter = (
          action    => 'action',
          body      => 'body of the message',
          class     => "min",
          attach    => '1',
          maxlength => '100',
          path      => "blib/perl/templates/",
          reply     => '',
          server    => "http://localhost",
          style     => 'lze',
          thread    => 'news',
          title     => "&New Message",
          html      => 1,                        # html enabled ? 0 for bbcode
          config    => "t/settings.pl",
);
initEditor( \%parameter );
use Test::More tests => 1;
ok( length( show() ) > 0 );

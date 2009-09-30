#!/usr/bin/perl -w
use lib qw(../lib);
use HTML::Editor;
use HTML::Editor::BBCODE;
use MySQL::Admin qw(:all);
use vars qw($m_hrSettings);
init();
*m_hrSettings= \$MySQL::Admin::settings;
print header;
print start_html(-title => 'HTML::Editor', -script => [{-type => 'text/javascript', -src => '/javascript/content.js'}], -style =>[ '/style/lze/lze16.css', '/style/lze/window.css'],);
print qq|
<script type="text/javascript">
var style ="lze";
var right = 0;
var htmlright = 0;
</script>|;
if(param('action') && param('action') eq 'add') {
        my $txt = param('message');
        if(param('submit') eq translate('preview')) {
                print a({href => "$ENV{SCRIPT_NAME}?txt=$txt"}, 'Edit it Again');
                print h2(param('headline'));
                BBCODE(\$txt);
                print br(), $txt;
        } else {
                print "You should save it ", br();
                print $txt;
                print br(), a({href => "$ENV{SCRIPT_NAME}?txt=$txt"}, 'Edit it Again');
        }
        } else {

        my %parameter = (

                action => 'add',

                body => param('txt') ? param('txt') : 'body of the message',

                class => "min",

                attach => ' ',

                maxlength => '100',

                path => "../templates/",

                reply => '',

                server => "http://localhost",

                style => 'lze',

                thread => 'news',

                headline => "New Message",
                title    => "title",
                catlist  => ' ',
                html     => 1,               # html enabled ? 0 for bbcode
        );
        my $editor = new HTML::Editor(\%parameter);

        print $editor->show();
}
use showsource;&showSource($0);

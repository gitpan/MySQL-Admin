$VAR1 = {
          'htmlright' => 2,
          'actions' => '/srv/www/cgi-bin/config/actions.pl',
          'tree' => {
                      'navigation' => '/srv/www/cgi-bin/config/tree.pl',
                      'links' => '/srv/www/cgi-bin/config/links.pl'
                    },
          'defaultAction' => 'news',
          'files' => {
                       'owner' => 'linse',
                       'group' => 'users',
                       'chmod' => '0755'
                     },
          'size' => 16,
          'uploads' => {
                         'maxlength' => 2003153,
                         'right' => 5,
                         'path' => '/srv/www//htdocs/downloads/',
                         'chmod' => 420,
                         'enabled' => 1
                       },
          'floodtime' => 10,
          'session' => '/srv/www/cgi-bin/config/session.pl',
          'scriptAlias' => 'cgi-bin',
          'admin' => {
                       'country' => 'Deutschland',
                       'firstname' => 'Dirk',
                       'number' => '33',
                       'postocde' => '10965',
                       'street' => 'example',
                       'name' => 'Lindner',
                       'town' => 'Berlin',
                       'aim' => '',
                       'msn' => '',
                       'jahoo' => '',
                       'email' => 'lze(a)cpan.org',
                       'icq' => '350108541',
                       'password' => 'testpass',
                       'signature' => 'perl -e\'&{sub{s~~shift~e;s-(&*{*{*#*L*.Z*.E*.)-chr-eg;print}}(100105114107)\'',
                       'tel' => '',
                       'skype' => 'pro_soccer',
                       'jabber' => ''
                     },
          'language' => 'en',
          'version' => '0.57',
          'cgi' => {
                     'bin' => '/srv/www/cgi-bin',
                     'style' => 'lze',
                     'serverName' => 'http://localhost',
                     'cookiePath' => '/',
                     'title' => 'MySQL::Admin',
                     'mod_rewrite' => '1',
                     'alias' => 'cgi-bin',
                     'DocumentRoot' => '/srv/www//htdocs',
                     'expires' => '+1y'
                   },
          'database' => {
                          'CurrentUser' => 'root',
                          'name' => 'LZE',
                          'CurrentPass' => '',
                          'host' => 'localhost',
                          'password' => '',
                          'user' => 'root',
                          'CurrentDb' => 'LZE',
                          'CurrentHost' => 'localhost'
                        },
          'sidebar' => {
                         'left' => 0,
                         'right' => 1
                       },
          'translate' => '/srv/www/cgi-bin/config/translate.pl',
          'config' => '/srv/www/cgi-bin/config/settings.pl',
          'news' => {
                      'maxlength' => 5000,
                      'right' => 5,
                      'messages' => 10,
                      'captcha' => 5
                    }
        };
$m_hrSettings =$VAR1;
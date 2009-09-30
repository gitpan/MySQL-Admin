use utf8;

sub fulltext
{
    my $search = param('query');
    my %parameter = (
                     path     => $m_hrSettings->{cgi}{bin} . '/templates',
                     style    => $m_sStyle,
                     template => "wnd.htm",
                     server   => $m_hrSettings->{serverName},
                     id       => 'Search',
                     class    => 'max',
    );

    my $window = new HTML::Window(\%parameter);
    $m_sContent .= br() . $window->windowHeader();
    $m_sContent .= '<div align="center">';
    $m_sContent .= br();
    my $ts = translate('search');
    my $checked = defined param('regexp') ? 'checked="checked"' : '';
    $m_sContent .= qq(
<div align="center">
<a href="http://www.google.com/custom?q=$search&amp;sa=Google+Search&amp;&amp;domains=$m_hrSettings->{cgi}{serverName}&amp;sitesearch=$m_hrSettings->{cgi}{serverName}" class="menulink">Search with Google</a><br/><br/>
<form action="$ENV{SCRIPT_NAME}" name="search" accept-charset="UTF-8">
<input align="top" type="text" maxlength="100" title="$ts" name="query" id="query" value="$search"/>
<input  type="hidden" name="action"  value="fulltext"/>
<input type="submit"  name="submit" value="$ts" maxlength="15" alt="$ts" align="left" />
Regexp:<input type="checkbox" $checked name="regexp" value="regexp" alt="regexp" align="left" />
</form></div>
);
    $m_sContent .= br();
    my $qsearch = $m_oDatabase->quote($search);
    my @count =
      $search
      ? (
         (defined param('regexp'))
         ? $m_oDatabase->fetch_array("SELECT count(*) FROM news WHERE  `right` <= $m_nRight  && ( body REGEXP $qsearch || title REGEXP $qsearch )  order by date desc  ")
         : $m_oDatabase->fetch_array("SELECT count(*) FROM news  where `right` <= $m_nRight and MATCH (title,body) AGAINST(?)", $search)
      )
      : 0;
    my $length = $count[0];

    if ($length > 0) {
        $m_sContent .= '<table align="center" border ="0" cellpadding ="0" cellspacing="0" summary="showThread" width="100%" >';
        $m_sContent .= Tr(
                          td(
                             div(
                                 {align => 'right'},
                                 (
                                  $length > 5
                                  ? translate('news_pro_page') . '&#160;|&#160;'
                                  : ''
                                   )
                                   . (
                                      $length > 5
                                      ? a(
                                          {
                                           href  => "$ENV{SCRIPT_NAME}?action=$akt&links_pro_page=5&von=$m_nStart$replylink",
                                           class => ($lpp == 5 ? 'menuLink2' : 'menuLink3')
                                          },
                                          '5'
                                        )
                                        . '&#160;'
                                      : ''
                                   )
                                   . (
                                      $length > 10
                                      ? a(
                                          {
                                           href  => "$ENV{SCRIPT_NAME}?action=$akt&links_pro_page=10&von=$m_nStart$replylink",
                                           class => ($lpp == 10 ? 'menuLink2' : 'menuLink3')
                                          },
                                          '10'
                                        )
                                        . '&#160;'
                                      : ''
                                   )
                                   . (
                                      $length > 30
                                      ? a(
                                          {
                                           href  => "$ENV{SCRIPT_NAME}?action=$akt&links_pro_page=30&von=$m_nStart$replylink",
                                           class => ($lpp == 30 ? 'menuLink2' : 'menuLink3')
                                          },
                                          '30'
                                        )
                                      : ''
                                   )
                             )
                          )
        );

        my %needed = (
                      start          => $m_nStart,
                      length         => $length,
                      style          => $m_sStyle,
                      mod_rewrite    => $m_hrSettings->{cgi}{mod_rewrite},
                      action         => "fulltext",
                      links_pro_page => $lpp,
                      append         => "&query=$search" . (defined param('regexp') ? '&regexp=regexp' : '')
        );

        my $pages = makePages(\%needed);
        $m_sContent .= '<tr><td>' . $pages . '</td></tr>';

        if (defined param('regexp')) {
            $m_sContent .= '<tr><td>' . $m_oDatabase->searchDB($search, 'body', 'news', $m_nRight, $m_nStart, $m_nEnd) . '</td></tr>';
        } else {
            $m_sContent .= '<tr><td>' . $m_oDatabase->fulltext($search, 'news', $m_nRight, $m_nStart, $m_nEnd) . '</td></tr>';
        }

        $m_sContent .= '<tr><td>' . $pages . '</td></tr>';
        $m_sContent .= '</table>';
    }
    $m_sContent .= '</div>';
    $m_sContent .= $window->windowFooter();
}

1;

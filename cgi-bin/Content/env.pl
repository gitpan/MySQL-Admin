my $env = translate('env');
my %parameter = (
                 path   => $m_hrSettings->{cgi}{bin} . '/templates',
                 style  => $m_sStyle,
                 title  => $env,
                 server => $m_hrSettings->{cgi}{serverName},
                 id     => 'Variables',
                 class  => 'max',
);
my $window = new HTML::Window(\%parameter);
$window->set_closeable(0);
$window->set_moveable(0);
$window->set_resizeable(0);
$m_sContent .= br() . $window->windowHeader();
$m_sContent .= "<h1>$env</h1>";
$m_sContent .= '<table align ="center" border ="0" cellpadding ="2" cellspacing="2" summary="env">';

foreach my $key (keys %ENV) {
    $m_sContent .= qq(<tr><td class="env" valign="top" width="100"><strong>$key</strong></td><td class="envValue" valign="top" width ="400">) . join("<br/>", split(/,/, $ENV{$key})) . '</td></tr>';
}
$m_sContent .= '</table>';
$m_sContent .= $window->windowFooter();

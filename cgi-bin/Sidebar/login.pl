my %parameter = (
                 path   => $m_hrSettings->{cgi}{bin} . '/templates',
                 style  => $m_sStyle,
                 title  => "&#160;Login",
                 server => $m_hrSettings->{cgi}{serverName},
                 id     => 'nlogin',
                 class  => 'sidebar',
);
my $window = new HTML::Window(\%parameter);
$window->set_closeable(1);
$window->set_moveable(0);
$window->set_resizeable(0);
$window->set_collapse(0);
$m_sContent .= '<tr id="trwnlogin"><td valign="top" class="sidebar">';
$m_sContent .= $window->windowHeader();

if ($m_sUser eq 'guest') {
    my $link     = $m_hrSettings->{cgi}{mod_rewrite} ? "/reg.html" : "$ENV{SCRIPT_NAME}?action=reg";
    my $trlogin  = translate('login');
    my $trreg    = translate('reg');
    my $password = translate('password');
    my $name     = translate('name');
    $m_sContent .=
qq(<div align="center" id="form"><form  action=""  target="_parent" method="post"  name="Login"  onSubmit="return checkLogin()"><label for="user">$name</label><br/><input type="text" id="user" name="user" value="" size="18" maxlength="25" alt="Login" align="left"><br/><label for="password">$password</label><br/><input type="hidden" name="action" value="login"/><input type="password" id="password" name="pass" value ="" size="18" maxlength="50" alt="password" align="left"/><br/><br/><input type="submit"  name="submit" value="$trlogin" size="15" maxlength="15" alt="submit" align="left"/></form><a  class="link" href="$link">$trreg</a></div>);
} else {
    my $lg      = $m_hrSettings->{cgi}{mod_rewrite} ? '/logout.html' : "$ENV{SCRIPT_NAME}?action=logout";
    my $welcome = translate('welcome');
    my $logout  = translate('logout');
    $m_sContent .= qq($welcome, $m_sUser <br/><a  class="link" href="$lg">$logout</a><br/>);    #todo translate
}
$m_sContent .= $window->windowFooter();
$m_sContent .= '<br/></td></tr>';
1;

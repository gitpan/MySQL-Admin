sub reg {
    my $sUserRegName = param('username');
    $sUserRegName =
        ( $sUserRegName =~ /^(\w{3,10})$/ ) ? $1 : translate('insertname');
    $sUserRegName = lc $sUserRegName;
    my $email = param('email');
    my %vars = ( title  => 'reg',
                 user   => 'guest',
                 action => 'makeUser',
                 file   => "$m_hrSettings->{cgi}{bin}/Content/reg.pl",
                 sub    => 'make',
                 right  => 0
    );
    my $qstring  = createSession( \%vars );
    my $register = translate('register');
    my %parameter = ( path   => $m_hrSettings->{cgi}{bin} . '/templates',
                      style  => $m_sStyle,
                      title  => $register,
                      server => $m_hrSettings->{cgi}{serverName},
                      id     => "reg$id",
                      class  => 'reg',
    );
    my $window    = new HTML::Window( \%parameter );
    my $t_regtext = translate('t_regtext');
    $m_sContent .=
        qq(<table  border="0" cellpadding="0" cellspacing="10" summary="contentLayout" width="100%"><tr><td valign="top" align="center">);
    $m_sContent .=
          br()
        . $window->windowHeader()
        . qq(<div align="center">$t_regtext<br/><form action="$ENV{SCRIPT_NAME}"  method="post"  name="Login" ><label for="username">Name</label><br/><input type="text" name="username" id="username" title="Bitte geben Sie ihren Namen  ein." value="$sUserRegName" size="20" maxlength="10" alt="Login" align="left"/><br/><label for="email">Email</label><br/><input type="text" name="email" value="$email" id="email" size="20" maxlength="200" alt="email" align="left"/><br/><input type="hidden" name="include" value="$qstring"/><br/><input type="submit"  name="submit" value="$register" size="15" alt="$register" align="left"/></form></div>)
        . $window->windowFooter();
    $m_sContent .= '</td></tr></table>';
}

sub make {
    my $fr           = 0;
    my $fingerprint  = param('fingerprint');
    my $sUserRegName = param('username');
    my $email        = param('email');
    my $imagedir     = $m_hrSettings->{'cgi'}{'DocumentRoot'} . '/images/';
    my $tlt          = translate('register');
    my %parameter = ( path   => $m_hrSettings->{cgi}{bin} . '/templates',
                      style  => $m_sStyle,
                      title  => $tlt,
                      server => $m_hrSettings->{cgi}{serverName},
                      id     => "reg$id",
                      class  => 'reg',
    );
    my $window = new HTML::Window( \%parameter );
    $m_sContent .= br() . $window->windowHeader();
SWITCH: {

        if ( defined $sUserRegName ) {
            if ( $m_oDatabase->isMember($sUserRegName) ) {
                $m_sContent .= translate('userexits');
                $fr           = 1;
                $sUserRegName = undef;
            }
        } else {
            $m_sContent .= translate('wrongusername');
            $fr = 1;
        }
        if ( $m_oDatabase->hasAcount($email) ) {
            $m_sContent .= translate('haveacount');
            $fr           = 1;
            $sUserRegName = undef;
        }
        unless ( defined $email ) {
            $m_sContent .= translate('nomail');
            $fr = 1;
        }
        &reg() if ($fr);
        last SWITCH if ($fr);
        use Mail::Sendmail;
        my $pass = int( rand(1000)+ 1 ) x 3;
        my %mail = ( To      => "$email",
                     From    => $m_hrSettings->{'admin'}{'email'},
                     subject => translate('mailsubject'),
                     Message => translate('regmessage')
                         . translate('username')
                         . ": $sUserRegName "
                         . translate('password')
                         . ":$pass"
        );
        sendmail(%mail) or warn $Mail::Sendmail::error;
        $m_oDatabase->addUser( $sUserRegName, $pass, $email );
        my $trlogin = translate('next');
        $m_sContent .=
            qq(<div align="center" id="form"><form  action=""  target="_parent" method="post"  name="Login"  onSubmit="return checkLogin()"><label for="user">Name</label><br/>$sUserRegName<input type="hidden" id="user" name="user" value="$sUserRegName" size="18" maxlength="50" alt="Login" align="left"><br/><label for="password">Password</label><br/>$pass<input type="hidden" name="action" value="login"/><input type="hidden" id="password" name="pass" value ="$pass" size="18" maxlength="50" alt="password" align="left"/><br/><br/><input type="submit"  name="submit" value="$trlogin" size="15" maxlength="15" alt="submit" align="left"/></form><a  class="link" href="$link">$trreg</a></div>);
    }
    clearSession();
    $m_sContent .= $window->windowFooter();
}
1;

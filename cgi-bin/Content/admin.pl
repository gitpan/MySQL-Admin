my %parameter = (
                 path   => $m_hrSettings->{cgi}{bin} . '/templates',
                 style  => $m_sStyle,
                 title  => translate('admin'),
                 server => $m_hrSettings->{cgi}{serverName},
                 id     => 'adminWindow',
                 class  => 'max',
);
my $window = new HTML::Window(\%parameter);
$window->set_closeable(0);
$window->set_moveable(0);
$window->set_resizeable(0);
$m_sContent .= br() . $window->windowHeader();
my $tn  = translate('editnavi');
my $ts  = translate('settings');
my $td  = translate('database');
my $tl  = translate('bookmarks');
my $tf  = translate('explorer');
my $te  = translate('env');
my $tna = translate('navigation');
my $tr  = translate('trash');
my $trn = translate('translate');
$m_sContent .= qq(<table align="center" border="0" cellpadding="0" cellspacing="0" summary="adminlayout" width="100%">
<tr>
<td align="center">
<img src="/style/$m_sStyle/buttons/settings.png" alt="$ts" border="0" title="$ts"/><br/>
<a href="$ENV{SCRIPT_NAME}?action=settings">$ts</a>
</td><td align="center">
<img src="/style/$m_sStyle/buttons/mysql.jpg" alt="$td" border="0" title="$td"/><br/>
<a href="$ENV{SCRIPT_NAME}?action=showTables">$td</a>
</td><td align="center">
<img src="/style/$m_sStyle/buttons/folder_txt.png" alt="$tna" border="0" title="$tna"/><br/>
<a href="$ENV{SCRIPT_NAME}?action=editTreeview">$tna</a>
</td>
</tr><tr>
<td align="center">
<img src="/style/$m_sStyle/buttons/bookmark.png" alt="$tl" border="0" title="$tl"/><br/>
<a href="$ENV{SCRIPT_NAME}?action=editTreeview&amp;dump=links">$tl</a>
</td><td align="center">
<img src="/style/$m_sStyle/buttons/explorer.png" alt="$tf" border="0" title="$tf"/><br/>
<a href="$ENV{SCRIPT_NAME}?action=showDir">$tf</a>
</td><td align="center">
<img src="/style/$m_sStyle/buttons/env.png" alt="$te" border="0" title="$te"/><br/>
<a href="$ENV{SCRIPT_NAME}?action=env">$te</a>
</td>
</tr>
<tr><td align="center"><img src="/style/$m_sStyle/buttons/trash.png" alt="$tr" border="0" title="$tr"/><br/><a href="$ENV{SCRIPT_NAME}?action=trash">$tr</a></td>
<td align="center"><img src="/style/$m_sStyle/buttons/translate.png" alt="$trn" border="0" title="$trn"/><br/><a href="$ENV{SCRIPT_NAME}?action=translate">$trn</a></td>
<td align="center">&#160;</td>
</tr>);
$m_sContent .= q(</table><br/>);

&showExploits() unless ($m_sAction eq 'deleteexploit');
$m_sContent .= $window->windowFooter();

sub deleteExploit
{
    my $id = param('id');
    $m_oDatabase->void("DELETE FROM exploit where id  = ?", $id);
    &showExploits();
}

sub showExploits
{
    my @exploit = $m_oDatabase->fetch_AoH("select * from exploit");
    $m_sContent .= q(<div align="center"><h3>Exploits</h3>);
    for (my $i = 0; $i <= ($#exploit > 10 ? 10 : $#exploit); $i++) {
        $m_sContent .= "<hr/>";
        foreach my $key (keys %{$exploit[$i]}) {
            $m_sContent .= "<b>$key:</b> " . $exploit[$i]->{$key} . br();
        }
        $m_sContent .= qq(<a href="$ENV{SCRIPT_NAME}?action=deleteExploit&amp;id=$exploit[$i]->{id}">Delete</a>);
    }
    $m_sContent .= qq(<br/><a href="$ENV{SCRIPT_NAME}?action=TruncateTable&amp;table=exploit">Truncate Exploits</a></div>);
}

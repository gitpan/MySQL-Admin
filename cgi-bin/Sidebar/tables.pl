no warnings "uninitialized";
ChangeDb(
         {
          name     => $m_sCurrentDb,
          host     => $m_sCurrentHost,
          user     => $m_sCurrentUser,
          password => $m_sCurrentPass,
         }
);
my @menu = $m_oDatabase->fetch_array("show tables");
my @dbs;
for (my $i = 0; $i <= $#menu; $i++) {
    maxlength(15, \$menu[$i]);
    push @dbs,
      {
        text => $menu[$i],
        href => "javascript:location.href='$ENV{SCRIPT_NAME}?action='+cAction+'&amp;table=$menu[$i]'",
      };
}
my $trdatabase = translate('database');
my %parameter = (
                 path   => $m_hrSettings->{cgi}{bin} . '/templates',
                 style  => $m_sStyle,
                 title  => "&#160;$trdatabase&#160;&#160;&#160;&#160;",
                 server => $m_hrSettings->{cgi}{serverName},
                 id     => "ndb1",
                 class  => "sidebar",
);
my $window = new HTML::Window(\%parameter);
$window->set_closeable(1);
$window->set_moveable(1);
$window->set_resizeable(0);
$m_sContent .= qq|<tr id="trwndb1"><td valign="top" class="sidebar"><form action="$ENV{SCRIPT_NAME}" name="changeDb" method="GET">|;
$m_sContent .= $window->windowHeader();
$m_sContent .= '<div align="center">' . $m_oDatabase->GetDataBases('m_ChangeCurrentDb', 1) . '</form></div><div align="center">';
my $newAction = $m_sAction =~ /ShowTable|ShowTableDetails|EditTable/ ? $m_sAction : 'ShowTable';
$m_sContent .= qq|
<script language="JavaScript1.5" type="text/javascript">cAction = '$newAction';</script>
<select onchange="setAction(this.options[this.options.selectedIndex].value)" style="width:75%;">
<option value="ShowTable" |
  . (param('action') eq 'ShowTable' ? 'selected="selected"' : '') . '>' . translate('show') . '</option>
<option value="ShowTableDetails" '
  . (param('action') eq 'ShowTableDetails' ? 'selected="selected"' : '') . '>' . translate('details') . '</option>
<option value="EditTable" '
  . (param('action') eq 'EditTable' ? 'selected="selected"' : '') . '>' . translate('edit') . qq'</option>
<option value="ShowDumpTable" '
  . (param('action') eq 'ShowDumpTable' ? 'selected="selected"' : '') . '>' . translate('Export') . qq'</option>
<option value="AnalyzeTable" '
  . (param('action') eq 'AnalyzeTable' ? 'selected="selected"' : '') . '>' . translate('AnalyzeTable') . qq'</option>
<option value="OptimizeTable" '
  . (param('action') eq 'OptimizeTable' ? 'selected="selected"' : '') . '>' . translate('OptimizeTable') . qq'</option>
<option value="RepairTable" '
  . (param('action') eq 'RepairTable' ? 'selected="selected"' : '') . '>' . translate('RepairTable') . qq|</option
  </select><br/><br/><a href="$ENV{SCRIPT_NAME}?action=showDatabases" >|
  . translate('database') . ' </a></div>';
$m_sContent .= Tree(\@dbs, $m_sStyle);
$m_sContent .= $window->windowFooter();
$m_sContent .= '</td></tr>';
ChangeDb(
         {
          name     => $m_hrSettings->{database}{name},
          host     => $m_hrSettings->{database}{host},
          user     => $m_hrSettings->{database}{user},
          password => $m_hrSettings->{database}{password},
         }
);

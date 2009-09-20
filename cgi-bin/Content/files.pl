use vars qw($r);

sub EditFile
{
    my $name = defined param('name') ? param('name') : $m_sAction;
    my @n = $m_oDatabase->fetch_array("select file from `actions` where action=?", $name);
    FileOpen("$m_hrSettings->{cgi}{bin}/Content/$n[0]");
}
use POSIX 'floor';

sub round
{
    my $x = shift;
    floor($x + 0.5);
}

sub showDir
{
    my $sSubfolder = param('subfolder') ? param('subfolder') : shift;
    $sSubfolder = defined $sSubfolder ? $sSubfolder : $m_hrSettings->{cgi}{bin};
    $sSubfolder =~ s?/$??g;
    my $links = $sSubfolder =~ ?^(.*/)[^/]+$? ? $1 : $sSubfolder;
    my $fname = $sSubfolder =~ ?^.*/([^/]+)$? ? qq(<span style="color:white">$1</span>) : $sSubfolder;
    $links =~ s?//?/?g;
    my $elinks     = uri_escape($links);
    my $esubfolder = uri_escape($sSubfolder);
    $r = 0;
    my $orderby  = defined param('orderBy')  ? param('orderBy')  : 'Name';
    my $byColumn = defined param('byColumn') ? param('byColumn') : -1;
    my $state = defined param('desc') ? param('desc') == 1 ? 1 : 0 : 0;
    my $newstate = $state ? 0 : 1;
    my @t = readFiles($sSubfolder, 0);

    if ($byColumn) {
        orderByColumn($byColumn);
        desc(1) if $state;
    } elsif (param('sort')) {
        sortTree(1);
        desc(1) if $state;
    }
    TrOver(1);
    @t = sort {lc($a->{mtime}) cmp lc($b->{mtime})} @t if $orderby eq 'mTime';
    @t = sort {lc($a->{size}) <=> lc($b->{size})} @t   if $orderby eq 'Size';
    @t = reverse @t if $state;
    columns(
            a(
               {
                href  => "$ENV{SCRIPT_NAME}?action=FileOpen&file=$esubfolder&sort=1&desc=$newstate",
                class => "treeviewLink$m_nSize",
                align => "left",
                style => 'white-space:nowrap;'
               },
               'Name'
              )
              . (
                 param('sort')
                 ? (
                    $state
                    ? qq|&#160;<img src="/style/$m_sStyle/$m_nSize/mimetypes/up.png" border="0" alt="" title="up" width="16" height="16" />|
                    : qq|&#160;<img src="/style/$m_sStyle/$m_nSize/mimetypes/down.png" border="0" alt="" title="down"/>|
                   )
                 : ''
              )
              . '&#160;',
            a(
               {
                href  => "$ENV{SCRIPT_NAME}?action=FileOpen&file=$esubfolder&orderBy=Size&desc=$newstate",
                class => "treeviewLink$m_nSize",
                align => "left"
               },
               'Size'
              )
              . (
                 $orderby eq 'Size'
                 ? (
                    $state
                    ? qq|&#160;<img src="/style/$m_sStyle/$m_nSize/mimetypes/up.png" border="0" alt="" title="up" width="16" height="16" />|
                    : qq|&#160;<img src="/style/$m_sStyle/$m_nSize/mimetypes/down.png" border="0" alt="" title="down"/>|
                   )
                 : ''
              )
              . '&#160;',
            a(
               {
                href  => "$ENV{SCRIPT_NAME}?action=FileOpen&file=$esubfolder&byColumn=0&desc=$newstate",
                class => "treeviewLink$m_nSize",
                align => "left"
               },
               'Permission'
              )
              . (
                 $byColumn == 0 && !param('sort')
                 ? (
                    $state
                    ? qq|&#160;<img src="/style/$m_sStyle/$m_nSize/mimetypes/up.png" border="0" alt="" title="up" width="16" height="16" />|
                    : qq|&#160;<img src="/style/$m_sStyle/$m_nSize/mimetypes/down.png" border="0" alt="" title="down" />|
                   )
                 : ''
              )
              . '&#160;',
            a(
               {
                href  => "$ENV{SCRIPT_NAME}?action=FileOpen&file=$esubfolder&byColumn=2&desc=$newstate",
                class => "treeviewLink$m_nSize",
                align => "left"
               },
               'UID'
              )
              . (
                 $byColumn == 2
                 ? (
                    $state
                    ? qq|&#160;<img src="/style/$m_sStyle/$m_nSize/mimetypes/up.png" border="0" alt="" title="up" width="16" height="16" />|
                    : qq|&#160;<img src="/style/$m_sStyle/$m_nSize/mimetypes/down.png" border="0" alt="" title="down"/>|
                   )
                 : ''
              )
              . '&#160;',
            a(
               {
                href  => "$ENV{SCRIPT_NAME}?action=FileOpen&file=$esubfolder&byColumn=3&desc=$newstate",
                class => "treeviewLink$m_nSize",
                align => "left"
               },
               'GID'
              )
              . (
                 $byColumn == 3
                 ? (
                    $state
                    ? qq|&#160;<img src="/style/$m_sStyle/$m_nSize/mimetypes/up.png" border="0" alt="" title="up" width="16" height="16"/>|
                    : qq|&#160;<img src="/style/$m_sStyle/$m_nSize/mimetypes/down.png" border="0" alt="" title="down" />|
                   )
                 : ''
              )
              . '&#160;',
            a(
               {
                href  => "$ENV{SCRIPT_NAME}?action=FileOpen&file=$esubfolder&orderBy=mTime&desc=$newstate",
                class => "treeviewLink$m_nSize",
                align => "left"
               },
               'Last Modified'
              )
              . (
                 $orderby eq 'mTime'
                 ? (
                    $state
                    ? qq|&#160;<img src="/style/$m_sStyle/$m_nSize/mimetypes/up.png" border="0" alt="" title="up" width="16" height="16"/>|
                    : qq|&#160;<img src="/style/$m_sStyle/$m_nSize/mimetypes/down.png" border="0" alt="" title="down"/>|
                   )
                 : ''
              )
              . '&#160;',
            "",
    );
    my $hf = "$ENV{SCRIPT_NAME}?action=FileOpen&file=$elinks";
    my %parameter = (
                     path   => $m_hrSettings->{cgi}{bin} . '/templates',
                     style  => $m_sStyle,
                     title  => "",
                     server => $m_hrSettings->{serverName},
                     id     => 'showDir',
                     class  => 'min',
    );
    my $window = new HTML::Window(\%parameter);
    $m_sContent .= br() . $window->windowHeader();
    $m_sContent .= div(
        {align => 'center'},
        a(
           {
            href  => $hf,
            class => "treeviewLink$m_nSize"
           },
           $links . $fname
          )
          . br()
          . a(
            {
             href =>
"javascript:var a = prompt('Enter File Name');if(a != null )location.href = '$ENV{SCRIPT_NAME}?action=newFile&file='+encodeURIComponent(a)+'&dir=$esubfolder';",
             class => "treeviewLink$m_nSize"
            },
            "New File"
          )
          . '&#160;|&#160;'
          . a(
            {
             href =>
"javascript:var a = prompt('Neues Verzeichnis');if(a != null )location.href = '$ENV{SCRIPT_NAME}?action=makeDir&file=$esubfolder&d='+encodeURIComponent(a);",
             class => "treeviewLink$m_nSize"
            },
            "New Directory"
          )
          . '&#160;|&#160;'
          . a(
            {
             href =>
"javascript:var a = prompt('Enter Chmod: 0755');if(a != null )location.href = '$ENV{SCRIPT_NAME}?action=chmodFile&file=$esubfolder&chmod='+encodeURIComponent(a);",
             class => "treeviewLink$m_nSize"
            },
            "Chmod",
          )
          . '&#160;|&#160;'
          . a(
            {
             href =>
"javascript:var a = prompt('Enter User:'),b = prompt('Enter Group:');if(a != null  && b != null)location.href = '$ENV{SCRIPT_NAME}?action=chownFile&file=$esubfolder&user='+encodeURIComponent(a)+'&gid='+encodeURIComponent(b);",
             class => "treeviewLink$m_nSize"
            },
            "Chown",
          )
          . br()
          . br()
          . Tree(\@t, $m_sStyle)
          . br()
          . $window->windowFooter()
    );
    border(0);
    TrOver(0);
    sortTree(0);
    orderByColumn(0);
    $HTML::Menu::TreeView::orderbyColumn = undef;
    desc();
}

sub readFiles
{
    my @TREEVIEW;
    my $dir  = shift;
    my $edir = uri_escape($dir);
    my $rk   = shift;
    $r++ if ($rk);
    if (-d "$dir" && -r "$dir") {
        opendir DIR, $dir or warn "files.pl sub readFiles: $dir $!";
        foreach my $d (readdir(DIR)) {
            my $fl = "$dir/$d";
            use File::stat;
            my $sb = stat($fl);
            TYPE: {
                last TYPE if ($d =~ /^\.+$/);
                my $efl  = uri_escape($fl);
                my $href = "$ENV{SCRIPT_NAME}?action=FileOpen&amp;file=$efl";
                my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime($sb->mtime);
                $year += 1900;
                $mon  = sprintf("%02d", $mon);
                $mday = sprintf("%02d", $mday);
                $min  = sprintf("%02d", $min);
                $hour = sprintf("%02d", $hour);
                $sec  = sprintf("%02d", $sec);
                my ($gname, $passwd, $gid, $members) = getgrgid $sb->gid;

                if (-d $fl) {
                    push @TREEVIEW,
                      {
                        text    => $d,
                        href    => "$href/",
                        empty   => 1,
                        mtime   => $sb->mtime,
                        size    => $sb->size,
                        columns => [
                                   sprintf("%s",   $sb->size),
                                   sprintf("%04o", $sb->mode & 07777),
                                   getpwuid($sb->uid)->name,
                                   $gname,
                                   "$year-$mon-$mday $hour:$min:$sec",
qq|<table border="0" cellpadding="0" cellspacing="0" align="right" summary="layout"><tr><td>&#160;<a class="treeviewLink$m_nSize" href="javascript:var a = prompt('Enter User:'),b = prompt('Enter Group:');if(a != null  && b != null)location.href = '$ENV{SCRIPT_NAME}?action=chownFile&file=$efl&user='+encodeURIComponent(a)+'&gid='+encodeURIComponent(b);">Chown</a></td><td>&#160;<a class="treeviewLink$m_nSize" href="javascript:var a = prompt('Enter Chmod: 0755');if(a != null )location.href = '$ENV{SCRIPT_NAME}?action=chmodFile&file=$efl&chmod='+encodeURIComponent(a);">chmod</a></td><td><a class="treeviewLink$m_nSize" href="javascript:var a = prompt('Enter File Name');location.href = '$ENV{SCRIPT_NAME}?action=newFile&file='+encodeURIComponent(a)+'&dir=$edir';"><img src="/style/$m_sStyle/$m_nSize/mimetypes/filenew.png" border="0" alt="new"/></a></td><td><a class="treeviewLink$m_nSize" href="$ENV{SCRIPT_NAME}?action=deleteFile&amp;file=$efl" onclick="return confirm('Realy delete ?')"><img src="/style/$m_sStyle/$m_nSize/mimetypes/editdelete.png" border="0" alt="delete"/></a></td></td></tr></table>|
                        ],
                      };
                    last TYPE;
                }

                if (-f $fl) {
                    my $suffix = $d =~ /\.([^\.]+)$/ ? $1 : '';
                    push @TREEVIEW,
                      {
                        text    => "$d",
                        href    => "$href",
                        mtime   => $sb->mtime,
                        size    => $sb->size,
                        columns => [
                                   sprintf("%s",   $sb->size),
                                   sprintf("%04o", $sb->mode & 07777),
                                   (getpwuid($sb->uid)->name),
                                   $gname,
                                   "$year-$mon-$mday $hour:$min:$sec",
qq|<table border="0" cellpadding="0" cellspacing="0" align="right" summary="layout"><tr><td>&#160;<a class="treeviewLink$m_nSize" href="javascript:var a = prompt('Enter User:'),b = prompt('Enter Group:');if(a != null  && b != null)location.href = '$ENV{SCRIPT_NAME}?action=chownFile&file=$efl&user='+encodeURIComponent(a)+'&gid='+encodeURIComponent(b);">Chown</a></td><td>&#160;<a class="treeviewLink$m_nSize" href="javascript:var a = prompt('Enter Chmod: 0755');if(a != null )location.href = '$ENV{SCRIPT_NAME}?action=chmodFile&file=$efl&chmod='+encodeURIComponent(a);">chmod</a></td><td><a class="treeviewLink$m_nSize" href="$href"><img src="/style/$m_sStyle/$m_nSize/mimetypes/edit.png" border="0" alt="edit"/></a></td><td><a class="treeviewLink$m_nSize" href="$ENV{SCRIPT_NAME}?action=deleteFile&amp;file=$efl" onclick="return confirm('Realy delete ?')"><img src="/style/$m_sStyle/$m_nSize/mimetypes/editdelete.png" border="0" alt="delete"/></a></td></tr></table>|,
                        ],
                        image => (-e "$m_hrSettings->{cgi}{DocumentRoot}/style/$m_sStyle/$m_nSize/mimetypes/$suffix.png")
                        ? "$suffix.png"
                        : 'link.gif',
                      };
                }
            }
        }
        $r = 0;
        return @TREEVIEW;
    }
}

sub FileOpen
{
    my $f = defined param('file') ? param('file') : shift;
    return unless defined $f;
    SWITCH: {
        if (-d $f) {
            &showDir($f);
            last SWITCH;
        }
        if (-T $f) {
            $m_sContent .= qq(<div align="center">) . a({-href => "javascript:history.back()"}, translate('back')) . "</div>";
            my $content = openFile($f);
            $content =~ s/<\/textarea>/[\%TEXTAREA\%]/gi;
            &showEditor("Edit File: $f<br/>", $content, 'saveFile', $f);
            last SWITCH;
        }
        if ($f =~ /png|jpg|jpeg|gif$/ && $f =~ m~/srv/www/htdocs/(.*)$~) {
            $m_sContent .=
                br()
              . qq(<div align="center"><img alt="" src="/$1" align="center"/>)
              . br()
              . a({-href => "javascript:history.back()"}, translate('back'))
              . "</div>";
            last SWITCH;
        }
        $m_sContent .= br() . translate("UnsopportedFileType") . br() . a({-href => "javascript:history.back()"}, translate('back'));
    }
}

sub saveFile
{
    my $txt = param('txt');
    $txt =~ s/\[%TEXTAREA%\]/<\/textarea>/gi;
    my $sFile = param('file');
    use Fcntl qw(:flock);
    use Symbol;
    my $fh = gensym();
    unless (-d $sFile) {
        open $fh, ">$sFile.bak" or warn "files.pl::saveFile $/ $! $/ $sFile $/";
        flock $fh, 2;
        seek $fh, 0, 0;
        truncate $fh, 0;
        print $fh $txt;
        close $fh;
        rename "$sFile.bak", $sFile or warn "files.pl::saveFile $/ $! $/" if (-e "$sFile.bak");
        chmod(0755, $sFile) if ($sFile =~ ?\.pl?);
        showDir();
    } elsif (defined param('title') && defined param('file')) {
        my $sf = param('file') . '/' . param('title');
        open $fh, ">$sf.bak" or warn "files.pl::saveFile $/ $! $/ $sf $/";
        flock $fh, 2;
        seek $fh, 0, 0;
        truncate $fh, 0;
        print $fh $txt;
        close $fh;
        rename "$sf.bak", $sf or warn "files.pl::saveFile $/ $! $/" if (-e "$sf.bak");
        showDir();
    }
}

sub showEditor
{
    my $h  = shift;
    my $t  = shift;
    my $a  = shift;
    my $fi = shift;

    my %parameter = (
                     path   => $m_hrSettings->{cgi}{bin} . '/templates',
                     style  => $m_sStyle,
                     title  => "",
                     server => $m_hrSettings->{serverName},
                     id     => 'showEditor',
                     class  => 'min',
    );
    my $window = new HTML::Window(\%parameter);
    $m_sContent .= br() . $window->windowHeader();
    $m_sContent .= qq(
<form action ="$ENV{SCRIPT_NAME}" method="post">
 <table cellspacing="5" cellpadding="0" border="0" align="center" summary="execSql" width="95%">
  <tbody>
   <tr>
      <td>$h</td>
    </tr>
    <tr><td><script language="JavaScript1.5" type="text/javascript">html = 1;bbcode = false;printButtons();</script></td></tr>
    <tr>
      <td>
       <textarea name="txt" id="txt" style="width:100%;height:640px;">$t</textarea>
      </td>
    </tr>
    <tr>
      <td align="right"><input type="submit" value="Save"/>
       <input type="hidden" value="$a" name="action"/>
       <input type="hidden" value="$fi" name="file"/>
      </td>
    </tr>
  </tbody>
</table>
</form>
);
    $m_sContent .= $window->windowFooter();
}

sub newFile
{
    my $d = defined param('dir') ? param('dir') : '';
    my $sFile = param('file');
    unless (-e $sFile) {
        open(IN, ">$d/$sFile") or die $!;
        close IN;
        $m_sContent .= translate('newfileadded') if -e $sFile;
    } else {
        $m_sContent .= translate('fileExists ') if -e $sFile;
    }
    &showDir($d);
}

sub makeDir
{
    my $d     = param('d');
    my $sFile = param('file');
    unless (-d "$sFile/$d") {
        mkdir "$sFile/$d";
        $m_sContent .= translate('newfileadded') if -d $sFile;
    } else {
        $m_sContent .= translate('fileExists');
    }
    &showDir($sFile);
}

sub chownFile
{
   my $user = param('user');
   my $uid = getpwnam($user);
   my $gid  = param('gid');
   my $g = getgrnam($gid);
   my $sFile = param('file');
   use POSIX qw(sysconf _PC_CHOWN_RESTRICTED);
   $can_chown_giveaway = not sysconf(_PC_CHOWN_RESTRICTED);
   $m_sContent .= "Not allowed" unless $can_chown_giveaway;
   my $cnt = chown  $uid, $g, $sFile ;
   $m_sContent .= "Ok" if $cnt > 0;
    my $d = $sFile =~ ?^(.*)/[^/]+$? ? $1 : $m_hrSettings->{cgi}{bin};
    &showDir($d);
}

sub chmodFile
{
    my $chmod = param('chmod');
    my $sFile = param('file');
    chmod oct($chmod), $sFile if $chmod =~ /\d\d\d\d/ && -e $sFile;
    my $d = $sFile =~ ?^(.*)/[^/]+$? ? $1 : $m_hrSettings->{cgi}{bin};
    &showDir($d);
}

sub deleteFile
{
    my $sFile = param('file');
    unlink $sFile if -e $sFile;
    rmdir $sFile  if -d $sFile;
    my $d = $sFile =~ ?^(.*)/[^/]+$? ? $1 : $m_hrSettings->{cgi}{bin};
    &showDir($d);
}


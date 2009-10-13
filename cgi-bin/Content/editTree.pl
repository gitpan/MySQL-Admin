use vars qw($m_sDump $m_sPdmp $m_sJs %m_hTempNode $m_hrTempNode $m_nRid %m_hWindowParameter $m_oWindow $m_nPrid );
no warnings "uninitialized";
$m_sPdmp = param('dump') ? param('dump') : 'navigation';
$m_sDump = $m_hrSettings->{tree}{$m_sPdmp};
$m_nPrid = param('rid');
$m_sDump = $m_hrSettings->{tree}{$m_sPdmp};
$m_nPrid = param('rid');
$m_nPrid =~ s/^a(.*)/$1/;
$m_sJs = qq|
<script language="JavaScript" >
var m_bOver = true;
function prepareMove(id){
       dragobjekt = document.getElementById(id);
       dragX = posX - dragobjekt.offsetLeft;
       dragY = posY - dragobjekt.offsetTop;
       dropenabled = true;
       m_bOver = false;
       var o = getElementPosition(id);
       move(id,o.x+25,o.y+25);
       startdrag(id);
}
function enableDropZone(id){
       if(!dragobjekt) return;
       dropzone = id;
       if(dragobjekt.id != dropzone) document.getElementById(id).className = "dropzone"+size;
}
function disableDropZone(id){
         document.getElementById(id).className = "treeviewlink"+size;
}
function confirmMove(){

  if(dropzone && dragobjekt.id != dropzone){
  var url = "$ENV{SCRIPT_NAME}?action=MoveTreeViewEntry&dump=$m_sPdmp&from="+document.getElementById(dropid).id+"&to="+document.getElementById(dropzone).id+"#"+document.getElementById(dropzone).id;
        var move = confirm("hierher verschieben ?");
        if(move){
          location.href =url;
        }else{
          dragobjekt.style.position ="";
          dropenabled = false;
          dragobjekt.className = "treeviewlink";
          dragobjekt = null;
        }
   }

  m_bOver = true;
}
if (typeof document.body.onselectstart!="undefined") //ie
        document.body.onselectstart=function(){return false};
else if (typeof document.body.style.MozUserSelect!="undefined") //gecko
        document.body.style.MozUserSelect="none";
else //Opera
        document.body.onmousedown=function(){return false}

document.body.style.cursor = "default";

</script>
|;
$m_hrTempNode = \%m_hTempNode;
%m_hWindowParameter = (
                       path   => $m_hrSettings->{cgi}{bin} . '/templates',
                       style  => $m_sStyle,
                       title  => " ",
                       server => $m_hrSettings->{serverName},
                       id     => 'editTree',
                       class  => 'min',
);
$m_oWindow = new HTML::Window(\%m_hWindowParameter);

sub linkseditTreeview
{
    $m_sPdmp = 'links';
    $m_sDump = $m_hrSettings->{tree}{'links'};
    editTreeview();
}

sub newTreeviewEntry
{
    $m_sPdmp = param('dump') ? param('dump') : 'navigation';
    $m_sDump = $m_hrSettings->{tree}{$m_sPdmp};
    &newEntry();
}

sub saveTreeviewEntry
{
    &load();
    &saveEntry(\@m_aTree, $m_nPrid);
    _Tree();
}

sub addTreeviewEntry
{
    &load();
    &addEntry(\@m_aTree, $m_nPrid);
    _Tree();
}

sub editTreeview
{
    &load();
    &rid();
    saveTree($m_sDump, \@m_aTree);
    _Tree();
}

sub _Tree
{
    &updateTree(\@m_aTree);
    TrOver(1);
    $m_sContent .= br() . $m_oWindow->windowHeader();

    $m_sContent .=
qq(<form action="$ENV{SCRIPT_NAME}" method="POST" enctype="multipart/form-data"><input type="hidden" name="action" value="deleteTreeviewEntrys"/><input type="hidden" name="dump" value="$m_sPdmp"/><table align="center" border="0" cellpadding="0"  cellspacing="0" summary="layout"  ><tr><td>);

    $m_sContent .= table(
                         {
                          align => 'center',
                          width => '*'
                         },
                         Tr(td($m_sJs)),
                         Tr(td(Tree(\@m_aTree)))
    );
    my $delete   = translate('delete');
    my $mmark    = translate('selected');
    my $markAll  = translate('select_all');
    my $umarkAll = translate('unselect_all');
    my $rebuild  = translate('rebuild');
    $m_sContent .=
qq{</tr><tr><td><table align="center" border="0" cellpadding="0"  cellspacing="0" summary="layout" width="100%" ><tr><td style="padding-left:18px;"><a id="markAll" href="javascript:markInput(true);" class="links">$markAll</a><a class="links" id="umarkAll" style="display:none;" href="javascript:markInput(false);">$umarkAll</a></td><td align="right"><select  name="MultipleRebuild"  onchange="if(this.value != '$mmark' )this.form.submit();"><option  value="$mmark" selected="selected">$mmark</option><option value="delete">$delete</option></select></td></tr></table></td></tr></table>};
    $m_sContent .= $m_oWindow->windowFooter();
    TrOver(0);
}

sub editTreeviewEntry
{
    &load();
    &editEntry(\@m_aTree, $m_nPrid);
}

sub deleteTreeviewEntry
{
    &load();
    &deleteEntry(\@m_aTree, $m_nPrid);
    _Tree();
}

sub upEntry
{
    &load();
    &sortUp(\@m_aTree, $m_nPrid);
    _Tree();
}

sub MoveTreeViewEntry
{
    &load();
    my $from = param('from');
    $from =~ s/^a(\d+)/$1/;
    my $to = param('to');
    $to =~ s/^a(\d+)/$1/;
    &getEntry(\@m_aTree, $from, $to);
    &rid();
    saveTree($m_sDump, \@m_aTree);
    _Tree();
}

sub moveEntry
{
    my $t    = shift;
    my $find = shift;
    for (my $i = 0; $i <= @$t; $i++) {
        next if ref @$t[$i] ne "HASH";
        if (@$t[$i]) {
            if (@$t[$i]->{rid} eq $find && defined $m_hrTempNode->{id}) {
                splice @$t, $i, 0, $m_hrTempNode;
                return 1;
            }
            if (defined @{@$t[$i]->{subtree}}) {
                moveEntry(\@{@$t[$i]->{subtree}}, $find);
            }
        }
    }
}

sub getEntry
{
    my $t    = shift;
    my $find = shift;
    my $goto = shift;
    for (my $i = 0; $i < @$t; $i++) {
        next if ref @$t[$i] ne "HASH";
        if (@$t[$i]->{rid} eq $find) {
            $m_hrTempNode->{$_} = @$t[$i]->{$_} foreach keys %{@$t[$i]};
            splice @$t, $i, 1;
            moveEntry(\@m_aTree, $goto);
        } elsif (defined @{@$t[$i]->{subtree}}) {
            getEntry(\@{@$t[$i]->{subtree}}, $find, $goto);
        }
    }
}

sub downEntry
{
    &load();
    $down = 1;
    &sortUp(\@m_aTree, $m_nPrid);
    &updateTree(\@m_aTree);
    _Tree();
}

sub newEntry
{
    $m_sContent .= br() . $m_oWindow->windowHeader();
    my $value = param('title') ? param('title') : '';
    my $push = '';

    if (param('addBookMark')) {
        &load();
        &rid();
        saveTree($m_sDump, \@m_aTree);
        $m_nPrid = $m_nRid;
        $push    = '<input type="hidden" name="addBookMark" value="addBookMark"/>';
    }
    my $new = translate('newEntry');
    $m_sContent .=
qq(<b>$new</b><form action="$ENV{SCRIPT_NAME}#a$m_nPrid"><input type="hidden" name="rid" value="a$m_nPrid"/>$push<br/><table align="center" class="mainborder" cellpadding="2"  cellspacing="2" summary="mainLayolut"><tr><td>Text:</td><td><input type="text" value="$value" name="text"></td></tr><tr><td>Folder</td><td><input type="checkbox" name="folder" /></td></tr>);
    language('de') if $ACCEPT_LANGUAGE eq 'de';
    my $node = help();
    $m_sContent .= qq(<tr><td>right :</td><td><input type="text" value="$node->{right}" name="right" /></td></tr>);
    foreach my $key (sort(keys %{$node})) {
        $value = "";
        $value = param('addBookMark') if ($key eq 'href' && param('addBookMark'));
        $value = param('title') if ($key eq 'title' && param('title'));
        $value = 'a' . $m_nPrid if ($key eq 'id' && param('addBookMark'));
        $m_sContent .= qq(<tr><td></td><td>$node->{$key}</td></tr><tr><td>$key :</td><td><input type="text" value="$value" name="$key" id="$key"/><br/></td></tr>) if ($key ne 'class');
    }
    $m_sContent .= qq|<tr><td><input type="hidden" name="action" value="addTreeviewEntry"/><input type="hidden" name="dump" value="$m_sPdmp"/></td><td><input type="submit"/></td></tr></table></form>|;

    $m_sContent .= $m_oWindow->windowFooter();
}

sub addEntry
{
    my $t    = shift;
    my $find = shift;
 
    for (my $i = 0; $i < @$t; $i++) {
        if (@$t[$i]->{rid} eq $find) {
            my %params = Vars();
            my $node   = {};
            foreach my $key (sort(keys %params)) {
                $node->{$key} = $params{$key} if ($params{$key} && $key ne 'action' && $key ne 'folder' && $key ne 'subtree' && $key ne 'class' && $key ne 'dump');
                $node->{$key} = (
                                 $m_hrSettings->{cgi}{mod_rewrite}
                                 ? "/$1.html"
                                 : "$ENV{SCRIPT_NAME}?action=$1"
                ) if ($key eq 'href' && $params{$key} =~ /^action:\/\/(.*)$/);
            }
            if (param('folder')) {
                $node->{'subtree'} = [{text => 'Empty Folder',}];
            }
           if (param('addBookMark')) {
                unless($node->{'text'} eq $m_aTree[$#m_aTree]->{'text'}){
                push @$t, $node;
      &rid();
saveTree($m_sDump, \@m_aTree);
                return;
              }
            }
            splice @$t, $i, 0, $node;
           
            &rid();
            saveTree($m_sDump, \@m_aTree);
            return;
        } elsif (defined @{@$t[$i]->{subtree}}) {
            &addEntry(\@{@$t[$i]->{subtree}}, $find);
        }
    }
}

sub saveEntry
{
    my $t    = shift;
    my $find = shift;
    for (my $i = 0; $i < @$t; $i++) {
        if (@$t[$i]->{rid} eq $find) {
            my %params = Vars();
            foreach my $key (sort keys %params) {
                @$t[$i]->{$key} = $params{$key} if ($key ne 'action' && $key ne 'folder' && $key ne 'subtree' && $key ne 'class' && $key ne 'dump');
                @$t[$i]->{$key} = (
                                   $m_hrSettings->{cgi}{mod_rewrite}
                                   ? "/$1.html"
                                   : "$ENV{SCRIPT_NAME}?action=$1"
                ) if ($key eq 'href' && $params{$key} =~ /^action:\/\/(.*)$/);
            }
            saveTree($m_sDump, \@m_aTree);
            return;
        } elsif (defined @{@$t[$i]->{subtree}}) {
            &saveEntry(\@{@$t[$i]->{subtree}}, $find);
        }
    }
}

sub editEntry
{
    my $t    = shift;
    my $find = shift;
    my $href = "$ENV{SCRIPT_NAME}?action=editTreeviewEntry&dump=$m_sPdmp";
    language('de') if $ACCEPT_LANGUAGE eq 'de';
    my $node = help();
    for (my $i = 0; $i < @$t; $i++) {
        if (@$t[$i]->{rid} eq $find) {
            $m_sContent .= br() . $m_oWindow->windowHeader();
            $m_sContent .= "<b>" . @$t[$i]->{text} . '</b><form action="' . $href . "#a$m_nPrid" . '"><table align=" center " class=" mainborder " cellpadding="0"  cellspacing="0" summary="mainLayolut">';
            $m_sContent .= qq(<tr><td>right :</td><td><input type="text" value="@$t[$i]->{right}" name="right" /></td></tr>);
            foreach my $key (sort(keys %{@$t[$i]})) {
                $m_sContent .= "<tr><td></td><td>$node->{$key}</td></tr>" if (defined $node->{$key});
                $m_sContent .= qq(<tr><td>$key </td><td><input type="text" value="@$t[$i]->{$key}" name="$key"></td></tr>)
                  if ($key ne 'subtree' && $key ne 'rid' && $key ne 'action' && $key ne 'dump' && $key ne 'class' && $key ne 'addition' && $key ne 'right');
            }
            foreach my $key2 (sort(keys %{$node})) {
                unless (defined @$t[$i]->{$key2}) {
                    $m_sContent .= qq(<tr><td></td><td>$node->{$key2}</td></tr><tr><td>$key2 :</td><td><input type="text" value="" name="$key2"/><br/></td></tr>);
                }
            }
            $m_sContent .= qq(
            <tr><td><input type="hidden" name="action" value="saveTreeviewEntry"/><input type="hidden" name="rid" value="@$t[$i]->{rid}"/><input type="hidden" name="dump" value="$m_sPdmp"/></td><td><input type="submit" value="save"/></td></tr></table></form>);
            $m_sContent .= $m_oWindow->windowFooter();
            saveTree($m_sDump, \@m_aTree);
            return;
        } elsif (defined @{@$t[$i]->{subtree}}) {
            &editEntry(\@{@$t[$i]->{subtree}}, $find);
        }
    }
}

sub sortUp
{
    my $t    = shift;
    my $find = shift;
    for (my $i = 0; $i <= @$t; $i++) {
        if (defined @$t[$i]) {
            if (@$t[$i]->{rid} eq $find) {
                $i++ if ($down);
                return if (($down && $i eq @$t) or (!$down && $i eq 0));
                splice @$t, $i - 1, 2, (@$t[$i], @$t[$i - 1]);
                saveTree($m_sDump, \@m_aTree);
            }
            if (defined @{@$t[$i]->{subtree}}) {
                sortUp(\@{@$t[$i]->{subtree}}, $find);
                saveTree($m_sDump, \@m_aTree);
            }
        }
    }
}

sub deleteEntry
{
    my $t    = shift;
    my $find = shift;
    for (my $i = 0; $i < @$t; $i++) {
        if (@$t[$i]->{rid} eq $find) {
            splice @$t, $i, 1;
            saveTree($m_sDump, \@m_aTree);
        } elsif (defined @{@$t[$i]->{subtree}}) {
            deleteEntry(\@{@$t[$i]->{subtree}}, $find);
        }
    }
}

sub updateTree
{
    my $t = shift;
    for (my $i = 0; $i < @$t; $i++) {
        if (defined @$t[$i]) {
            @$t[$i]->{onmouseup}   = "confirmMove()";
            @$t[$i]->{id}          = @$t[$i]->{id};
            @$t[$i]->{name}        = @$t[$i]->{id};
            @$t[$i]->{onmousedown} = "prepareMove('" . @$t[$i]->{id} . "')";
            @$t[$i]->{onmousemove} = "enableDropZone('" . @$t[$i]->{id} . "')";
            @$t[$i]->{onmouseout}  = "disableDropZone('" . @$t[$i]->{id} . "')";
            my $nPrevId = 'a' . (@$t[$i]->{rid} - 1);
            @$t[$i]->{addition} = qq|<table border="0" cellpadding="0" cellspacing="0" align="right" summary="layout"><tr>
<td><a class="treeviewLink$m_nSize" target="_blank" title="@$t[$i]->{text}" href="@$t[$i]->{href}"><img src="/style/$m_sStyle/$m_nSize/mimetypes/www.png" border="0" alt=""></a></td>
<td><a class="treeviewLink$m_nSize" href="$ENV{SCRIPT_NAME}?action=editTreeviewEntry&dump=$m_sPdmp&rid=@$t[$i]->{rid}#@$t[$i]->{id}"><img src="/style/$m_sStyle/$m_nSize/mimetypes/edit.png" border="0" alt="edit"></a></td><td><a class="treeviewLink$m_nSize" href="$ENV{SCRIPT_NAME}?action=deleteTreeviewEntry&dump=$m_sPdmp&rid=@$t[$i]->{rid}#$nPrevId" onclick="if( confirm('Delete ?')){return true;}else{return false;}"><img src="/style/$m_sStyle/$m_nSize/mimetypes/editdelete.png" border="0" alt="delete"></a></td><td><a class="treeviewLink$m_nSize" href="$ENV{SCRIPT_NAME}?action=upEntry&dump=$m_sPdmp&rid=@$t[$i]->{rid}#@$t[$i]->{id}"><img src="/style/$m_sStyle/$m_nSize/mimetypes/up.png" border="0" alt="up"></a></td><td><a class="treeviewLink$m_nSize" href="$ENV{SCRIPT_NAME}?action=downEntry&dump=$m_sPdmp&rid=@$t[$i]->{rid}#@$t[$i]->{id}"><img src="/style/$m_sStyle/$m_nSize/mimetypes/down.png" border="0" alt="down"></a></td><td><a class="treeviewLink$m_nSize" href="$ENV{SCRIPT_NAME}?action=newTreeviewEntry&dump=$m_sPdmp&rid=@$t[$i]->{rid}"><img src="/style/$m_sStyle/$m_nSize/mimetypes/filenew.png" border="0" alt="new"></a></td><td><input type="checkbox" name="markBox$i" class="markBox" value="@$t[$i]->{rid}" /></td></tr></table>|;
            @$t[$i]->{href} = '';
            updateTree(\@{@$t[$i]->{subtree}}) if (defined @{@$t[$i]->{subtree}});

            #             }
        }
    }
}

sub rid
{
    no warnings;
    $m_nRid = 0;
    &getRid(\@m_aTree);

    sub getRid
    {
        my $t = shift;
        for (my $i = 0; $i < @$t; $i++) {
            $m_nRid++;
            next unless ref @$t[$i] eq "HASH";
            @$t[$i]->{rid} = $m_nRid;
            @$t[$i]->{id}  = "a$m_nRid";
            getRid(\@{@$t[$i]->{subtree}}) if (defined @{@$t[$i]->{subtree}});
        }
    }
}

sub load
{

    if (-e $m_sDump) {
        loadTree($m_sDump);
        *m_aTree = \@{$HTML::Menu::TreeView::TreeView[0]};
    }
}

sub deleteTreeviewEntrys
{
    &load();
    my @params = param();

    for (my $i = 0; $i <= $#params; $i++) {
        if ($params[$i] =~ /markBox\d?/) {

            my $id = param($params[$i]);
            &deleteEntry(\@m_aTree, $id);

        }
    }

    editTreeview();
}
1;

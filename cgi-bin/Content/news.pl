use vars qw( $m_sAkt $m_nLength $m_nReplyId );

sub show
{
    my $threadlength = $m_oDatabase->tableLength('news');
    my $lpp =
        defined param('links_pro_page')
      ? param('links_pro_page') =~ /(\d\d?\d?)/
          ? $1
          : $m_hrSettings->{news}{messages}
      : $m_hrSettings->{news}{messages};
    $m_nStart = $m_nStart >= $threadlength       ? $threadlength - $lpp : $m_nStart;
    $m_nEnd   = $m_nStart + $lpp > $threadlength ? $threadlength        : $m_nStart + $lpp;
    my %needed = (
                  action => 'news',
                  start  => $m_nStart,
                  end    => $m_nEnd,
                  thread => 'news',
                  id     => 'c',
    );
    $m_sContent .= showThread(\%needed);
    my $catlist = readcats('news');
    my %parameter = (
                     action => 'addNews',
                     body   => translate('body'),
                     class  => 'max',
                     attach => $m_nRight >= $m_hrSettings->{uploads}{right}
                     ? $m_hrSettings->{uploads}{enabled}
                     : 0,
                     maxlength => $m_hrSettings->{news}{maxlength},
                     path      => "$m_hrSettings->{cgi}{bin}/templates",
                     reply     => 'none',
                     server    => $m_hrSettings->{cgi}{serverName},
                     style     => $m_sStyle,
                     thread    => 'news',
                     headline  => translate('headline'),
                     title     => translate('newMessage'),
                     catlist   => $catlist,
                     right     => $m_nRight,
                     html      => 0,
                     atemp     => qq(<input  name="von" value="$m_nStart" style="display:none;"/><input  name="bis" value="$m_nEnd" style="display:none;"/>),
    );

    my $editor = new HTML::Editor(\%parameter);
    $m_sContent .= '<div align="center">';
    $m_sContent .= $editor->show() if ($m_nRight >= $m_hrSettings->{news}{right});
    $m_sContent .= '</div>';
}

sub showEditor
{
    my $catlist = readcats('news');
    my %parameter = (
                     action => 'addNews',
                     body   => translate('body'),
                     class  => 'max',
                     attach => $m_nRight >= $m_hrSettings->{uploads}{right}
                     ? $m_hrSettings->{uploads}{enabled}
                     : 0,
                     maxlength => $m_hrSettings->{news}{maxlength},
                     path      => "$m_hrSettings->{cgi}{bin}/templates",
                     reply     => 'none',
                     server    => $m_hrSettings->{cgi}{serverName},
                     style     => $m_sStyle,
                     thread    => 'news',
                     headline  => translate('headline'),
                     title     => translate('newMessage'),
                     catlist   => $catlist,
                     right     => $m_nRight,
                     html      => 0,
                     template  => "enlargedEditor.htm",
    );
    my $editor = new HTML::Editor(\%parameter);
    $m_sContent .= '<div align="center">';
    $m_sContent .= $editor->show() if ($m_nRight >= $m_hrSettings->{news}{right});
    $m_sContent .= '</div>';
}

sub addNews
{
    my $sbm = param('submit') ? param('submit') : 'save';
    if (not defined $sbm or ($sbm ne translate('preview'))) {
        if (defined param('message') && defined param('headline') && defined param('thread') && defined param('catlist')) {
            my $message = param('message');
            my $max = $m_hrSettings->{news}{maxlength} < 32766 ? $m_hrSettings->{news}{maxlength} : 0;
            $message = ($message =~ /^(.{3,$max})$/s) ? $1 : translate('invalidBody') if $max > 0;
            my $headline = param('headline');
            $headline = ($headline =~ /^(.{3,100})$/s) ? $1 : translate('invalidHeadline');
            my $thread = param('thread');
            $thread = ($thread =~ /^(\w+)$/) ? $1 : 'trash';
            my @cat = param('catlist');
            my $cat = join '|', @cat;
            &saveUpload() if $m_nRight >= $m_hrSettings->{uploads}{right};
            my $attach =
                (defined param('file'))
              ? (split(/[\\\/]/, param('file')))[-1]
              : 0;
            my $cit =
                (defined $attach)
              ? $attach =~ /^(\S+)\.[^\.]+$/
                  ? $1
                  : 0
              : 0;
            my $type =
                (defined $attach)
              ? ($attach =~ /\.([^\.]+)$/)
                  ? $1
                  : 0
              : 0;
            $cit =~ s/("|'|\s| )//g;
            my $sra = ($cit && $type) ? "$cit.$type" : undef;
            my $format = param('format') eq 'on' ? 'html' : 'bbcode';

            if (defined $headline && defined $message && defined $thread && $m_nRight >= $m_hrSettings->{news}{right}) {
                my %message = (
                               title  => $headline,
                               body   => $message,
                               thread => $thread,
                               user   => $m_sUser,
                               cat    => $cat,
                               attach => $sra,
                               format => $format,
                               ip     => remote_addr()
                );
                if ($m_oDatabase->addMessage(\%message)) {
                    my $tx = translate('newMessageReleased');
                    $m_sContent .= qq|<div align="center">$tx<br/></div>|;
                } else {
                    $m_sContent .= '<div align="center">' . translate('floodtext') . '<br/></div>';
                }
            }
        }
        &show();
    } else {
        &preview();
    }
}

sub saveedit
{

    if (not defined param('submit') or (param('submit') ne translate('preview'))) {
        my $thread = param('thread');
        $thread = ($thread =~ /^(\w+)$/) ? $1 : 'trash';
        my $id = param('reply');
        $id = ($id =~ /^(\d+)$/) ? $1 : 0;
        my $headline = param('headline');
        $headline = ($headline =~ /^(.{3,50})$/) ? $1 : 0;
        my $body = param('message');
        my $max = $m_hrSettings->{news}{maxlength} < 32766 ? $m_hrSettings->{news}{maxlength} : 0;
        $body = ($body =~ /^(.{3,$max})$/s) ? $1 : translate('invalidBody') if $max > 0;

        &saveUpload() if $m_nRight >= $m_hrSettings->{uploads}{right};
        my $attach = (param('file')) ? (split(/[\\\/]/, param('file')))[-1] : 0;
        my $cit = (defined $attach) ? $attach =~ /^(\S+)\.[^\.]+$/ ? $1 : 0 : 0;
        my $type = (defined $attach) ? ($attach =~ /\.([^\.]+)$/) ? $1 : 0 : 0;
        $cit =~ s/("|'|\s| )//g;
        my $sra = ($cit && $type) ? "$cit.$type" : undef;
        my $format = param('format') eq 'on' ? 'html' : 'bbcode';
        my @cat    = param('catlist');
        my $c      = join '|', @cat;
        my %message = (
                       thread     => $thread,
                       title      => $headline,
                       body       => $body,
                       thread     => $thread,
                       cat        => $c,
                       attach     => $sra,
                       format     => $format,
                       id         => $id,
                       user       => $m_sUser,
                       ip         => remote_addr(),
                       uploadpath => $m_hrSettings->{uploads}{path}
        );
        $m_oDatabase->editMessage(\%message);
        my $rid = $id;

        if ($thread eq 'replies') {
            my @tid = $m_oDatabase->fetch_array("select refererId from  `replies` where id = '$id'");
            $rid = $tid[0];
        }
        &showMessage($rid);
    } else {
        &preview();
    }
}

sub editNews
{
    my $id = param('edit');
    $id = ($id =~ /^(\d+)$/) ? $1 : 0;
    my $th = param('thread');
    $th = ($th =~ /^(\w+)$/) ? $1 : 'news';
    if (not defined param('submit') or (param('submit') ne translate('preview'))) {

        my @data    = $m_oDatabase->fetch_array("select title,body,date,id,user,attach,format,cat from  `$th`  where `id` = '$id'  and  (`user` = '$m_sUser'  or `right` < '$m_nRight' );") if (defined $th);
        my $catlist = readcats($data[7]);
        my $html    = $data[6] eq 'html' ? 1 : 0;
        my %parameter = (
                         action => 'saveedit',
                         body   => $data[1],
                         class  => 'max',
                         attach => $m_nRight >= $m_hrSettings->{uploads}{right}
                         ? $m_hrSettings->{uploads}{enabled}
                         : '',
                         maxlength => $m_hrSettings->{news}{maxlength},
                         path      => "$m_hrSettings->{cgi}{bin}/templates",
                         reply     => $id,
                         server    => $m_hrSettings->{cgi}{serverName},
                         style     => $m_sStyle,
                         thread    => $th,
                         headline  => $data[0],
                         title     => translate('editMessage'),
                         right     => $m_nRight,
                         catlist   => ($th eq 'news') ? $catlist : ' ',
                         html      => $html,
                         atemp     => qq(<input  name="von" value="$m_nStart" style="display:none;"/><input  name="bis" value="$m_nEnd" style="display:none;"/>),
        );
        my $editor = new HTML::Editor(\%parameter);
        $m_sContent .= '<div align="center"><br/>';
        $m_sContent .= $editor->show();
        $m_sContent .= '</div>';
    } else {
        &preview();
    }
    my $rid = $id;
    if ($th eq 'replies') {
        my @tid = $m_oDatabase->fetch_array("select refererId from  `replies` where id = '$id'");
        $rid = $tid[0];
    }
    &showMessage($rid);
}

sub replyNews
{
    my $id = param('reply');
    $id = ($id =~ /^(\d+)$/) ? $1 : 0;
    my $th = param('thread');
    $th = ($th =~ /^(\w+)$/) ? $1 : 'trash';
    my $attachment;
    if ($m_nRight >= $m_hrSettings->{uploads}{right}) {
        $attachment = $m_hrSettings->{uploads}{enabled};
    } else {
        my $captcha = Authen::Captcha->new(
                                           data_folder   => "$m_hrSettings->{cgi}{bin}/config/",
                                           output_folder => "$m_hrSettings->{cgi}{DocumentRoot}/images",
                                           expire        => 300,
        );
        my $md5sum = $captcha->generate_code('3');
        $attachment = qq|<input size="5" type="hidden" name="md5" value="$md5sum"/><div align="center"><img src="/images/$md5sum.png" border="0"/><br/><br/><input size="5"" name="captcha" value=""/></div>|;
    }
    my %parameter = (
                     action    => 'addreply',
                     body      => translate('insertText'),
                     class     => 'max',
                     attach    => $attachment,
                     maxlength => $m_hrSettings->{news}{maxlength},
                     path      => "$m_hrSettings->{cgi}{bin}/templates",
                     reply     => $id,
                     server    => $m_hrSettings->{cgi}{serverName},
                     style     => $m_sStyle,
                     thread    => $th,
                     headline  => translate('headline'),
                     title     => translate('reply'),
                     right     => $m_nRight,
                     catlist   => '',
                     html      => 0,
                     atemp     => qq(<input  name="von" value="$m_nStart" style="display:none;"/><input  name="bis" value="$m_nEnd" style="display:none;"/>),
    );
    my $editor = new HTML::Editor(\%parameter);
    $m_sContent .= '<div align="center"><br/>';
    $m_sContent .= $editor->show();
    $m_sContent .= '</div>';
    &saveUpload() if $m_nRight >= $m_hrSettings->{uploads}{right};
    &showMessage($id);
}

sub addReply
{
    my $body     = param('message');
    my $headline = param('headline');
    my $reply    = param('reply');
    my $format   = 'bbcode';
    if (defined param('format')) {
        $format = 'html' if param('format') eq 'on';
    }
    my $result = 0;
    if ($m_nRight < $m_hrSettings->{uploads}{right}) {
        my $captcha = Authen::Captcha->new(data_folder   => "$m_hrSettings->{cgi}{bin}/config/",
                                           output_folder => "$m_hrSettings->{cgi}{DocumentRoot}/images");
        $result = $captcha->check_code(param('captcha'), param('md5'));
    } else {
        $result = 1;
    }
    $m_sContent .= div({align => 'center'}, translate('Code not checked (file error)')) if $result eq 0;
    $m_sContent .= div({align => 'center'}, translate('Failed: code expired'))          if $result eq -1;
    $m_sContent .= div({align => 'center'}, translate('Failed: not in database'))       if $result eq -2;
    $m_sContent .= div({align => 'center'}, translate('Failed: invalid code'))          if $result eq -3;
    my $submit = param('submit') ? param('submit') : 'save';
    if ($submit ne translate("preview") && $result >= 1) {
        if (param('file')) {
            my $attach = (split(/[\\\/]/, param('file')))[-1];
            my $cit = $attach =~ /^(\S+)\.[^\.]+$/ ? $1 : 0;
            my $type = ($attach =~ /\.([^\.]+)$/) ? $1 : 0;
            $cit =~ s/("|'|\s| )//g;
            my $sra = "$cit.$type";
            my %reply = (
                         title  => $headline,
                         body   => $body,
                         id     => $reply,
                         user   => $m_sUser,
                         attach => $sra,
                         format => $format,
            );
            $m_oDatabase->reply(\%reply);
        } else {
            my %reply = (
                         title  => $headline,
                         body   => $body,
                         id     => $reply,
                         user   => $m_sUser,
                         format => $format,
                         ip     => remote_addr()
            );
            $m_oDatabase->reply(\%reply);
        }
        &saveUpload() if $m_nRight >= $m_hrSettings->{uploads}{right};
    } else {

        &preview();
    }
    &showMessage($reply);
}

sub deleteNews
{
    my $th = param('thread');
    $th = ($th =~ /^(\w+)$/) ? $1 : 'trash';
    my $del = param('delete');
    $del = ($del =~ /^(\d+)$/) ? $1 : 0;
    if ($th eq 'replies') {
        my @tid = $m_oDatabase->fetch_array("select refererId from  `replies` where id = ?", $del);
        $m_oDatabase->deleteMessage($th, $del);
        &showMessage($tid[0]);
    } else {
        $m_oDatabase->deleteMessage($th, $del);
        my @a_id = $m_oDatabase->fetch_array("select id from  `replies` where refererId = ?", $del);
        foreach my $id (@a_id) {
            $m_oDatabase->deleteMessage('replies', $del);
        }
        &show();
    }
}

sub showMessage
{
    my $id = $_[0] ? shift : defined param('reply') && param('reply') =~ /(\d+)/ ? $1 : 0;
    my $qcats = $m_oDatabase->fetch_string("SELECT cats FROM users where user = ?", $m_sUser);
    $qcats = $m_oDatabase->quote($qcats);
    my $sql_read = qq/select title,body,date,id,user,attach,format from  news where `id` = $id && `right` <= $m_nRight && cat REGEXP($qcats)/;
    my $ref      = $m_oDatabase->fetch_hashref($sql_read);

    if ($ref->{id} eq $id) {
        my $m_sTitle = $ref->{title};
        my %parameter = (
                         path   => $m_hrSettings->{cgi}{bin} . '/templates',
                         style  => $m_sStyle,
                         title  => qq(<div style="white-space:nowrap">$m_sTitle</div>),
                         server => $m_hrSettings->{cgi}{serverName},
                         id     => "n$id",
                         class  => 'min',
        );
        my $window = new HTML::Window(\%parameter);
        $window->set_closeable(0);
        $window->set_moveable(1);
        $window->set_resizeable(1);
        $ref->{body} =~ s/\[previewende\]//s;
        BBCODE(\$ref->{body}, $ACCEPT_LANGUAGE) if ($ref->{format} eq 'bbcode');
        my $menu = "";
        my $answerlink = $m_hrSettings->{cgi}{mod_rewrite} ? "/replynews-$ref->{id}.html" : "$ENV{SCRIPT_NAME}?action=reply&amp;reply=$ref->{id}&amp;thread=news";
        my %reply = (
                     title    => translate('reply'),
                     descr    => translate('reply'),
                     src      => 'reply.png',
                     location => $answerlink,
                     style    => $m_sStyle,
        );
        my $thread = defined param('thread') ? param('thread') : 'news';
        $menu .= action(\%reply) unless ($thread =~ /.*\d$/ && $m_nRight < 5);
        my $editlink =
          $m_hrSettings->{cgi}{mod_rewrite}
          ? "/edit$thread-$ref->{id}.html"
          : "$ENV{SCRIPT_NAME}?action=edit&amp;edit=$ref->{id}&amp;thread=news&amp;von=$m_nStart&amp;bis=$m_nEnd;";
        my %edit = (
                    title    => translate('edit'),
                    descr    => translate('edit'),
                    src      => 'edit.png',
                    location => $editlink,
                    style    => $m_sStyle,
        );
        $menu .= action(\%edit) if ($m_nRight >= 5);
        my $trdelete = translate('delete');
        my $deletelink =
          $m_hrSettings->{cgi}{mod_rewrite}
          ? "javascript:if(confirm('$trdelete ?')) location.href='/delete.html&amp;delete=$ref->{id}&amp;thread=news&amp;von=$m_nStart&amp;bis=$m_nEnd;'"
          : "javascript:if(confirm('$trdelete ?')) location.href='$ENV{SCRIPT_NAME}?action=delete&amp;delete=$ref->{id}&amp;thread=news&amp;von=$m_nStart&amp;bis=$m_nEnd;'";
        my %delete = (
                      title    => translate('delete'),
                      descr    => translate('delete'),
                      src      => 'delete.png',
                      location => $deletelink,
                      style    => $m_sStyle,
        );
        $menu .= action(\%delete) if ($m_nRight >= 5);
        $m_sContent .=
            br()
          . $window->windowHeader()
          . qq(<table align="left" border ="0" cellpadding="0" cellspacing="0" summary ="0"  width="100%"><tr ><td align='left'>$menu</td></tr><tr ><td align='left'><table align="left" border ="0" cellpadding="0" cellspacing="0" summary="user_datum"  width="100%"><tr><td align="left">$ref->{user}</td><td align="right">$ref->{date}</td></tr></table></td></tr><tr><td align='left'>$ref->{body}</td></tr>);
        $m_sContent .= qq(<tr><td><a href="/downloads/$ref->{attach}">$ref->{attach}</a></td></tr>) if (-e "$m_hrSettings->{uploads}{path}/$ref->{attach}");

        $m_sContent .= "</table>" . $window->windowFooter();
        my @rps = $m_oDatabase->fetch_array("select count(*) from replies where refererId = ?;", $id);

        if ($rps[0] > 0) {
            $m_nStart = $m_nStart > $rps[0] ? $rps[0] - 1 : $m_nStart;
            my %needed = (
                          action  => 'showthread',
                          start   => $m_nStart,
                          end     => $m_nEnd,
                          thread  => 'replies',
                          replyId => $id,
                          id      => 'c',
            );
            $m_sContent .= showThread(\%needed);
        }
    } else {
        &show();
    }
}

# privat
sub readcats
{
    my $selected = lc(shift);
    my @select = split /\|/, $selected;
    my %sel;
    $sel{$_} = 1 foreach @select;
    my @cats = $m_oDatabase->fetch_AoH("select * from cats where `right` <= ?", $m_nRight);
    my $cats = translate('catslist');
    my $list =
qq|<a id="catLink" class="catLink" onclick="var o =  getElementPosition('catLink');move('catlist',o.x,o.y+20);displayTree('catlist');var e =document.getElementById('catLink');e.className = (e.className == 'catLink') ? 'catLinkPressed' :'catLink';">$cats</a><select id="catlist" name="catlist" size="5" multiple="multiple" style="display:none;position:absolute;">|;
    for (my $i = 0; $i <= $#cats; $i++) {
        my $catname = lc($cats[$i]->{name});
        $list .=
          $sel{$catname}
          ? qq(<option value="$catname"  selected="selected">$catname</option>)
          : qq(<option value="$catname">$catname</option>);
    }
    $list .= '</select>';
    return $list;
}

sub preview
{
    my $thread = param('thread');
    $thread = ($thread =~ /^(\w+)$/) ? $1 : 'trash';
    my $id = param('reply');
    $id = ($id =~ /^(\d+)$/) ? $1 : 0;
    my $headline = param('headline');
    $headline = ($headline =~ /^(.{3,50})$/) ? $1 : 0;
    my $body    = param('message');
    my @cat     = param('catlist');
    my $cat     = join '|', @cat;
    my $catlist = $m_sAction ne 'addreply' ? readcats($cat) : ' ';
    my %wparameter = (
                      path   => "$m_hrSettings->{cgi}{bin}/templates",
                      style  => $m_sStyle,
                      title  => $headline,
                      server => $m_hrSettings->{cgi}{serverName},
                      id     => "previewWindow",
                      class  => "min",
    );
    my $win = new HTML::Window(\%wparameter);
    $win->set_closeable(1);
    $win->set_collapse(1);
    $win->set_moveable(1);
    $win->set_resizeable(1);
    $m_sContent .= "<br/>";
    $m_sContent .= $win->windowHeader();
    my $html = defined param('format') ? param('format') : 'off';
    $html = $html eq 'on' ? 1 : 0;
    BBCODE(\$body, $ACCEPT_LANGUAGE) unless ($html);
    $m_sContent .= qq(<table align="left" border ="0" cellpadding="0" cellspacing="0" summary ="0"  width="100%"><tr ><td align="left">$body</td></tr></table>);
    $m_sContent .= $win->windowFooter();
    my $attachment;

    if ($m_nRight >= $m_hrSettings->{uploads}{right}) {
        $attachment = $m_hrSettings->{uploads}{enabled};
    } else {
        my $captcha = Authen::Captcha->new(
                                           data_folder   => "$m_hrSettings->{cgi}{bin}/config/",
                                           output_folder => "$m_hrSettings->{cgi}{DocumentRoot}/images",
                                           expire        => 300,
        );
        my $md5sum = $captcha->generate_code('3');
        $attachment = qq|<input size="5" type="hidden" name="md5" value="$md5sum"/><div align="center"><img src="/images/$md5sum.png" border="0"/><br/><br/><input size="5"" name="captcha" value=""/></div>|;
    }

    my %parameter = (
                     action    => $m_sAction,
                     body      => param('message'),
                     class     => 'max',
                     attach    => $attachment,
                     maxlength => $m_hrSettings->{news}{maxlength},
                     path      => "$m_hrSettings->{cgi}{bin}/templates",
                     reply     => $id,
                     server    => $m_hrSettings->{cgi}{serverName},
                     style     => $m_sStyle,
                     thread    => $thread,
                     headline  => $headline,
                     title     => translate("editMessage"),
                     right     => $m_nRight,
                     catlist   => ($thread eq 'news') ? $catlist : ' ',
                     html      => $html,
                     template  => 'enlargedEditor.htm',
                     atemp     => qq(<input  name="von" value="$m_nStart" style="display:none;"/><input  name="bis" value="$m_nEnd" style="display:none;"/>),
    );
    my $editor = new HTML::Editor(\%parameter);
    $m_sContent .= '<div align="center"><br/>';
    $m_sContent .= $editor->show();
    $m_sContent .= '</div>';
}

sub showThread
{
    my $needed = shift;
    $m_sAkt     = $needed->{action};
    $m_nEnd     = $needed->{end};
    $m_nStart   = $needed->{start};
    $thread     = $needed->{thread};
    $m_nReplyId = $needed->{replyId};
    $replylink  = defined $m_nReplyId ? "&amp;reply=$m_nReplyId" : ' ';
    my $qcats = $m_oDatabase->fetch_string("SELECT cats FROM users where user = ?", $m_sUser);
    $qcats = $m_oDatabase->quote($qcats);
    my @rp = $m_oDatabase->fetch_array("select count(*) from news where `right` <= $m_nRight && cat REGEXP($qcats)");
    $m_nLength = $rp[0] =~ /(\d+)/ ? $rp[0] : 0 unless ($thread eq 'replies');

    if (defined $needed->{replyId}) {
        my @rps = $m_oDatabase->fetch_array("select count(*) from replies where refererId = $needed->{replyId};");
        if   ($rps[0] > 0) {$m_nLength = $rps[0];}
        else               {$m_nLength = 0;}
    }
    $m_nLength = 0 unless (defined $m_nLength);
    my $lpp =
        defined param('links_pro_page')
      ? param('links_pro_page') =~ /(\d\d?\d?)/
          ? $1
          : $m_hrSettings->{news}{messages}
      : $m_hrSettings->{news}{messages};
    my $itht = '<table align="center" border ="0" cellpadding ="0" cellspacing="0" summary="showThread" width="100%" >';
    $itht .= Tr(
                td(
                   div(
                       {align => 'right'},
                       (
                        $m_nRight >= $m_hrSettings->{news}{right}
                        ? a(
                            {
                             href  => "$ENV{SCRIPT_NAME}?action=showEditor",
                             class => 'menuLink3'
                            },
                            translate('newmessage')
                          )
                          . ($m_nLength > 5 ? ' / ' : ' ')
                        : ''
                         )
                         . ($m_nLength > 5 ? translate('news_pro_page') . ' | ' : '')
                         . (
                            $m_nLength > 5
                            ? a(
                                {
                                 href  => "$ENV{SCRIPT_NAME}?action=$m_sAkt&amp;links_pro_page=5&amp;von=$m_nStart$replylink",
                                 class => ($lpp eq 5 ? 'menuLink2' : 'menuLink3')
                                },
                                '5'
                              )
                              . ' '
                            : ''
                         )
                         . (
                            $m_nLength > 9
                            ? a(
                                {
                                 href  => "$ENV{SCRIPT_NAME}?action=$m_sAkt&amp;links_pro_page=10&amp;von=$m_nStart$replylink",
                                 class => ($lpp eq 10 ? 'menuLink2' : 'menuLink3')
                                },
                                '10'
                              )
                              . ' '
                            : ''
                         )
                         . (
                            $m_nLength > 29
                            ? a(
                                {
                                 href  => "$ENV{SCRIPT_NAME}?action=$m_sAkt&amp;links_pro_page=30&amp;von=$m_nStart$replylink",
                                 class => ($lpp eq 30 ? 'menuLink2' : 'menuLink3')
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
                  length         => $m_nLength,
                  style          => $m_sStyle,
                  mod_rewrite    => $m_hrSettings->{cgi}{mod_rewrite},
                  action         => $m_sAkt,
                  append         => "links_pro_page=$lpp$replylink",
                  path           => $m_hrSettings->{cgi}{bin},
                  links_pro_page => $lpp,
    );
    my $pages = makePages(\%needed);
    $itht .= '<tr><td>' . $pages . '</td></tr>';
    $itht .= '<tr><td>' . threadBody($thread) . '</td></tr>';
    $itht .= '<tr><td>' . $pages . '</td></tr>';
    $itht .= '</table>';

    return $itht;
}

sub threadBody
{

    my $th = shift;
    my $output;
    if (($m_oDatabase->tableExists($th))) {
        $output .= '<table border="0" cellpadding="0" cellspacing="10" summary="contentLayout" width="100%">';
        my $lpp =
            defined param('links_pro_page')
          ? param('links_pro_page') =~ /(\d\d?\d?)/
              ? $1
              : $m_hrSettings->{news}{messages}
          : $m_hrSettings->{news}{messages};
        my $qcats = $m_oDatabase->fetch_string("SELECT cats FROM users where user = ?", $m_sUser);
        $qcats = $m_oDatabase->quote($qcats);
        my $answers =
          defined $m_nReplyId
          ? " && refererId =$m_nReplyId"
          : "&& cat REGEXP($qcats)";

        my $sql_read = qq/select title,body,date,id,user,attach,format from $th where `right` <= $m_nRight $answers  order by date desc LIMIT $m_nStart,$lpp /;

        my $sth = $m_dbh->prepare($sql_read);
        $sth->execute() or warn $sql_read . $m_dbh->errstr;

        while (my @data = $sth->fetchrow_array()) {

            my $headline    = $data[0];
            my $body        = $data[1];
            my $datum       = $data[2];
            my $id          = $data[3];
            my $m_sUsername = $data[4];
            my $attach      = $data[5];
            my $format      = $data[6];
            my $replylink =
              $m_hrSettings->{cgi}{mod_rewrite}
              ? "/news$id.html"
              : "$ENV{SCRIPT_NAME}?action=showthread&amp;reply=$id&amp;thread=$th";
            my $answer = translate('answers');
            my @rps    = $m_oDatabase->fetch_array("select count(*) from replies where refererId = $id;");
            my $reply =
              (($rps[0] > 0) && $th eq 'news')
              ? qq(<br/><a href="$replylink" class="link" >$answer:$rps[0]</a>)
              : '<br/>';
            my $menu = "";

            if ($th ne 'replies') {
                my $answerlink =
                  $m_hrSettings->{cgi}{mod_rewrite}
                  ? "/reply$th-$id.html"
                  : "$ENV{SCRIPT_NAME}?action=reply&amp;reply=$id&amp;thread=$th";
                my %reply = (
                             title    => translate('reply'),
                             descr    => translate('reply'),
                             src      => 'reply.png',
                             location => $answerlink,
                             style    => $m_sStyle,
                );
                $menu .= action(\%reply);
            }
            my $editlink =
              $m_hrSettings->{cgi}{mod_rewrite}
              ? "/edit$th-$id.html"
              : "$ENV{SCRIPT_NAME}?action=edit&amp;edit=$id&amp;thread=$th&amp;von=$m_nStart&amp;bis=$m_nEnd;";
            my %edit = (
                        title    => translate('edit'),
                        descr    => translate('edit'),
                        src      => 'edit.png',
                        location => $editlink,
                        style    => $m_sStyle,
            );
            $menu .= action(\%edit) if ($m_nRight > 1);
            my $trdelete = translate('delete');
            my $deletelink =
              $m_hrSettings->{cgi}{mod_rewrite}
              ? "javascript:if(confirm('$trdelete ?')) location.href='/delete.html&amp;delete=$id&amp;thread=$th&amp;von=$m_nStart&amp;bis=$m_nEnd'"
              : "javascript:if(confirm('$trdelete ?')) location.href='$ENV{SCRIPT_NAME}?action=delete&amp;delete=$id&amp;thread=$th&amp;von=$m_nStart&amp;bis=$m_nEnd'";
            my %delete = (
                          title    => translate('delete'),
                          descr    => translate('delete'),
                          src      => 'delete.png',
                          location => $deletelink,
                          style    => $m_sStyle,
            );
            $menu .= action(\%delete) if ($m_nRight >= 5);
            my %parameter = (
                             path   => "$m_hrSettings->{cgi}{bin}/templates",
                             style  => $m_sStyle,
                             title  => qq(<div style="white-space:nowrap;">$headline</div>),
                             server => $m_hrSettings->{cgi}{serverName},
                             id     => $id,
                             class  => 'min',
            );
            my $win = new HTML::Window(\%parameter);
            $win->set_closeable(1);
            $win->set_collapse(1);
            $win->set_moveable(1);
            $win->set_resizeable(1);
            my $h1       = qq(<tr id="trw$id"><td valign="top">) . $win->windowHeader();
            my $readmore = translate('readmore');
            $reply .= qq( <a href="$replylink" class="link" >$readmore</a>) if $body =~ /\[previewende\]/i && $thread eq "news";
            my $permalink =
              $m_hrSettings->{cgi}{mod_rewrite}
              ? "/news$id.html"
              : "$ENV{SCRIPT_NAME}?action=showthread&amp;thread=$th&amp;reply=$id";

            if ($th eq 'news') {
                my $Permalink = translate('Permalink');
                $reply .= qq( <a href="$permalink" class="link" >$permalink</a>) if $m_hrSettings->{news}{permalink};
                $body =~ s/([^\[previewende\]]+)\[previewende\](.*)$/$1/is;
            }
            BBCODE(\$body, $ACCEPT_LANGUAGE) if ($format eq 'bbcode');

            $h1 .=
qq(<table align="left" border ="0" cellpadding="0" cellspacing="0" summary="threadBody"  width="100%"><tr ><td align="left">$menu</td></tr><tr><td align="left"><table align="left" border ="0" cellpadding="0" cellspacing="0" summary="user_datum"  width="100%"><tr><td align="left">$m_sUsername</td><td align="right">$datum</td></tr></table></td></tr><tr><td align="left">$body</td></tr>
            );
            $h1 .= qq(<tr><td><a href="/downloads/$attach">$attach</a></td></tr>) if (-e "$m_hrSettings->{uploads}{path}/$attach");
            $h1 .= qq(<tr><td align="left">$reply</td></tr></table>);
            $h1 .= $win->windowFooter();
            $output .= qq|$h1</td></tr>|;
        }
        $output .= "</table>";
    }
    return $output;
}

sub saveUpload
{
    my $ufi = param('file');
    if ($m_nRight >= $m_hrSettings->{uploads}{right}) {
        if ($ufi) {
            my $attach = (split(/[\\\/]/, param('file')))[-1];
            my $cit = $attach =~ /^(\S+)\.[^\.]+$/ ? $1 : 0;
            my $type = ($attach =~ /\.([^\.]+)$/) ? $1 : 0;
            $cit =~ s/("|'|\s| )//g;
            my $sra = "$cit.$type";
            my $up  = upload('file');
            use Symbol;
            my $fh = gensym();
            open $fh, ">$m_hrSettings->{uploads}{path}/$sra.bak" or warn "news.pl::saveUpload: $!";
            while (<$up>) {print $fh $_;}
            close $fh;
            rename "$m_hrSettings->{uploads}{path}/$sra.bak", "$m_hrSettings->{uploads}{path}/$cit.$type" or warn "news.pl::saveUpload: $!";
            chmod("$m_hrSettings->{'uploads'}{'chmod'}", "$m_hrSettings->{uploads}{path}/$sra") if (-e "$m_hrSettings->{uploads}{path}/$sra");
        }
    }
}

sub trash
{
    my @trash = $m_oDatabase->fetch_AoH('select * from trash');
    my %parameter = (
                     path   => $m_hrSettings->{cgi}{bin} . '/templates',
                     style  => $m_sStyle,
                     title  => translate('trash'),
                     server => $m_hrSettings->{cgi}{serverName},
                     id     => "windowTrash",
                     class  => 'min',
    );
    my $window = new HTML::Window(\%parameter);
    $m_sContent .= $window->windowHeader() . qq(<div style="overflow:auto;"><form action="$ENV{SCRIPT_NAME}" method="get" enctype="multipart/form-data">
    <input type="hidden" name="action" value="rebuildtrash"/>
    <table align="center" border ="0" cellpadding="0" cellspacing="0" summary="threadBody"  width="100%">
        <tr>
        <td class="caption"></td>
        <td class="caption">title</td>
        <td class="caption">date</td>
        <td class="caption">user</td>
        <td class="caption">table</td>
        <td class="caption">oldId</td>
        <td class="caption">refererId</td>
        <td class="caption">cat</td>
        <td class="caption"></td>
        </tr>
        );

    for (my $i = 0; $i <= $#trash; $i++) {
        my $rebuild = translate('rebuild');
        my $delete  = translate('delete');
        my $body    = $trash[$i]->{body};
        $m_sContent .= qq(<tr>
                <td><input type="checkbox" name="markBox$i" class="markBox" value="$trash[$i]->{id}" /></td>
                <td>$trash[$i]->{title}</td>
                <td>$trash[$i]->{date}</td>
                <td>$trash[$i]->{user}</td>
                <td>$trash[$i]->{table}</td>
                <td align="center">$trash[$i]->{oldId}</td>
                <td align="center">$trash[$i]->{refererId}</td>
                <td align="center">$trash[$i]->{cat}</td>
                <td align="right"><a href="$ENV{SCRIPT_NAME}?action=rebuildtrash&amp;id=$trash[$i]->{id}" width="50">$rebuild</a>&#160;<a href="$ENV{SCRIPT_NAME}?action=DeleteEntry&amp;table=trash&amp;&id=$trash[$i]->{id}">$delete</a></td>
                </tr>);
    }
    my $delete   = translate('delete');
    my $mmark    = translate('selected');
    my $markAll  = translate('select_all');
    my $umarkAll = translate('unselect_all');
    my $rebuild  = translate('rebuild');
    $m_sContent .= qq{
                <td colspan="9">
                <table align="center" border="0" cellpadding="0"  cellspacing="0" summary="layout" width="100%" ><tr>
                <td><a id="markAll" href="javascript:markInput(true);" class="links">$markAll</a><a class="links" id="umarkAll" style="display:none;" href="javascript:markInput(false);">$umarkAll</a>
                </td><td align="right">
                <select  name="MultipleRebuild"  onchange="if(this.value != '$mmark' )this.form.submit();">
                <option  value="$mmark" selected="selected">$mmark</option>
                <option value="delete">$delete</option>
                <option value="rebuild">$rebuild</option>
                </select>
                </td></tr></table>
                };
    $m_sContent .= '</table></div>' . $window->windowFooter();
}

sub rebuildtrash
{
    unless (param("MultipleRebuild")) {
        my $id = param('id');
        my $trash = $m_oDatabase->fetch_hashref('select * from trash where id = ?', $id);
        if ($trash->{table} eq 'news') {
            my $err = $m_oDatabase->void("insert into news (`title`,`body`,`attach`,`cat`,`right`,`user`,`action`,`format`,`date`,`id`) values(?,?,?,?,?,?,?,?,?,?)",
                                         $trash->{title}, $trash->{body}, $trash->{attach}, $trash->{cat}, $trash->{right}, $trash->{user}, $trash->{action}, $trash->{format}, $trash->{date}, $trash->{oldId});
            &show();
            $m_oDatabase->void("delete from news where id = ?", $id);
        } else {
            my $err = $m_oDatabase->void("insert into replies (`title`,`body`,`attach`,`cat`,`right`,`user`,`format`,`refererId`,`date`,`id`) values(?,?,?,?,?,?,?,?,?,?)",
                                         $trash->{title}, $trash->{body}, $trash->{attach}, $trash->{cat}, $trash->{right}, $trash->{user}, $trash->{format}, $trash->{refererId}, $trash->{date}, $trash->{oldId});
            &showMessage($trash->{refererId});
            $m_oDatabase->void("delete from replies where id = ?", $id);
        }
    } else {
        &multipleRebuild();
    }
}

=head2 multipleRebuild()

Action:

multipleRebuild

=cut

sub multipleRebuild
{
    my $a      = param("MultipleRebuild");
    my @params = param();

    for (my $i = 0; $i <= $#params; $i++) {
        if ($params[$i] =~ /markBox\d?/) {
            my $id = param($params[$i]);
            my $trash = $m_oDatabase->fetch_hashref('select * from trash where id = ?', $id);
            SWITCH: {
                if ($a eq "delete") {
                    $m_oDatabase->void("delete from trash where id = ?", $id);
                    last SWITCH;
                }
                if ($a eq "rebuild") {
                    if ($trash->{table} eq 'news') {
                        $m_oDatabase->void("insert into news (`title`,`body`,`attach`,`cat`,`right`,`user`,`action`,`format`,`date`,`id`) values(?,?,?,?,?,?,?,?,?,?)",
                                           $trash->{title}, $trash->{body}, $trash->{attach}, $trash->{cat}, $trash->{right}, $trash->{user}, $trash->{action}, $trash->{format}, $trash->{date}, $trash->{oldId});
                        $m_oDatabase->void("delete from trash where id = ?", $id);
                    } else {
                        $m_oDatabase->void("insert into replies (`title`,`body`,`attach`,`cat`,`right`,`user`,`format`,`refererId`,`date`,`id`) values(?,?,?,?,?,?,?,?,?,?)",
                                           $trash->{title}, $trash->{body}, $trash->{attach}, $trash->{cat}, $trash->{right}, $trash->{user}, $trash->{format}, $trash->{refererId}, $trash->{date}, $trash->{oldId});
                        $m_oDatabase->void("delete from trash where id = ?", $id);
                    }
                    last SWITCH;
                }
            }
        }
    }
    &show();
}
1;

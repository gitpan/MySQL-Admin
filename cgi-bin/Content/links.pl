use vars qw(@t $ff $ss $folderfirst $sortstate);
$folderfirst = param('folderfirst') ? 1 : 0;
$ss          = param('sort')        ? 1 : 0;
folderFirst($folderfirst);

sub ShowBookmarks {
    loadTree( $m_hrSettings->{tree}{links} );
    *t = \@{ $HTML::Menu::TreeView::TreeView[0] };
    my %parameter = ( path   => $m_hrSettings->{cgi}{bin} . '/templates',
                      style  => $m_sStyle,
                      title  => " ",
                      server => $m_hrSettings->{serverName},
                      id     => 'ShowBookmarks',
                      class  => 'max',
    );
    my $window = new HTML::Window( \%parameter );
    $m_sContent .= br() . $window->windowHeader();
    _showBookmarksNavi();
    $m_sContent .=
        qq(<table align="center"  border="0" cellpadding="0" cellspacing="0"  width="100%" summary="linkLayout"><tr><td valign="top">);
    $m_sContent .= Tree( \@t );
    $m_sContent .= qq(</td></tr></table>);
    $m_sContent .= $window->windowFooter();
}

sub _showBookmarksNavi {
    $ff = $folderfirst;
    $ff = $ff ? 0 : 1;
    sortTree($ss);
    $sortstate = $ss;
    $ss = $ss ? 0 : 1;
    $m_sContent .=
          '<div align="right">' 
        . br()
        . a(
        {  class => $sortstate ? 'currentLink' : 'link',
           href =>
               "$ENV{SCRIPT_NAME}?action=links&sort=$ss&folderfirst=$folderfirst",
           title => translate('sort')
        },
        translate('sort')
        ) . '&#160;|&#160;';
    $m_sContent .= a(
        {  class => $folderfirst ? 'currentLink' : 'link',
           href =>
               "$ENV{SCRIPT_NAME}?action=links&sort=$sortstate&folderfirst=$ff",
           title => translate('folderFirst')
        },
        translate('folderFirst')
    ) . '&#160;|&#160;';
    $m_sContent .= a(
                   { class => 'link',
                     href  => "$ENV{SCRIPT_NAME}?action=ExportOperaBookmarks",
                     title => translate('ExportOperaBookmarks')
                   },
                   translate('ExportOperaBookmarks')
    );
    $m_sContent .= '&#160;|&#160;'
        . a( {  class => 'link',
                href  => "$ENV{SCRIPT_NAME}?action=editTreeview&dump=links",
                title => translate('edit')
             },
             translate('edit')
        )
        .br()
        if ( $m_nRight >= $m_oDatabase->getActionRight('editTreeview') );
    $m_sContent .= a(
                   { class => $m_sAction eq "ImportOperaBookmarks"
                     ? 'currentLink'
                     : 'link',
                     href  => "$ENV{SCRIPT_NAME}?action=ImportOperaBookmarks",
                     title => translate("ImportOperaBookmarks")
                   },
                   translate("ImportOperaBookmarks")
        )
        if (
          $m_nRight >= $m_oDatabase->getActionRight('ImportOperaBookmarks') );
    $m_sContent .= '&#160;|&#160;'
        . a(
          { class => $m_sAction eq "ImportFireFoxBookmarks"
            ? 'currentLink'
            : 'link',
            href =>
                "$ENV{SCRIPT_NAME}?action=ImportFireFoxBookmarks&dump=links",
            title => translate('importFireFox')
          },
          translate('importFireFox')
        )
        if (
        $m_nRight >= $m_oDatabase->getActionRight('ImportFireFoxBookmarks') );
    my $moveLink = translate('DragShareLink');
    $m_sContent .= '&#160;|&#160;'
        . a(
        {  class => 'link',
           href =>
               qq|javascript:window.open(' $m_hrSettings->{cgi}{serverName}$ENV{SCRIPT_NAME}?dump=links&action=newTreeviewEntry&addBookMark='+escape(location.href)+'&title='+escape(document.title),'Bookmark');void(0)|,
           title   => translate('DragShareLink'),
           onclick => "alert('$moveLink');return false;",
        },
        translate('shareLink')
        )
        if ( $m_nRight >= $m_oDatabase->getActionRight('newTreeviewEntry') );

    $m_sContent .= '</div>' . br();
}

sub ExportOperaBookmarks {
    loadTree( $m_hrSettings->{tree}{links} );
    *t = \@{ $HTML::Menu::TreeView::TreeView[0] };
    my %parameter = ( path   => $m_hrSettings->{cgi}{bin} . '/templates',
                      style  => $m_sStyle,
                      title  => " ",
                      server => $m_hrSettings->{serverName},
                      id     => 'ShowBookmarks',
                      class  => 'min',
    );
    my $window = new HTML::Window( \%parameter );
    $m_sContent .= br() . $window->windowHeader();
    _showBookmarksNavi();
    $m_sContent .=
        qq(<table align="center"  border="0" cellpadding="0" cellspacing="0"  width="100%" summary="linkLayout"><tr><td align="center" valign="top">);
    $m_sContent .=
        qq(<textarea style="width:98%;height:800px;">\nOpera Hotlist version 2.0\nOptions: encoding = utf-8, version=3\n);
    &_rec( \@t );
    $m_sContent .= qq(</textarea><br/>);
    $m_sContent .= qq(</td></tr></table>);
    $m_sContent .= $window->windowFooter();
}

sub _rec {
    my $tree = shift;
    for ( my $i = 0; $i < @$tree; $i++ ) {
        if ( defined @$tree[$i] ) {
            my $text = defined @$tree[$i]->{text} ? @$tree[$i]->{text} : '';
            if ( defined @{ @$tree[$i]->{subtree} } ) {
                $m_sContent .=
                    "#FOLDER\n\tID=@$tree[$i]->{rid}\n\tNAME=$text\n\tUNIQUEID=@$tree[$i]->{rid}\n";
                _rec( \@{ @$tree[$i]->{subtree} } );
                $m_sContent .= "-\n\n";
            } else {
                my $hrf =
                    defined @$tree[$i]->{href} ? @$tree[$i]->{href} : '';
                $m_sContent .=
                    "#URL\n\tID=@$tree[$i]->{rid}\n\tNAME=$text\n\tURL=$hrf\n\tUNIQUEID=@$tree[$i]->{rid}\n";
            }
        }
    }
}

sub ImportOperaBookmarks {
    my $save        = translate('save');
    my $choosefile  = translate('choosefile');
    my $newFolder   = translate('newFolder');
    my $b_NewFolder = param('newFolder') ? param('newFolder') : '';
    $m_sContent .= qq|
<br/><div align="center">
<font size="+1">Upload Opera Bookmarks</font><br/><br/>
<form name="upload" action="$ENV{SCRIPT_NAME}" method="post" accept-charset="utf-8" accept="text/*" enctype="multipart/form-data" onSubmit="return confirm('$save ?');">
<input name="file" type="file" size ="30" title="$choosefile"/>
$newFolder<input type="checkbox" name="newFolder"/>
<input type="submit" value="$save"/>
<input  name="action" value="ImportOperaBookmarks" style="display:none;"/>
</form></div><br/>|;
    my $sra = 0;
    my $ufi = param('file');

    if ($ufi) {
        use vars
            qw(@adrFile $folderId $currentOpen @openFolders @operaTree $treeTempRef $up);
        $up = upload('file');
        while (<$up>) { push @adrFile, $_; }
        ( $folderId, $currentOpen ) = (0) x 2;

        if ( $b_NewFolder eq 'on' ) {
            loadTree( $m_hrSettings->{tree}{links} );
            unshift @fireFoxTree, @{ $HTML::Menu::TreeView::TreeView[0] };
        }
        $treeTempRef = \@operaTree;
        $openFolders[0][0] = $treeTempRef;
        for ( my $line = 0; $line < $#adrFile; $line++ ) {
            chomp $adrFile[$line];
            if ( $adrFile[$line] =~ /^#FOLDER/ ) {    #neuer Folder
                $folderId++;
                my $text = $1 if ( $adrFile[ $line+ 1 ] =~ /NAME=(.*)$/ );
                $text = $1 if ( $adrFile[ $line+ 2 ] =~ /NAME=(.*)$/ );

              #                 Encode::from_to($text, "utf-8", "iso-8859-1");
                push @{$treeTempRef},
                    { text => $text =~ /(.{50}).+/ ? "$1..." : $text,
                      subtree => []
                    };
                my $l = @$treeTempRef;
                $treeTempRef =
                    \@{ @{$treeTempRef}[ $l- 1 ]
                        ->{subtree} };    #aktuelle referenz setzen.
                $openFolders[$folderId][0] =
                    $treeTempRef;    #referenz auf den parent Tree speichern
                $openFolders[$folderId][1] =
                    $currentOpen;    #rücksprung speichern
                $currentOpen = $folderId;
            }
            if ( $adrFile[$line] =~ /^-/ ) {    #wenn folder geschlossen wird
                $treeTempRef =
                    $openFolders[ $openFolders[$currentOpen][1] ][0]
                    ;    #aktuelle referenz auf parent referenz setzen
                $currentOpen =
                    $openFolders[$currentOpen][1];    #rücksprung zu parent
            }
            if ( $adrFile[$line] =~ /^#URL/ ) {       #Node anhängen
                my $text = $1 if ( $adrFile[ $line+ 2 ] =~ /NAME=(.*)$/ );
                $text = $1 if ( $adrFile[ $line+ 1 ] =~ /NAME=(.*)$/ );
                my $href = $1 if ( $adrFile[ $line+ 3 ] =~ /URL=(.*)$/ );
                $href = $1 if ( $adrFile[ $line+ 2 ] =~ /URL=(.*)$/ );
                if ( defined $text && defined $href ) {
                    push @{$treeTempRef},
                        { text => $text =~ /(.{75}).+/ ? "$1..." : $text,
                          href => $href,
                          target => "_blank",
                        };
                }
            }
        }
        saveTree( $m_hrSettings->{tree}{links}, \@operaTree );
    }
    ShowBookmarks();
}

sub ImportFireFoxBookmarks {
    my $save        = translate('save');
    my $choosefile  = translate('choosefile');
    my $newFolder   = translate('newFolder');
    my $b_NewFolder = param('newFolder') ? param('newFolder') : '';
    $m_sContent .= qq|
<br/><div align="center">
<font size="+1">Upload Firefox Bookmarks</font><br/><br/>
<form name="upload" action="$ENV{SCRIPT_NAME}" method="post" accept-charset="utf-8" accept="text/*" enctype="multipart/form-data" onSubmit="return confirm('$save ?');">
<input name="file" type="file" size ="30" title="$choosefile"/>
$newFolder<input type="checkbox"  name="newFolder"/>
<input type="submit" value="$save"/>
<input  name="action" value="ImportFireFoxBookmarks" style="display:none;"/>
</form></div><br/>|;
    my $sra = 0;
    my $ufi = param('file');

    if ($ufi) {
        use vars
            qw(@adrFile $folderId $currentOpen @openFolders @fireFoxTree $treeTempRef $up);
        $up = upload('file');
        while (<$up>) { push @adrFile, $_; }
        ( $folderId, $currentOpen ) = (0) x 2;
        if ( $b_NewFolder eq 'on' ) {
            loadTree( $m_hrSettings->{tree}{links} );
            unshift @fireFoxTree, @{ $HTML::Menu::TreeView::TreeView[0] };
        }
        $treeTempRef       = \@fireFoxTree;
        $openFolders[0][0] = $treeTempRef;
        $openFolders[0][1] = 0;
        for ( my $line = 0; $line < $#adrFile; $line++ ) {
            chomp $adrFile[$line];
            if ( $adrFile[$line] =~ /<DL>/ ) {    #neuer Folder
                $folderId++;
                if ( $adrFile[ $line- 1 ] =~ /<H3[^>]+>(.*)<\/H3>/ ) {
                    my $text = $1;
                    push @{$treeTempRef},
                        { text => $text =~ /(.{50}).+/ ? "$1..." : $text,
                          subtree => []
                        };
                    my $l = @$treeTempRef;
                    $treeTempRef =
                        \@{ @{$treeTempRef}[ $l- 1 ]
                            ->{subtree} };    #aktuelle referenz setzen.
                    $openFolders[$folderId][0] =
                        $treeTempRef;  #referenz auf den parent Tree speichern
                    $openFolders[$folderId][1] =
                        $currentOpen;    #rücksprung speichern
                    $currentOpen = $folderId;
                }
            }
            if ( $adrFile[$line] =~ /<\/DL>/ ) { #wenn folder geschlossen wird
                $treeTempRef =
                    $openFolders[ $openFolders[$currentOpen][1] ][0]
                    ;    #aktuelle referenz auf parent referenz setzen
                $currentOpen =
                    $openFolders[$currentOpen][1];    #rücksprung zu parent
            }
            if ( $adrFile[$line] =~ /<A HREF="([^"]+)"[^>]+>(.*)<\/A>/ )
            {                                         #Node anhängen
                my $text = $2;
                my $href = $1;

              #                 Encode::from_to($text, "utf-8", "iso-8859-1");
                if ( defined $text && defined $href ) {
                    push @{$treeTempRef},
                        { text => $text =~ /(.{75}).+/ ? "$1..." : $text,
                          href => $href,
                          target => "_blank",
                        };
                }
            }
        }
        saveTree( $m_hrSettings->{tree}{links}, \@fireFoxTree );
    }
    ShowBookmarks();
}

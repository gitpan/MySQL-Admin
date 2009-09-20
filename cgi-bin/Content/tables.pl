use vars qw/$RIBBONCONTENT $PAGES $SQL %m_hUserRights/;
no warnings "uninitialized";
use utf8;
ChangeDb(
         {
          name     => $m_sCurrentDb,
          host     => $m_sCurrentHost,
          user     => $m_sCurrentUser,
          password => $m_sCurrentPass,
         }
);
$PAGES = br() . br();

=head2 ShowNewTable()

Action:

Form um eine Neue tabelle zu erstelle anzeigen

=cut

sub ShowNewTable
{
    my $tbl   = $_[0] ? shift : param('table');    #todo parameter wieder nzeigen
    my $count = $_[0] ? shift : param('count');
    my $newentry = translate('CreateNewTable');
    my $save     = translate('save');
    my %parameter = (
                     path     => $m_hrSettings->{cgi}{bin} . '/templates',
                     style    => $m_sStyle,
                     template => "wnd.htm",
                     server   => $m_hrSettings->{serverName},
                     id       => 'ShowNewTable',
                     class    => 'max',
    );
    my $window = new HTML::Window(\%parameter);
    $m_sContent .= br() . $window->windowHeader();
    ShowDbHeader($m_sCurrentDb, 0, "none");
    $m_sContent .= qq(
       <div align="center" style="overflow:auto;">
       <form action="$ENV{SCRIPT_NAME}" method="post" enctype="multipart/form-data">
       <input type="hidden" name="action" value="SaveNewTable"/>
       <table border="0" cellpadding="0" cellspacing="0" class="dataBaseTable" summary="ShowNewTable">
       <tr><td colspan="8" align="left"><b>$tbl</b></td></tr>
       <tr>
              <td class="caption">Field</td>
              <td class="caption">Type</td>
              <td class="caption">LENGTH</td>
              <td class="caption">Null</td>
              <td class="caption">Default</td>
              <td class="caption">Extra</td>
              <td class="caption">Attribute</td>
              <td class="caption">Primary Key</td>
       </tr>
    );
    my %vars = (
                user   => $m_sUser,
                action => 'SaveNewTable',
                table  => $tbl,
                count  => $count,
                rows   => {}
    );
    sessionValidity(60 * 60);
    my $m_hUniqueRadio = Unique();

    for (my $j = 0; $j < $count; $j++) {
        my $m_hUniqueField   = Unique();
        my $m_hUniqueType    = Unique();
        my $m_hUniqueLength  = Unique();
        my $m_hUniqueNull    = Unique();
        my $m_hUniqueKey     = Unique();
        my $m_hUniqueDefault = Unique();
        my $m_hUniqueExtra   = Unique();
        my $m_hUniqueComment = Unique();
        my $m_hUniqueAttrs   = Unique();
        my $m_hUniquePrimary = Unique();
        my $atrrs            = $m_oDatabase->GetAttrs(0, "none", $m_hUniqueAttrs);
        $m_sContent .= qq|
              <tr>
              <td calss="values"><input type="text" value="" name="$m_hUniqueField"/></td>
              <td calss="values">|
          . $m_oDatabase->GetTypes('INT', $m_hUniqueType) . qq{</td>
              <td calss="values"><input type="text" value="" style="width:40px;" name="$m_hUniqueLength"/></td>
              <td calss="values">
              <select name="$m_hUniqueNull">
                     <option  value="not NULL">not NULL</option>
                     <option value="NULL">NULL</option>
              </select>
              </td>
              <td calss="values"><input type="text" value="" name="$m_hUniqueDefault"/></td>
              <td calss="values">
              <select name="$m_hUniqueExtra">
                     <option value=""></option>
                     <option value="auto_increment">auto_increment</option>
              </select>
              </td>
              <td calss="values">$atrrs</td>
              <td calss="values">
              <input type="checkbox" class="checkbox"   name="$m_hUniquePrimary"/> Primary Key
              </td>
              </tr>
     };
        $vars{rows}{$m_hUniqueField} = {
                                        Field   => $m_hUniqueField,
                                        Type    => $m_hUniqueType,
                                        Length  => $m_hUniqueLength,
                                        Null    => $m_hUniqueNull,
                                        Key     => $m_hUniqueKey,
                                        Default => $m_hUniqueDefault,
                                        Extra   => $m_hUniqueExtra,
                                        Comment => $m_hUniqueComment,
                                        Attrs   => $m_hUniqueAttrs,
                                        Primary => $m_hUniquePrimary,
        };
    }
    my $m_hUniqueCollation = Unique();
    my $m_hUniqueEngine    = Unique();
    my $m_hUniqueComment   = Unique();
    $vars{Collation} = $m_hUniqueCollation;
    $vars{Engine}    = $m_hUniqueEngine;
    clearSession();
    my $qstring   = createSession(\%vars);
    my $collation = $m_oDatabase->GetCollation($m_hUniqueCollation);
    $m_sContent .= qq(
       </table>
       <br/>
       $collation <input type="text" value="" name="$m_hUniqueComment" align="left"/><br/>
       <input type="submit" value="$save" align="right"/>
       <input type="hidden" name="create_table_sessionPop" value="$qstring"/>
       </form>
       </div>
       );
    $m_sContent .= $window->windowFooter();
}

=head2 SaveNewTable()

Action:

Neue Tabelle erstellen.

=cut

sub SaveNewTable
{
    my $session = param('create_table_sessionPop');
    session($session, $m_sUser);
    my $tbl = $m_hrParams->{table};
    my $pk;
    my @prims;
    if (defined $tbl and defined $session) {
        my $tbl2 = $m_dbh->quote_identifier($tbl);
        my $sql  = qq|CREATE TABLE IF NOT EXISTS $tbl2 (|;
        foreach my $row (keys %{$m_hrParams->{rows}}) {
            my $type   = param($m_hrParams->{rows}{$row}{Type});
            my $length = param($m_hrParams->{rows}{$row}{Length});
            $type = $type =~ /Blob|TEXT|TIMESTAMP/ ? $type : $length ? $type . "($length)" : $type;
            my $fie1d   = param($m_hrParams->{rows}{$row}{Field});
            my $null    = param($m_hrParams->{rows}{$row}{Null});
            my $extra   = param($m_hrParams->{rows}{$row}{Extra});
            my $default = param($m_hrParams->{rows}{$row}{Default});
            my $attrs   = param(param($m_hrParams->{rows}{$row}{Attrs}));
            my $prim    = param($m_hrParams->{rows}{$row}{Primary});
            push @prims, $fie1d if $prim eq 'on';
            $default = $extra ? 'auto_increment' : ($default ? 'default ' . $m_oDatabase->quote($default) : '');
            $sql .= $m_dbh->quote_identifier($fie1d) . " $type $null $default $attrs,";
        }
        my $comment  = param($m_hrParams->{Comment});
        my $vcomment = $m_dbh->quote($comment);
        my $engine   = param($m_hrParams->{Engine}) ? param($m_hrParams->{Engine}) : 'MyISAM';
        for (my $i = 0; $i < $#prims; $i++) {$prims[$i] = $m_dbh->quote_identifier($i);}
        my $key = join(' , ', @prims);
        my $character_set = $m_oDatabase->GetCharacterSet(param($m_hrParams->{Collation}));
        $sql .= qq| PRIMARY KEY  ($key) ) ENGINE=$engine DEFAULT CHARSET=$character_set|;
        $sql .= $comment ? " COMMENT $vcomment;" : ';';

        unless (ExecSql($sql)) {
            ShowNewTable($tbl, $m_hrParams->{count});
        } else {
            EditTable($tbl);
        }
    } else {
        ShowNewTable($tbl, $m_hrParams->{count});
    }
}

=head2 ShowDumpTable()

Action:

Export Tabelle

=cut

sub ShowDumpTable
{
    my $tbl = param('table');
    my %parameter = (
                     path     => $m_hrSettings->{cgi}{bin} . '/templates',
                     style    => $m_sStyle,
                     template => "wnd.htm",
                     server   => $m_hrSettings->{serverName},
                     id       => 'ShowDumpTable',
                     class    => 'max',
    );
    my $window = new HTML::Window(\%parameter);
    $m_sContent .= br() . $window->windowHeader();
    ShowDbHeader($tbl, 1, "Export");
    $m_sContent .= '<div align="left" class="dumpBox" style="width:100%;padding-top:5px;">';
    $m_sContent .= qq(<textarea style="width:100%;height:800px;overflow:auto;">);
    DumpTable($tbl);
    $m_sContent .= qq(</textarea>);
    $m_sContent .= '</div>' . $window->windowFooter();
}

=head2 DumpTable()

Tabelle wird $m_sContent angehangen.

=cut

sub DumpTable
{
    my $tbl = $_[0] ? shift : param('table');
    $tbl = $m_dbh->quote_identifier($tbl);
    my $hr      = $m_oDatabase->fetch_hashref("SHOW CREATE TABLE $tbl");
    my $sql     = $hr->{'Create Table'} . ";$/";
    my @a       = $m_oDatabase->fetch_AoH("select *from $tbl");
    my @columns = $m_oDatabase->fetch_AoH("show columns from $tbl");
    for (my $n = 0; $n <= $#a; $n++) {
        $sql .= "INSERT INTO $tbl (";
        for (my $i = 0; $i <= $#columns; $i++) {
            $sql .= $m_dbh->quote_identifier($columns[$i]->{'Field'});
            $sql .= "," if ($i < $#columns);
        }
        $sql .= ') values(';
        for (my $i = 0; $i <= $#columns; $i++) {
            $sql .= $m_oDatabase->quote($a[$n]->{$columns[$i]->{'Field'}});
            $sql .= "," if ($i < $#columns);
        }
        $sql .= ");$/";
    }
    $m_sContent .= $sql . $/;
}

=head2 ShowDumpDatabase()

Action

Export Datenbank

=cut

sub ShowDumpDatabase
{
    my %parameter = (
                     path     => $m_hrSettings->{cgi}{bin} . '/templates',
                     style    => $m_sStyle,
                     template => "wnd.htm",
                     server   => $m_hrSettings->{serverName},
                     id       => 'ShowDumpDatabase',
                     class    => 'max',
    );
    my $window = new HTML::Window(\%parameter);
    $m_sContent .= br() . $window->windowHeader();
    ShowDbHeader($m_sCurrentDb, 0, 'Export');
    $m_sContent .=
      qq(<div align="left" class="dumpBox" style="width:100%;padding-top:5px;"><textarea style="width:100%;height:800px;overflow:auto;">);
    DumpDatabase();
    $m_sContent .= qq(</textarea></div>) . $window->windowFooter();
}

=head2 DumpDatabase()

private

Export Datenbank

=cut

sub DumpDatabase
{
    my $sql = (defined $_[0]) ? "show tables from " . $m_dbh->quote_identifier($_[0]) : "show tables";
    my @tables = $m_oDatabase->fetch_array($sql);
    ChangeDb(
             {
              name => (defined $_[0]) ? $_[0] : $m_sCurrentDb,
              host => $m_sCurrentHost,
              user => $m_sCurrentUser,
              password => $m_sCurrentPass,
             }
    );
    for (my $n = 0; $n <= $#tables; $n++) {DumpTable($tables[$n]);}
}

=head2 HighlightSQl()

$formated_string = HighlightSQl()

=cut

sub HighlightSQl
{
    use Syntax::Highlight::Engine::Kate;
    my $hl = new Syntax::Highlight::Engine::Kate(
                                                 language      => "SQL",
                                                 substitutions => {
                                                                   "<" => "&lt;",
                                                                   ">" => "&gt;",
                                                                   "&" => "&amp;",
                                                 },
                                                 format_table => {
                                                                  Alert        => ['<span class="Alert">',        '</span>'],
                                                                  BaseN        => ['<span class="BaseN">',        '</span>'],
                                                                  BString      => ['<span class="BString">',      '</span>'],
                                                                  Char         => ['<span class="Char">',         '</span>'],
                                                                  Comment      => ['<span class="Comment">',      '</span>'],
                                                                  DataType     => ['<span class="DataType">',     '</span>'],
                                                                  DecVal       => ['<span class="DecVal">',       '</span>'],
                                                                  Error        => ['<span class="Error">',        '</span>'],
                                                                  Float        => ['<span class="Float">',        '</span>'],
                                                                  Function     => ['<span class="Function">',     '</span>'],
                                                                  IString      => ['<span class="IString">',      '</span>'],
                                                                  Keyword      => ['<span class="Keyword">',      '</span>'],
                                                                  Normal       => ['<span class="Normal">',       '</span>'],
                                                                  Operator     => ['<span class="Operator">',     '</span>'],
                                                                  Others       => ['<span class="Others">',       '</span>'],
                                                                  RegionMarker => ['<span class="RegionMarker">', '</span>'],
                                                                  Reserved     => ['<span class="Reserved">',     '</span>'],
                                                                  String       => ['<span class="String">',       '</span>'],
                                                                  Variable     => ['<span class="Variable">',     '</span>'],
                                                                  Warning      => ['<span class="Warning">',      '</span>'],
                                                 },
    );
    return $hl->highlightText(shift);
}

=head2 AddFulltext()

     AddFulltext(table,name)

=cut

sub AddFulltext
{
    my $tbl   = param('table')  ? param('table')  : shift;
    my $uname = param('column') ? param('column') : shift;
    if ($m_oDatabase->tableExists($tbl) && defined $uname) {
        my $tbl2 = $m_dbh->quote_identifier($tbl);
        $uname = $m_dbh->quote_identifier($uname);
        ExecSql("Alter TABLE $tbl2 ADD FULLTEXT ($uname)");
        EditTable($tbl);
    } else {
        ShowTables();
    }
}

=head2 DropFulltext()

     DropFulltext(table,name)

=cut

sub DropFulltext
{
    my $tbl   = param('table')  ? param('table')  : shift;
    my $uname = param('column') ? param('column') : shift;
    if ($m_oDatabase->tableExists($tbl) && defined $uname) {
        my $tbl2 = $m_dbh->quote_identifier($tbl);
        $uname = $m_dbh->quote_identifier($uname);
        ExecSql("Alter TABLE $tbl2 DROP FULLTEXT ($uname)");
        EditTable($tbl);
    } else {
        ShowTables();
    }
}

=head2 AddIndex()

       AddIndex(table,name)

=cut

sub AddIndex
{
    my $tbl   = param('table')  ? param('table')  : shift;
    my $uname = param('column') ? param('column') : shift;
    if ($m_oDatabase->tableExists($tbl) && defined $uname) {
        my $tbl2 = $m_dbh->quote_identifier($tbl);
        $uname = $m_dbh->quote_identifier($uname);
        ExecSql("Alter TABLE $tbl2 ADD INDEX ($uname)");
        EditTable($tbl);
    } else {
        ShowTables();
    }
}

=head2 DropIndex()

       DropIndex(table,name)

=cut

sub DropIndex
{
    my $tbl   = param('table') ? param('table') : shift;
    my $uname = param('index') ? param('index') : shift;
    if ($m_oDatabase->tableExists($tbl) && defined $uname) {
        my $tbl2 = $m_dbh->quote_identifier($tbl);
        $uname = $m_dbh->quote_identifier($uname);
        ExecSql("Alter TABLE $tbl2 DROP INDEX $uname");
        EditTable($tbl);
    } else {
        ShowTables();
    }
}

=head2 AddUnique()

       AddUnique(table,name)

=cut

sub AddUnique
{
    my $tbl   = param('table')  ? param('table')  : shift;
    my $uname = param('column') ? param('column') : shift;
    if ($m_oDatabase->tableExists($tbl) && defined $uname) {
        my $tbl2 = $m_dbh->quote_identifier($tbl);
        $uname = $m_dbh->quote_identifier($uname);
        ExecSql("Alter TABLE $tbl2 ADD UNIQUE ($uname)");
        EditTable($tbl);
    } else {
        ShowTables();
    }
}

=head2 DropUnique()

       DropUnique(table,name)

=cut

sub DropUnique
{
    my $tbl   = param('table')  ? param('table')  : shift;
    my $uname = param('column') ? param('column') : shift;
    if ($m_oDatabase->tableExists($tbl) && defined $uname) {
        my $tbl2 = $m_dbh->quote_identifier($tbl);
        $uname = $m_dbh->quote_identifier($uname);
        ExecSql("Alter TABLE $tbl2 DROP UNIQUE ($uname)");
        EditTable($tbl);
    } else {
        ShowTables();
    }
}

=head2 ExecSql()

       ExecSql(sql, bool showSql)

=cut

sub ExecSql
{
    my $sql        = shift;
    my $showSql    = $_[0] ? $_[0] : param('showsql');
    my @statements = split /;\n/, $sql unless param('sql');
    @statements = split /%3B%0D%0A/, uri_escape($sql) if param('sql');
    my %parameter = (
                     path     => $m_hrSettings->{cgi}{bin} . '/templates',
                     style    => $m_sStyle,
                     template => 'wnd.htm',
                     server   => $m_hrSettings->{serverName},
                     id       => 'ExecSql',
                     class    => 'max',
    );
    $RIBBONCONTENT .= '<br/><br/><div class="sqlBox" style="width:100%;overflow:auto;">' if $showSql;
    my $id2 = 0;
    my $ret = 1;

    foreach my $s (@statements) {
        $s = uri_unescape($s);
        $SQL .= "$s$/";
        my $rows_affected = 0;
        $parameter{id} = "ExecSql$id2";
        my $window = new HTML::Window(\%parameter);
        eval {
            my $sth = $m_dbh->prepare($s);
            $sth->execute();
            $rows_affected = $sth->rows;
            if ($showSql) {
                if ($rows_affected > 0) {
                    my $id = 0;
                    while (my $ergebnis = $sth->fetchrow_hashref) {
                        $RIBBONCONTENT .=
'<table border="0" cellpadding="5" cellspacing="0" class="dataBaseTable"  summary="SelectEntry" width="100%" style="border-bottom:1px solid black;border-right:1px solid black;">';
                        $parameter{id} = "ExecSql$id";
                        while (my ($spaltenname, $inhalt) = each(%$ergebnis)) {
                        if (!utf8::is_utf8($inhalt)) {
                                 utf8::decode($inhalt);
                        }
                            $RIBBONCONTENT .=
qq|<tr><td class="caption" valign="top" align="left" style="border-left:1px solid black;border-top:1px solid black;" width="120">$spaltenname</td><td valign="top" align="left" class="value" style="border-left:1px solid black;border-top:1px solid black;" width="*">|
                              . encode_entities($inhalt)
                              . '</td></tr>';
                        }
                        $id++;
                        $RIBBONCONTENT .= '</table><br/>';
                    }
                }

            }
            if ($@) {
                $ret = 0;
                $RIBBONCONTENT .= br() . $window->windowHeader() . HighlightSQl($s) . br() . $m_dbh->errstr . $window->windowFooter();
            }
        };
        $id2++;
        $RIBBONCONTENT .= br() . translate('rows in effect') . $rows_affected if ($rows_affected > 0 && $showSql);
    }
    $RIBBONCONTENT .= '</div><br/>' if $showSql;

    return $ret;
}

=head2 SQL()

action
       SQL

=cut

sub SQL
{
    ExecSql(param('sql'), 1);
    ShowTables();
}

=head2 ShowTable()

action
       ShowTable(table)

=cut

sub ShowTable
{
    my $tbl = param('table') ? param('table') : shift;
    if ($m_oDatabase->tableExists($tbl)) {
        my %parameter = (
                         path     => $m_hrSettings->{cgi}{bin} . '/templates',
                         style    => $m_sStyle,
                         template => "wnd.htm",
                         server   => $m_hrSettings->{serverName},
                         id       => 'ShowTable',
                         class    => 'max',
        );
        my $window = new HTML::Window(\%parameter);
        $m_sContent .= br() . $window->windowHeader();
        my $tb2 = $m_dbh->quote_identifier($tbl);

        my $count   = $m_oDatabase->tableLength($tbl);
        my @caption = $m_oDatabase->fetch_AoH("show columns from $tb2");
        my $rws     = $#caption + 2;
        my $rows    = $#caption;
        $m_nStart = ($m_nStart >= $count) ? ((($count - 10) > 0) ? ($count - 10) : 0) : $m_nStart;
        my $field = $caption[0]->{'Field'};
        my $orderby = defined param('orderBy') ? param('orderBy') : 0;
        $field = $orderby if $orderby;
        my $qfield = $m_dbh->quote_identifier($field);
        my $state  = param('desc') ? param('desc') : 0;
        my $desc   = $state ? 'desc' : '';
        my $lpp    = defined param('links_pro_page') ? param('links_pro_page') : 30;
        $lpp = $lpp =~ /(\d\d\d?)/ ? $1 : $lpp;
        my @a = $m_oDatabase->fetch_AoH("select * from $tb2 order by $qfield $desc LIMIT $m_nStart , $lpp");

        if ($count > 0) {
            my %needed = (
                          start          => $m_nStart,
                          length         => $count,
                          style          => $m_sStyle,
                          mod_rewrite    => 0,
                          action         => "ShowTable",
                          append         => "&table=$tbl&links_pro_page=$lpp&orderBy=$field&desc=$state",
                          path           => $m_hrSettings->{cgi}{bin},
                          links_pro_page => $lpp,
            );
            $PAGES = makePages(\%needed);
        }
        ShowDbHeader($tbl, 1, "Show");
        $m_sContent .= qq|
                     <div style="overflow:auto;"><form action="$ENV{SCRIPT_NAME}" method="get" enctype="multipart/form-data">
                     <input type="hidden" name="action" value="MultipleAction"/>
                     <input type="hidden" name="table" value="$tbl"/>
                     <table align="center" border="0" cellpadding="2" cellspacing="0" summary="layout" width="100%"><tr><td></td><td colspan="$rws">|
          . (
             $count > 20
             ? div(
                   {align => 'right'},
                   translate('links_pro_page') 
                     . '&#160;|&#160;'
                     . a(
                         {
                          href  => "$ENV{SCRIPT_NAME}?action=ShowTable&table=$tbl&links_pro_page=10&von=$m_nStart&orderBy=$field&desc=$state",
                          class => $lpp == 10 ? 'menuLink2' : 'menuLink3'
                         },
                         '10'
                     )
                     . (
                        $count > 20
                        ? '&#160;|&#160;'
                          . a(
                              {
                               href  => "$ENV{SCRIPT_NAME}?action=ShowTable&table=$tbl&links_pro_page=20&von=$m_nStart&orderBy=$field&desc=$state",
                               class => $lpp == 20 ? 'menuLink2' : 'menuLink3'
                              },
                              '20'
                          )
                        : ''
                     )
                     . (
                        $count > 30
                        ? '&#160;|&#160;'
                          . a(
                              {
                               href  => "$ENV{SCRIPT_NAME}?action=ShowTable&table=$tbl&links_pro_page=30&von=$m_nStart&orderBy=$field&desc=$state",
                               class => $lpp == 30 ? 'menuLink2' : 'menuLink3'
                              },
                              '30'
                          )
                        : ''
                     )
                     . (
                        $count > 100
                        ? '&#160;|&#160;'
                          . a(
                              {
                               href  => "$ENV{SCRIPT_NAME}?action=ShowTable&table=$tbl&links_pro_page=100&von=$m_nStart&orderBy=$field&desc=$state",
                               class => $lpp == 100 ? 'menuLink2' : 'menuLink3'
                              },
                              '100'
                          )
                        : ''
                     )
               )
             : ''
          ) . '</td></tr><tr><td class="caption"></td>';
        for (my $i = 0; $i <= $rows; $i++) {
            $m_sContent .= qq|<td class="caption">|;
            $m_sContent .= a(
                {
                 class => $caption[$i]->{'Field'} eq $field ? 'currentLink' : 'link',
                 href => "$ENV{SCRIPT_NAME}?action=ShowTable&table=$tbl&links_pro_page=$lpp&von=$m_nStart&orderBy=$caption[$i]->{'Field'}&desc="
                   . ($field eq $caption[$i]->{'Field'} ? ($desc eq 'desc' ? '0' : '1') : '0'),
                 title => $caption[$i]->{'Field'}
                },
                $caption[$i]->{'Field'}

              )
              . (
                 $caption[$i]->{'Field'} eq $field
                 ? (
                    $state
                    ? qq|&#160;<img src="/style/$m_sStyle/$m_nSize/mimetypes/up.png" border="0" alt="up" title="up" width="16" height="16"/>|
                    : qq|&#160;<img src="/style/$m_sStyle/$m_nSize/mimetypes/down.png" border="0" alt="down" title="down"/>|
                   )
                 : ''
              );
            $m_sContent .= '</td>';
        }
        $m_sContent .= '<td class="caption"></td></tr>';
        my @p_key    = $m_oDatabase->GetPrimaryKey($tbl);
        my $trdelete = translate('delete');
        my $tredit   = translate('EditEntry');
        for (my $i = 0; $i <= $#a; $i++) {
            $m_sContent .= q|<tr onmouseover="this.className='overDb';" onmouseout="this.className='';">|;
            my $eid  = "";
            my $pkey = "";
            if ($#p_key > 0) {
                for (my $j = 0; $j < $#p_key; $j++) {
                    $eid  .= "$p_key[$j]=$a[$i]->{$p_key[$j]}&amp;";
                    $pkey .= "$a[$i]->{$p_key[$j]}/";
                }
                $eid  .= "$p_key[$#p_key]=$a[$i]->{ $p_key[$#p_key]}";
                $pkey .= "$a[$i]->{$p_key[$#p_key]}";
            } else {
                $eid  .= "$p_key[0]=$a[$i]->{$p_key[0]}";
                $pkey .= "$a[$i]->{$p_key[0]}";
            }
            $m_sContent .= qq|<td width="20"><input type="checkbox" name="markBox$i" class="markBox" value="$tbl/$pkey" /></td>|;
            for (my $j = 0; $j <= $rows; $j++) {
                my $headline = $a[$i]->{$caption[$j]->{'Field'}};
                $m_sContent .= '<td class="values">' . substr($headline, 0, int(120 / $rows)) . '</td>';
            }
            $m_sContent .=
qq|<td class="values"><a href="$ENV{SCRIPT_NAME}?action=EditEntry&amp;table=$tbl&amp;$eid&amp;von=$m_nStart&amp;bis=$m_nEnd;"><img src="/style/$m_sStyle/buttons/edit.png" border="0" alt="Edit" title="$tredit"/></a><a href ="$ENV{SCRIPT_NAME}?action=DeleteEntry&amp;table=$tbl&amp;$eid&amp;von=$m_nStart;&amp;bis=$m_nEnd;" onclick="return confirm('$trdelete ?')"><img src="/style/$m_sStyle/buttons/delete.png" border="0" alt="delete" title="$trdelete"/></a></td></tr>|;
        }
        $m_sContent .= qq|<tr><td><img src="/style/$m_sStyle/buttons/feil.gif" border="0" alt=""/></td>|;
        my $delete   = translate('delete');
        my $mmark    = translate('selected');
        my $markAll  = translate('select_all');
        my $umarkAll = translate('unselect_all');
        my $export   = translate('export');
        my $edit     = translate('edit');
        $m_sContent .= qq{
              <td colspan="$rws">
              <table align="center" border="0" cellpadding="0"  cellspacing="0" summary="layout" width="100%" ><tr>
              <td><a id="markAll" href="javascript:markInput(true);" class="links">$markAll</a><a class="links" id="umarkAll" style="display:none;" href="javascript:markInput(false);">$umarkAll</a>
              </td><td align="right">
              <select  name="MultipleAction"  onchange="if(this.value != '$mmark' )this.form.submit();">
              <option  value="$mmark" selected="selected">$mmark</option>
              <option value="delete">$delete</option>
              <option value="export">$export</option>
              </select>
              </td></tr></table>
        };
        $m_sContent .= qq|</td></tr></table></form></div>|;
        $m_sContent .= $window->windowFooter() . br();
    } else {
        ShowTables();
    }
}

=head2 MultipleAction()

Action:

MultipleAction

=cut

sub MultipleAction
{
    my $a      = param("MultipleAction");
    my @params = param();
    my $tbl    = param('table');
    my ($tbl2, @p_key);
    unless ($a eq "deleteUser") {
        $tbl2  = $m_dbh->quote_identifier($tbl);
        @p_key = $m_oDatabase->GetPrimaryKey($tbl);
    }
    my $window = new HTML::Window(
                                  {
                                   path     => $m_hrSettings->{cgi}{bin} . '/templates',
                                   style    => $m_sStyle,
                                   template => "wnd.htm",
                                   server   => $m_hrSettings->{serverName},
                                   id       => 'MultipleAction',
                                   class    => 'max',
                                  }
    );
    if ($a eq "export") {
        $m_sContent .= br() . $window->windowHeader();
        ShowDbHeader($tbl, 1, 'Export');
        $m_sContent .=
          qq(<div  class="dumpBox" style="padding-top:5px;width:100%;padding-right:2px;"><textarea style="width:100%;height:800px;overflow:auto;">);
    }
    for (my $i = 0; $i <= $#params; $i++) {
        if ($params[$i] =~ /markBox\d?/) {
            my $col = param($params[$i]);
            my @prims = split /\//, $col;
            $col = shift @prims;
            my $eid = "where ";
            if ($#p_key > 0) {
                for (my $j = 0; $j < $#p_key; $j++) {
                    $eid .= $m_dbh->quote_identifier($p_key[$j]) . ' = ' . $m_oDatabase->quote($prims[$j]) . ' && ';
                }
                $eid .= $m_dbh->quote_identifier($p_key[$#p_key]) . ' = ' . $m_oDatabase->quote($prims[$#p_key]);
            } else {
                $eid .= $m_dbh->quote_identifier($p_key[0]) . ' = ' . $m_oDatabase->quote($prims[0]);
            }
            SWITCH: {
                if ($a eq "delete") {
                    ExecSql("DELETE FROM $tbl2 $eid");
                    last SWITCH;
                }
                if ($a eq "deleteUser") {
                    my ($u, $h) = split /\//, $col;
                    $u = $m_oDatabase->quote($u);
                    $h = $m_oDatabase->quote($h);
                    $u .= "&& Host = $h" if ($h ne "NULL");
                    ExecSql("DELETE FROM mysql.user where user  = $u");
                    last SWITCH;
                }
                if ($a eq "truncate") {
                    ExecSql("truncate $tbl2");
                    last SWITCH;
                }
                if ($a eq "export") {
                    my $a       = $m_oDatabase->fetch_hashref("select * from $tbl2 $eid");
                    my @columns = $m_oDatabase->fetch_AoH("show columns from $tbl2");
                    $m_sContent .= "INSERT INTO $tbl (";
                    for (my $j = 0; $j <= $#columns; $j++) {
                        $m_sContent .= $m_dbh->quote_identifier($columns[$j]->{'Field'});
                        $m_sContent .= "," if ($j < $#columns);
                    }
                    $m_sContent .= ') values(';
                    for (my $j = 0; $j <= $#columns; $j++) {
                        $m_sContent .= $m_oDatabase->quote($a->{$columns[$j]->{'Field'}});
                        $m_sContent .= "," if ($j < $#columns);
                    }
                    $m_sContent .= ");$/";
                    last SWITCH;
                }
            }
        }
    }
    if ($a eq "export") {
        $m_sContent .= qq(</textarea>);
        $m_sContent .= '</div>' . $window->windowFooter();
    } elsif ($a eq "deleteUser") {
        ShowUsers();
    } else {
        ShowTable($tbl);
    }
}

=head2 MultipleDbAction()

Action:

MultipleDbAction

=cut

sub MultipleDbAction
{
    my $a      = param("MultipleDbAction");
    my @params = param();
    my %parameter = (
                     path     => $m_hrSettings->{cgi}{bin} . '/templates',
                     style    => $m_sStyle,
                     template => "wnd.htm",
                     server   => $m_hrSettings->{serverName},
                     id       => 'MultipleDbAction',
                     class    => 'max',
    );
    my $window = new HTML::Window(\%parameter);
    if ($a eq "export") {
        $m_sContent .= br() . $window->windowHeader();
        ShowDbHeader($m_sCurrentDb, 0, 'Export');
        $m_sContent .=
qq(<div align="left" class="dumpBox" style="width:100%;padding-top:5px;padding-right:2px;overflow:auto;"><textarea style="width:100%;height:800px;">);
    }
    if ($a eq "exportDb") {
        $m_sContent .= br() . $window->windowHeader();
        ShowDbHeader($m_sCurrentDb, 0, 'Export');
        $m_sContent .=
qq(<div align="left" class="dumpBox" style="width:100%;padding-top:5px;padding-right:2px;overflow:auto;"><textarea style="width:100%;height:800px;">);
    }
    for (my $i = 0; $i <= $#params; $i++) {
        if ($params[$i] =~ /markBox\d?/) {
            my $tbl  = param($params[$i]);
            my $tbl2 = $m_dbh->quote_identifier($tbl);
            SWITCH: {
                if ($a eq "dropDb") {
                    ExecSql("Drop database $tbl2");
                    last SWITCH;
                }
                if ($a eq "exportDb") {DumpDatabase($tbl);}
                if ($a eq "delete") {
                    ExecSql("Drop table $tbl2");
                    last SWITCH;
                }
                if ($a eq "export") {
                    DumpTable($tbl);
                    last SWITCH;
                }
                if ($a eq "truncate") {
                    ExecSql("Truncate $tbl2");
                    last SWITCH;
                }
                if ($a eq "optimize") {
                    ExecSql("OPTIMIZE TABLE $tbl2");
                    last SWITCH;
                }
                if ($a eq "analyze") {
                    ExecSql("ANALYZE TABLE $tbl2");
                    last SWITCH;
                }
                if ($a eq "repair") {
                    ExecSql("REPAIR TABLE $tbl2");
                    last SWITCH;
                }
            }
        }
    }
    if ($a eq "exportDb" || $a eq "export") {$m_sContent .= qq(</textarea></div>) . $window->windowFooter();}
    else {
        if   ($a eq "dropDb") {ShowDatabases();}
        else                  {ShowTables();}
    }
}

=head2 EditEntry()

Action:

     EditEntry( table, id )

=cut

sub EditEntry
{
    my $tbl = defined param('table') ? param('table') : shift;
    my $rid = defined param('edit')  ? param('edit')  : shift;
    if ($m_oDatabase->tableExists($tbl)) {
        my $tbl2    = $m_dbh->quote_identifier($tbl);
        my @caption = $m_oDatabase->fetch_AoH("show columns from $tbl2");
        my $eid     = "where ";
        my @p_key   = $m_oDatabase->GetPrimaryKey($tbl);
        if ($#p_key > 0) {
            for (my $j = 0; $j < $#p_key; $j++) {$eid .= "$p_key[$j] = " . $m_oDatabase->quote(param($p_key[$j])) . ' && ';}
            $eid .= "$p_key[$#p_key] = " . $m_oDatabase->quote(param($p_key[$#p_key]));
        } else {
            $eid .= "$p_key[0] = " . $m_oDatabase->quote(param($p_key[0]) ? param($p_key[0]) : $rid);
        }
        my $ed = translate('Edit Entry');
        my $a  = $m_oDatabase->fetch_hashref("select * from $tbl2 $eid");
        my %parameter = (
                         path     => $m_hrSettings->{cgi}{bin} . '/templates',
                         style    => $m_sStyle,
                         template => 'wnd.htm',
                         title    => translate("EditEntry"),
                         server   => $m_hrSettings->{serverName},
                         id       => 'EditEntry',
                         class    => 'none',
        );
        my $window = new HTML::Window(\%parameter);
        $RIBBONCONTENT .= br() . $window->windowHeader() . qq(
              <div align="center">
              <form action="$ENV{SCRIPT_NAME}" method="post"  enctype="multipart/form-data"><input type="hidden" name="action" value="SaveEntry"/>
              <input type="hidden" name="id" value="$rid"/>
              <input type="hidden" name="table" value="$tbl"/>
              <input type="hidden" name="von" value="$m_nStart"/>
              <input type="hidden" name="bis" value="$m_nEnd"/>
              <table align="center" border="0" cellpadding="2"  cellspacing="0" summary="layout">
                     <tr>
                            <td class="values" colspan="7">$ed</td>
                     </tr>
                     <tr>
                            <td class="caption">Field</td>
                            <td class="caption">Value</td>
                            <td class="caption">Type</td>
                            <td class="caption">Null</td>
                            <td class="caption">Key</td>
                            <td class="caption">Default</td>
                            <td class="caption">Extra</td>
                     </tr>
              );
        for (my $j = 0; $j <= $#caption; $j++) {
            SWITCH: {
                if ($caption[$j]->{'Type'} eq "text") {
                    $RIBBONCONTENT .=
qq(<tr><td class="values">$caption[$j]->{'Field'}</td><td class="values"><textarea name="tbl$caption[$j]->{'Field'}" >$a->{$caption[$j]->{'Field'}}</textarea></td><td class="values">$caption[$j]->{'Type'}</td><td>$caption[$j]->{'Null'}</td><td class="values">$caption[$j]->{'Key'}</td><td class="values">$caption[$j]->{'Default'}</td><td class="values">$caption[$j]->{'Extra'}</td></tr>);
                    last SWITCH;
                }
                $RIBBONCONTENT .=
qq(<tr><td class="values">$caption[$j]->{'Field'}</td><td class="values"><input type="text" name="tbl$caption[$j]->{'Field'}" value="$a->{$caption[$j]->{'Field'}}" align="left"/></td><td class="values">$caption[$j]->{'Type'}</td><td class="values">$caption[$j]->{'Null'}</td><td class="values">$caption[$j]->{'Key'}</td><td>$caption[$j]->{'Default'}</td><td class="values">$caption[$j]->{'Extra'}</td></tr>);
            }
        }
        my $trsave = translate('save');
        $RIBBONCONTENT .= qq(
              <tr>
                   <td colspan="7" align="right"><input type="submit" value="$trsave"/></td>
              </tr>
       </table>
       </form>
       </div>);
        $RIBBONCONTENT .= $window->windowFooter();
        ShowTable($tbl);
    } else {
        ShowTables();
    }
}

=head2 EditAction()

Action:

EditAction()

=cut

sub EditAction
{    #todo geht nicht
    my $name = defined param('name') ? param('name') : $m_sAction;
    unless ($m_sCurrentDb eq $m_hrSettings->{database}{name}) {
        ChangeDb(
                 {
                  name     => $m_hrSettings->{database}{name},
                  host     => $m_hrSettings->{database}{host},
                  user     => $m_hrSettings->{database}{user},
                  password => $m_hrSettings->{database}{password},
                 }
        );
    }
    my @id = $m_oDatabase->fetch_array("select id from `actions` where action=?", $name);
    if ($id[0] >= 0) {EditEntry('actions', $id[0]);}
    else             {ShowTable('actions');}
}

=head2 EditVertMenu()

Action:

EditAction()

=cut

sub EditVertMenu
{
    unless ($m_sCurrentDb eq $m_hrSettings->{database}{name}) {
        ChangeDb(
                 {
                  name     => $m_hrSettings->{database}{name},
                  host     => $m_hrSettings->{database}{host},
                  user     => $m_hrSettings->{database}{user},
                  password => $m_hrSettings->{database}{password},
                 }
        );
    }
    my $name = defined param('name') ? param('name') : $m_sAction;
    my @id = $m_oDatabase->fetch_array("select id from `navigation` where action=?", $name);
    if (defined $id[0]) {EditEntry('navigation', $id[0]);}
    else                {ShowTable('navigation');}
}

=head2 EditTopMenu()

Action:

EditTopMenu()

=cut

sub EditTopMenu
{
    unless ($m_sCurrentDb eq $m_hrSettings->{database}{name}) {
        ChangeDb(
                 {
                  name     => $m_hrSettings->{database}{name},
                  host     => $m_hrSettings->{database}{host},
                  user     => $m_hrSettings->{database}{user},
                  password => $m_hrSettings->{database}{password},
                 }
        );
    }
    my $name = defined param('name') ? param('name') : $m_sAction;
    my @id = $m_oDatabase->fetch_array("select id from `topnavigation` where action=?", $name);
    if (defined $id[0]) {EditEntry('topnavigation', $id[0]);}
    else                {ShowTable('topnavigation');}
}

=head2 ShowNewEntry()

Action:

ShowNewEntry(table)

=cut

sub ShowNewEntry
{
    my $tbl = param('table') ? param('table') : shift;
    if ($m_oDatabase->tableExists($tbl)) {
        my @caption  = $m_oDatabase->fetch_AoH("show columns from `$tbl`");
        my $newentry = translate('NewEntry');
        my %parameter = (
                         path     => $m_hrSettings->{cgi}{bin} . '/templates',
                         style    => $m_sStyle,
                         template => "wnd.htm",
                         server   => $m_hrSettings->{serverName},
                         id       => 'ShowNewEntry',
                         class    => 'none',
        );
        my $window = new HTML::Window(\%parameter);
        $m_sContent .= br() . $window->windowHeader();
        $m_sContent .= qq(
              <div align="center">
              <form action="$ENV{SCRIPT_NAME}?" method="get" name="action" enctype="multipart/form-data">
              <input type="hidden" name="action" value="NewEntry"/>
              <input type="hidden" name="table" value="$tbl"/>
              <input type="hidden" name="von" value="$m_nStart"/>
              <input type="hidden" name="bis" value="$m_nEnd"/>
              <table align="center" border="0" cellpadding="2"  cellspacing="0" summary="layout">
                     <tr><td colspan="7" align="left">$newentry</td></tr>
                     <tr><td class="caption">Field</td><td class="caption">Value</td><td class="caption">Type</td><td class="caption">Null</td><td class="caption">Key</td><td class="caption">Default</td><td class="caption">Extra</td></tr>);
        for (my $j = 0; $j <= $#caption; $j++) {
            SWITCH: {
                if ($caption[$j]->{'Type'} eq "text") {
                    $m_sContent .=
qq(<tr><td class="values" >$caption[$j]->{'Field'}</td><td><textarea name="tbl$caption[$j]->{'Field'}" value="" align="left" style="width:100%"></textarea></td><td>$caption[$j]->{'Type'}</td><td>$caption[$j]->{'Null'}</td><td>$caption[$j]->{'Key'}</td><td>$caption[$j]->{'Default'}</td><td>$caption[$j]->{'Extra'}</td></tr>);
                    last SWITCH;
                }
                $m_sContent .=
qq(<tr><td class="values" >$caption[$j]->{'Field'}</td><td><input type="text" name="tbl$caption[$j]->{'Field'}" value="" align="left"/></td><td>$caption[$j]->{'Type'}</td><td>$caption[$j]->{'Null'}</td><td>$caption[$j]->{'Key'}</td><td>$caption[$j]->{'Default'}</td><td>$caption[$j]->{'Extra'}</td></tr>);
            }
        }
        my $save = translate('save');
        $m_sContent .= qq(
            <tr><td colspan="7" align="RIGHT"><input type="submit" value="$save"/></td></tr>
            </table>
            </form>
            </div>);
        $m_sContent .= $window->windowFooter();
    } else {
        ShowTables();
    }
}

=head2 SaveEntry()

       Action

=cut

sub SaveEntry
{
    my @params = param();
    my $tbl    = param('table');
    if ($m_oDatabase->tableExists($tbl)) {
        my $i = 0;
        my @rows;
        my $eid   = "where ";
        my @p_key = $m_oDatabase->GetPrimaryKey($tbl);
        while ($i < $#params) {
            $i++;
            my $pa = param($params[$i]);
            if ($params[$i] =~ /tbl.*/) {
                $params[$i] =~ s/tbl//;
                if ($#p_key > 0) {
                    for (my $j = 0; $j < $#p_key; $j++) {$eid .= "$p_key[$j] = " . $m_oDatabase->quote($pa) . ' && ' if ($params[$i] eq $p_key[$j]);}
                    $eid .= "$p_key[$#p_key] = " . $m_oDatabase->quote($pa) if ($params[$i] eq $p_key[$#p_key]);
                } else {
                    $eid .= "$p_key[0] = " . $m_oDatabase->quote($pa) if ($params[$i] eq $p_key[0]);
                }
                unshift @rows, "" . $m_dbh->quote_identifier($params[$i]) . " = " . $m_oDatabase->quote($pa);
            }
        }
        $tbl   = $m_dbh->quote_identifier($tbl);
        $p_key = $m_dbh->quote_identifier($p_key);
        my $sql = "update $tbl set " . join(',', @rows) . " $eid";
        ExecSql($sql);
        ShowTable($tbl);
    } else {
        ShowTables();
    }
}

=head2 NewEntry()

       Action

=cut

sub NewEntry
{
    my @params = param();
    my $tbl    = param('table');
    if ($m_oDatabase->tableExists($tbl)) {
        $tbl = $m_dbh->quote_identifier($tbl);
        my $sql = "INSERT INTO $tbl VALUES(";
        my $i   = 0;
        while ($i < $#params) {
            $i++;
            my $pa = param($params[$i]);
            if ($params[$i] =~ /tbl.*/) {
                $params[$i] =~ s/tbl//;
                $sql .= $m_oDatabase->quote($pa);
                $sql .= "," if ($i < $#params);
            }
        }
        $sql .= ");";
        ExecSql($sql);
        ShowTable($tbl);
    } else {
        ShowTables();
    }
}

=head2 DeleteEntry()

       Action

=cut

sub DeleteEntry
{
    my $tbl = param('table') ? param('table') : shift;
    if ($m_oDatabase->tableExists($tbl)) {
        my $tbl2  = $m_dbh->quote_identifier($tbl);
        my $eid   = "where ";
        my @p_key = $m_oDatabase->GetPrimaryKey($tbl);
        if ($#p_key > 0) {
            for (my $j = 0; $j < $#p_key; $j++) {$eid .= "$p_key[$j] = " . $m_oDatabase->quote(param($p_key[$j])) . ' && ';}
            $eid .= "$p_key[$#p_key] = " . $m_oDatabase->quote(param($p_key[$#p_key]));
        } else {
            $eid .= "$p_key[0] = " . $m_oDatabase->quote(param($p_key[0]));
        }
        $p_key = $m_dbh->quote_identifier($p_key);
        ExecSql("DELETE FROM $tbl2 $eid");
        ShowTable($tbl);
    } else {
        ShowTables();
    }
}
use POSIX 'floor';

=head2 round()

dmit richtig sortiert wird.

=cut

sub round
{
    my $x = shift;
    floor($x + 0.5) if ($x =~ /\d+/);
}

=head2 ShowTables()

Action

=cut

sub ShowTables
{
    my @a = $m_oDatabase->fetch_AoH("SHOW TABLE STATUS");
    my %parameter = (
                     path     => $m_hrSettings->{cgi}{bin} . '/templates',
                     style    => $m_sStyle,
                     template => "wnd.htm",
                     server   => $m_hrSettings->{serverName},
                     id       => 'ShowTables',
                     class    => 'max',
    );
    my $window = new HTML::Window(\%parameter);
    $m_sContent .= br() . $window->windowHeader();
    my $orderby = defined param('orderBy')        ? param('orderBy')        : 'Name';
    my $state   = param('desc')                   ? 1                       : 0;
    my $nstate  = $state                          ? 0                       : 1;
    my $lpp     = defined param('links_pro_page') ? param('links_pro_page') : 30;
    $lpp = $lpp =~ /(\d\d\d?)/ ? $1 : $lpp;
    my $end = $m_nStart + $lpp > $#a ? $#a : $m_nStart + $lpp;

    if ($#a > $lpp) {
        my %needed = (
                      start          => $m_nStart,
                      length         => $#a,
                      style          => $m_sStyle,
                      mod_rewrite    => 0,
                      action         => "ShowTables",
                      append         => "&table=$tbl&links_pro_page=$lpp&orderBy=$field&desc=$state",
                      path           => $m_hrSettings->{cgi}{bin},
                      links_pro_page => $lpp,
        );
        $PAGES = makePages(\%needed);
    } else {
        $PAGES = '';
        $end   = $#a;
    }
    @a = sort {round($a->{$orderby}) <=> round($b->{$orderby})} @a;
    @a = reverse @a if $state;

    ShowDbHeader($m_sCurrentDb, 0, 'Show');
    $m_sContent .= div(
                      {align => 'right'},
                      translate('links_pro_page') 
                        . '&#160;|&#160;'
                        . (
                           $#a > 10
                           ? a(
                               {
                                href  => "$ENV{SCRIPT_NAME}?action=ShowTables&table=$tbl&links_pro_page=10&von=$m_nStart&orderBy=$field&desc=$state",
                                class => $lpp == 10 ? 'menuLink2' : 'menuLink3'
                               },
                               '10'
                             )
                           : ''
                        )
                        . (
                           $#a > 20
                           ? '&#160;'
                             . a(
                                 {
                                  href => "$ENV{SCRIPT_NAME}?action=ShowTables&table=$tbl&links_pro_page=20&von=$m_nStart&orderBy=$field&desc=$state",
                                  class => $lpp == 20 ? 'menuLink2' : 'menuLink3'
                                 },
                                 '20'
                             )
                           : ''
                        )
                        . (
                           $#a > 30
                           ? '&#160;'
                             . a(
                                 {
                                  href => "$ENV{SCRIPT_NAME}?action=ShowTables&table=$tbl&links_pro_page=30&von=$m_nStart&orderBy=$field&desc=$state",
                                  class => $lpp == 30 ? 'menuLink2' : 'menuLink3'
                                 },
                                 '30'
                             )
                           : ''
                        )
                        . (
                          $#a > 100
                          ? '&#160;'
                            . a(
                                {
                                 href => "$ENV{SCRIPT_NAME}?action=ShowTables&table=$tbl&links_pro_page=100&von=$m_nStart&orderBy=$field&desc=$state",
                                 class => $lpp == 100 ? 'menuLink2' : 'menuLink3'
                                },
                                '100'
                            )
                          : ''
                        )
    ) if $#a > 20;
    $m_sContent .= qq(
              <form action="$ENV{SCRIPT_NAME}" method="post" enctype="multipart/form-data">
              <input type="hidden" name="action" value="MultipleDbAction"/>
              <div align="center" style="padding-top:5px;overflow:auto;width:100%">
              <table align="left" border="0" cellpadding="2"  cellspacing="0" summary="ShowTables" width="100%">
              <tr>
              <td class="caption"></td>
              <td class="caption" > )
      . qq(<a href="$ENV{SCRIPT_NAME}?action=ShowTables&amp;table=$a[$i]->{Name}&amp;links_pro_page=$lpp&amp;von=$m_nStart&amp;orderBy=Name&amp;desc=$nstate">Name</a>)
      . (
           $orderby eq "Name"
         ? $state
               ? qq|&#160;<img src="/style/$m_sStyle/$m_nSize/mimetypes/up.png" border="0" alt="up" title="up" width="16" height="16"/>|
               : qq|&#160;<img src="/style/$m_sStyle/$m_nSize/mimetypes/down.png" border="0" alt="down" title="down" />|
         : ''
      )
      . qq(</td>
              <td class="caption"><a href="$ENV{SCRIPT_NAME}?action=ShowTables&amp;table=$a[$i]->{Name}&amp;links_pro_page=$lpp&amp;von=$m_nStart&amp;orderBy=Rows&amp;desc=$nstate">Rows</a>)
      . (
           $orderby eq "Rows"
         ? $state
               ? qq|&#160;<img src="/style/$m_sStyle/$m_nSize/mimetypes/up.png" border="0" alt="up" title="up" width="16" height="16"/>|
               : qq|&#160;<img src="/style/$m_sStyle/$m_nSize/mimetypes/down.png" border="0" alt="down" title="down" />|
         : ''
      )
      . q(</td>
              <td class="caption"> )
      . qq(<a href="$ENV{SCRIPT_NAME}?action=ShowTables&amp;table=$a[$i]->{Name}&amp;links_pro_page=$lpp&amp;von=$m_nStart&amp;orderBy=Type&amp;desc=$nstate">Type</a>)
      . (
           $orderby eq "Type"
         ? $state
               ? qq|&#160;<img src="/style/$m_sStyle/$m_nSize/mimetypes/up.png" border="0" alt="up" title="up" width="16" height="16"/>|
               : qq|&#160;<img src="/style/$m_sStyle/$m_nSize/mimetypes/down.png" border="0" alt="down" title="down"/>|
         : ''
      )
      . q(</td>
              <td class="caption"> )
      . qq(<a href="$ENV{SCRIPT_NAME}?action=ShowTables&amp;table=$a[$i]->{Name}&amp;links_pro_page=$lpp&amp;von=$m_nStart&amp;orderBy=Data_length&amp;desc=$nstate">Size (kb)</a>)
      . (
           $orderby eq "Size"
         ? $state
               ? qq|&#160;<img src="/style/$m_sStyle/$m_nSize/mimetypes/up.png" border="0" alt="up" title="up" width="16" height="16"/>|
               : qq|&#160;<img src="/style/$m_sStyle/$m_nSize/mimetypes/down.png" border="0" alt="down" title="down"/>|
         : ''
      )
      . q(</td>
              <td class="caption"></td>
              <td class="caption"></td>
              <td class="caption"></td>
              </tr>
    );

    for (my $i = $m_nStart; $i <= $end; $i++) {
        my $kb         = sprintf("%.2f", ($a[$i]->{Index_length} + $a[$i]->{Data_length}) / 1024);
        my $trdatabase = translate('database');
        my $trdelete   = translate('delete');
        my $change     = translate('EditTable');
        my $eid;
        if ($#p_key > 0) {
            for (my $j = 0; $j < $#p_key; $j++) {$eid .= "$p_key[$j]=$a[$i]->{$p_key[$j]}&amp;";}
            $eid .= "$p_key[$#p_key]=$a[$i]->{ $p_key[$#p_key]}";
        } else {
            $eid .= "$p_key[0]=$a[$i]->{$p_key[0]}";
        }
        $m_sContent .= qq(
              <tr onmouseover="this.className = 'overDb';" onmouseout="this.className = '';">
              <td width="20" class="values"><input type="checkbox" name="markBox$i" class="markBox" value="$a[$i]->{Name}" /></td>
              <td class="values"><a href="$ENV{SCRIPT_NAME}?action=ShowTable&amp;table=$a[$i]->{Name}&amp;desc=0">$a[$i]->{Name}</a></td>
              <td class="values">$a[$i]->{Rows}</td><td class="values">$a[$i]->{Engine}</td><td class="values">$kb</td>
              <td class="values" width="16"><a href="$ENV{SCRIPT_NAME}?action=DropTable&amp;table=$a[$i]->{Name}&amp;$eid" onclick="return confirm(' $trdelete?')"><img src="/style/$m_sStyle/buttons/delete.png" align="middle" alt="" border="0"/></a></td>
              <td class="values" width="16"><a href="$ENV{SCRIPT_NAME}?action=EditTable&amp;table=$a[$i]->{Name}&amp;$eid"><img src="/style/$m_sStyle/buttons/edit.png" border="0" alt="$change" title="$change"/></a></td>
              <td class="values" width="16"><a href="$ENV{SCRIPT_NAME}?action=ShowTableDetails&amp;table=$a[$i]->{Name}&amp;$eid"><img src="/style/$m_sStyle/buttons/details.png" border="0" alt="Details" title="Details" width="16" /></a></td>
              </tr>
       );
    }
    my $delete   = translate('delete');
    my $mmark    = translate('selected');
    my $markAll  = translate('select_all');
    my $umarkAll = translate('unselect_all');
    my $export   = translate('export');
    my $truncate = translate('truncate');
    my $optimize = translate('optimize');
    my $repair   = translate('repair');
    $m_sContent .= qq|
              <tr>
              <td><img src="/style/$m_sStyle/buttons/feil.gif" border="0" alt=""/></td>
              <td colspan="7" align="left">
              <table align="center" border="0" cellpadding="0"  cellspacing="0" summary="ShowTables" width="100%">
              <tr><td colspan="2" align="left">
              <a id="markAll" href="javascript:markInput(true);" class="links">$markAll</a><a class="links" id="umarkAll" style="display:none;" href="javascript:markInput(false);">$umarkAll</a></td>
              <td  align="right">
              <select name="MultipleDbAction" onchange="if(this.value != '$mmark' )this.form.submit();">
              <option value="$mmark" selected="selected">$mmark</option>
              <option value="delete">$delete</option>
              <option value="export">$export</option>
              <option value="truncate">$truncate</option>
              <option value="optimize">$optimize</option>
              <option value="repair">$repair</option>
              </select>
</td>
              </tr></table>
              </td>
              </tr>
              </table>
              </form>
              </div>
    |;
    $m_sContent .= $window->windowFooter();
}

=head2 DropTable()

action
       DropTable(table)

=cut

sub DropTable
{
    my $tbl = param('table');
    if ($m_oDatabase->tableExists($tbl)) {
        $tbl = $m_dbh->quote_identifier($tbl);
        ExecSql("drop table $tbl");
    }
    ShowTables();
}

=head2 ShowTableDetails()

action

       ShowTableDetails(table)

=cut

sub ShowTableDetails
{
    my $tbl = $_[0] ? shift : param('table');
    my %parameter = (
                     path     => $m_hrSettings->{cgi}{bin} . '/templates',
                     style    => $m_sStyle,
                     template => "wnd.htm",
                     server   => $m_hrSettings->{serverName},
                     id       => 'ShowTableDetails',
                     class    => 'max',
    );
    my $window = new HTML::Window(\%parameter);
    $m_sContent .= br() . $window->windowHeader();
    ShowDbHeader($tbl, 1, "Details");
    $m_sContent .= '<div align="center" style="padding-top:5px;width:100%;padding-right:2px;">';
    my $name = param('table');
    my @a    = $m_oDatabase->fetch_AoH("SHOW TABLE STATUS");
    $m_sContent .= qq(
              <table align="center" border="0" cellpadding="2"  cellspacing="0" summary="ShowTables">
              <tr><td colspan="2" align="left">$name</td></tr>
              <tr><td class="caption">Name</td><td class="caption">Value</td></tr>);

    for (my $i = 0; $i <= $#a; $i++) {
        if ($a[$i]->{Name} eq $name) {
            foreach my $key (keys %{$a[0]}) {
                $m_sContent .=
                  qq(<tr class="values" align="left"><td class="value" align="left">$key</td><td class="value" align="left">$a[$i]->{$key}</td></tr>);
            }
        }
    }
    $m_sContent .= '</table></div><br/>' . $window->windowFooter();
}

=head2 AddPrimaryKey()

action

       AddPrimaryKey(table,$col)

=cut

sub AddPrimaryKey
{
    my $tbl = $_[0] ? shift : param('table');
    my $col = $_[0] ? shift : param('column');
    if (defined $tbl && defined $col) {
        my $tbl2 = $m_dbh->quote_identifier($tbl);
        $col = $m_dbh->quote_identifier($col);
        ExecSql("ALTER TABLE  $tbl2 DROP PRIMARY KEY, ADD PRIMARY KEY($col) ");
        EditTable($tbl);
    } else {
        ShowTables();
    }
}

=head2 DropCol()

action

       DropCol(table,$col)

=cut

sub DropCol
{
    my $tbl = $_[0] ? shift : param('table');
    my $col = $_[0] ? shift : param('column');
    if (defined $tbl && defined $col) {
        my $tbl2 = $m_dbh->quote_identifier($tbl);
        $col = $m_dbh->quote_identifier($col);
        ExecSql("ALTER TABLE $tbl2 DROP COLUMN $col");
        EditTable($tbl);
    } else {
        ShowTables();
    }
}

=head2 TruncateTable()

action

       TruncateTable(table)

=cut

sub TruncateTable
{
    my $tbl = $_[0] ? shift : param('table');
    if ($m_oDatabase->tableExists($tbl)) {
        $tbl = $m_dbh->quote_identifier($tbl);
        ExecSql(" TRUNCATE TABLE $tbl");
    }
    ShowTables();
}

=head2 EditTable()

action

       EditTable(table)

=cut

sub EditTable
{
    my $tbl = $_[0] ? shift : param('table');
    if ($m_oDatabase->tableExists($tbl)) {
        my $tbl2     = $m_dbh->quote_identifier($tbl);
        my @caption  = $m_oDatabase->fetch_AoH("show full columns from $tbl2");
        my @p_key    = $m_oDatabase->GetPrimaryKey($tbl);
        my $newentry = translate('editTableProps');
        my $rename   = translate('rename');
        my $save     = translate('save');
        my %parameter = (
                         path     => $m_hrSettings->{cgi}{bin} . '/templates',
                         style    => $m_sStyle,
                         template => "wnd.htm",
                         server   => $m_hrSettings->{serverName},
                         id       => 'EditTable',
                         class    => 'max',
        );
        my $window = new HTML::Window(\%parameter);
        $m_sContent .= $window->windowHeader();
        ShowDbHeader($tbl, 1, "Edit");
        $m_sContent .= qq(
              <div  align="center" style="padding-top:5px;width:100%;padding-right:2px;">
              <table border="0" cellpadding="0" cellspacing="2" class="dataBaseTable">
              <tr >
              <td >);
        $m_sContent .= qq|
              <table cellspacing="0" border="0" cellpadding="2" width="100%">
              <tr>
              <td class="caption">Name</td>
              <td class="caption">Engine</td>
              <td class="caption">Auto_increment</td>
              </tr>
              <tr>
              <td class="values"><form action="" enctype="multipart/form-data" accept-charset="utf-8"><input type="hidden" name="action" value="RenameTable"/>
              <table border="0"  align="left"  cellpadding="2" cellspacing="0" class="dataBaseTable">
              <tr ><td class="values">
              <input type="hidden" name="table" value="$tbl"/><input type="text" align="bottom" name="newTable" value="$tbl"/></td><td><input type="submit" name="submit" value="$rename"/></td>
              </tr></table>
              </form></td>
              <td>
               <form action="$ENV{SCRIPT_NAME}" method="POST" enctype="multipart/form-data">
              <table border="0"  align="left"  cellpadding="2" cellspacing="0" class="dataBaseTable">
              <tr ><td class="values">|
          . $m_oDatabase->GetEngines($tbl, 'engine') . qq|
              </td><td class="values">
              <input type="submit" value="|
          . translate('ChangeEngine') . qq|"/>
              </td>
              </tr></table>
              <input type="hidden" value="ChangeEngine" name="action"/>
              <input type="hidden" value="$tbl" name="table"/>
              </form></td>|;
        $m_sContent .= qq|
              <td class="values"><form action="$ENV{SCRIPT_NAME}" method="POST" enctype="multipart/form-data">
                     <table border="0" align="left"  cellpadding="2" cellspacing="0" class="dataBaseTable">
                     <tr><td class="values">
                     <input type="text" value="|
          . $m_oDatabase->GetAutoIncrementValue($tbl) . qq|" name="AUTO_INCREMENT" style="width:40px"/>
                     </td><td class="values"><input type="hidden" value="$tbl" name="table"/>
                     <input type="hidden" value="ChangeAutoInCrementValue" name="action"/>
                     <input type="submit" value="|
          . translate('ChangeAutoInCrementValue') . qq|"/>
                     </form></td>
                     </tr></table>
              </td></tr></table>|;

        #                 $m_sContent
        #                     .= qq|<td class="values"><form action="$ENV{SCRIPT_NAME}" method="POST" enctype="multipart/form-data">
        #                        <table border="0" align="left" cellpadding="2" cellspacing="0" class="dataBaseTable">
        #                       <tr><td class="values">|
        #                     . $m_oDatabase->GetCollation($tbl,'charset') . qq|
        #                       </td>
        #                       <td class="values"><input type="submit" value="|
        #                     . translate('ChangeCharset') . qq|"/>
        #                       </td>
        #                       </tr></table>
        #                       <input type="hidden" value="$tbl" name="table"/>
        #                       <input type="hidden" value="ChangeCharset" name="action"/>
        #                       </form></td></table></td>|;
        $m_sContent .= qq(
              <tr><td >
              <form action="$ENV{SCRIPT_NAME}" method="post" enctype="multipart/form-data">
              <input type="hidden" name="action" value="SaveEditTable"/>
              <table border="0" cellpadding="0" cellspacing="0" class="dataBaseTable">
              <tr class="caption">
              <td class="caption">Field</td>
              <td class="caption">Type</td>
              <td class="caption">Length</td>
              <td class="caption">Null</td>
              <td class="caption">Default</td>
              <td class="caption">Extra</td>
              <td class="caption">Collation</td>
              <td class="caption">Attribute</td>
              <td class="caption">Comment</td>
              <td class="caption"><img src="/style/$m_sStyle/buttons/primary.png" alt="Add Primary Key"  title="Add Primary Key" width="16" height="16" align="left" border="0"/></td>
              <td class="caption"></td>
              </tr>
       );
        my %vars = (
                    user   => $m_sUser,
                    action => 'SaveEditTable',
                    table  => $tbl,
                    rows   => {}
        );
        sessionValidity(60 * 60 * 3);
        for (my $j = 0; $j <= $#caption; $j++) {
            my $field              = $caption[$j]->{'Field'};
            my $lght               = $caption[$j]->{'Type'};
            my $length             = ($lght =~ /\((\d+)\)/) ? $1 : '';
            my $m_hUniqueField     = Unique();
            my $m_hUniqueType      = Unique();
            my $m_hUniqueLength    = Unique();
            my $m_hUniqueNull      = Unique();
            my $m_hUniqueDefault   = Unique();
            my $m_hUniqueExtra     = Unique();
            my $m_hUniqueComment   = Unique();
            my $m_hUniqueCollation = Unique();
            my $m_hUniqueAttrs     = Unique();
            my $m_hUniquePrimary   = Unique();
            my $clm                = 0;
            for (my $j = 0; $j <= $#p_key; $j++) {$clm = 1 if $p_key[$j] eq $field;}
            $m_sContent .= qq|
              <tr class="values">
              <td><input type="text" value="$field" style="width:80px;" name="$m_hUniqueField"/></td>
              <td>|
              . $m_oDatabase->GetTypes($caption[$j]->{'Type'}, $m_hUniqueType) . qq|</td>
              <td><input type="text" value="$length" style="width:80px;" name="$m_hUniqueLength"/></td>
              <td>|
              . $m_oDatabase->GetNull($caption[$j]->{'Null'}, $m_hUniqueNull) . qq|</td>
              <td><input type="text" value="$caption[$j]->{'Default'}" style="width:80px;" name="$m_hUniqueDefault"/></td>
              <td>|
              . $m_oDatabase->GetExtra($caption[$j]->{'Extra'}, $m_hUniqueExtra) . '</td>
              <td>'
              . $m_oDatabase->GetColumnCollation($tbl, $field, $m_hUniqueCollation)
              . qq{</td> <td>}
              . $m_oDatabase->GetAttrs($tbl, $field, $m_hUniqueAttrs)
              . qq{</td>
              <td><input type="text" value="$caption[$j]->{Comment}" style="width:80px;" name="$m_hUniqueComment"/></td><td>}
              . (
                 $clm
                 ? qq|<input align="left" type="checkbox"   name="$m_hUniquePrimary" title="Primary Key"  checked="checked"/>|
                 : qq|<input align="left" type="checkbox"   name="$m_hUniquePrimary" title="Primary Key"/> |
              )
              . qq{</td><td><a href="?action=AddFulltext;&amp;table=$tbl&amp;column=$field" title="Add fulltext $field" title="Add fulltext"><img src="/style/$m_sStyle/buttons/fulltext.png" alt="Add fulltext" width="16" height="16" align="left" border="0"/></a>
              <a href="?action=AddIndex;&amp;table=$tbl&amp;column=$field" title="Add Index $field"><img src="/style/$m_sStyle/buttons/index.png" alt="Add Index" width="16" height="16" align="left" border="0"/></a>
              <a href="?action=AddUnique;&amp;table=$tbl&amp;column=$field" title="Add Unique $field" ><img src="/style/$m_sStyle/buttons/unique.png" alt="Add Unique" width="16" height="16" align="left" border="0"/></a>
              <a href="?action=DropCol;&amp;table=$tbl&amp;column=$field" onclick="return confirm('Delete $field')" title="Drop Column $field" ><img src="/style/$m_sStyle/buttons/delete.png" alt="Delete $field" width="16" height="16" align="left" border="0"/></a>
              </td>
              </tr>
};
            $vars{rows}{$field} = {
                                   Field     => $m_hUniqueField,
                                   Type      => $m_hUniqueType,
                                   Length    => $m_hUniqueLength,
                                   Null      => $m_hUniqueNull,
                                   Default   => $m_hUniqueDefault,
                                   Extra     => $m_hUniqueExtra,
                                   Comment   => $m_hUniqueComment,
                                   Collation => $m_hUniqueCollation,
                                   Attrs     => $m_hUniqueAttrs,
                                   Primary   => $m_hUniquePrimary,
            };
        }
        clearSession();
        my $qstring = createSession(\%vars);
        $m_sContent .= qq(
              <tr><td colspan="11" align="right" style="padding-top:2px;">
              <input type="submit" value="$save" align="right"/>
              <input type="hidden" name="change_col_sessionRTZHBG" value="$qstring"/>
              </form>
              </td></tr>
              <tr><td colspan="10" align="right" style="padding-top:2px;">
       );
        my $newCol = translate('newcol');
        $m_sContent .= qq(
              <div align="center">
              <form action="$ENV{SCRIPT_NAME}" method="post" enctype="multipart/form-data">
              <input type="hidden" name="action" value="SaveNewColumn"/>
              <table border="0" cellpadding="2" cellspacing="0" class="dataBaseTable" width="100%">
              <tr ><td colspan="10" align="left">$newCol</td></tr>
              <tr class="caption">
              <td class="caption">Field</td>
              <td class="caption">Type</td>
              <td class="caption">LENGTH</td>
              <td class="caption">Null</td>
              <td class="caption">Default</td>
              <td class="caption">Extra</td>
              <td class="caption">Collation</td>
              <td class="caption">Attribute</td>
              <td class="caption">Comment</td>
              </tr>
       );
        sessionValidity(60 * 60);
        my $m_hUniqueRadio      = Unique();
        my $m_hUniqueColField   = Unique();
        my $m_hUniqueColType    = Unique();
        my $m_hUniqueColLength  = Unique();
        my $m_hUniqueColNull    = Unique();
        my $m_hUniqueColKey     = Unique();
        my $m_hUniqueColDefault = Unique();
        my $m_hUniqueColExtra   = Unique();
        my $m_hUniqueColComment = Unique();
        my $m_hUniqueColAttrs   = Unique();
        $m_sContent .= qq|
              <tr>
              <td class="values"><input type="text" value="" name="$m_hUniqueColField" style="width:100px;"/></td>
              <td class="values">|
          . $m_oDatabase->GetTypes('INT', $m_hUniqueColType) . qq{</td>
              <td class="values"><input type="text" value="" style="width:80px;" name="$m_hUniqueColLength"/></td>
              <td class="values">
              <select name="$m_hUniqueColNull" style="width:80px;">
              <option  value="not NULL">not NULL</option>
              <option value="NULL">NULL</option>
              </select>
              </td>
              <td class="values"><input type="text" value="" id="default" onkeyup="intputMaskType('default','$m_hUniqueColType')" name="$m_hUniqueColDefault" style="width:80px;"/></td>
              <td class="values">
              <select name="$m_hUniqueColExtra" style="width:80px;">
              <option value=""></option>
              <option value="auto_increment">auto_increment</option>
              </select>
              </td>
        };
        my $m_hUniqueColCollation = Unique();
        my $m_hUniqueColEngine    = Unique();
        my $qstringCol = createSession(
                                       {
                                        user      => $m_sUser,
                                        action    => 'SaveNewColumn',
                                        table     => $tbl,
                                        Collation => $m_hUniqueColCollation,
                                        Engine    => $m_hUniqueColEngine,
                                        Primary   => $m_hUniqueColRadio,
                                        rows      => {
                                                 Field   => $m_hUniqueColField,
                                                 Type    => $m_hUniqueColType,
                                                 Length  => $m_hUniqueColLength,
                                                 Null    => $m_hUniqueColNull,
                                                 Key     => $m_hUniqueColKey,
                                                 Default => $m_hUniqueColDefault,
                                                 Extra   => $m_hUniqueColExtra,
                                                 Comment => $m_hUniqueColComment,
                                                 Attrs   => $m_hUniqueColAttrs,
                                        }
                                       }
        );
        my $sStart    = translate('startTable');
        my $sEnde     = translate('endTable');
        my $sInsert   = translate('insertAfter');
        my $sAfter    = translate('after');
        my $si        = translate('insert');
        my $collation = $m_oDatabase->GetCollation($m_hUniqueColCollation);
        my $atrrs     = $m_oDatabase->GetAttrs($tbl, "none", $m_hUniqueColAttrs);
        my $clmns     = $m_oDatabase->GetColumns($tbl, 'after_name');
        $m_sContent .= qq(
              <td class="values">$collation</td>
              <td class="values">$atrrs</td>
              <td class="values"><input type="text" value="" name="$m_hUniqueColComment" align="left" style="width:80px;"/><br/></td>
              </tr>
              <tr>
              <td colspan="10"  >
              $sInsert&#160;$sStart<input type="radio" class="radioButton" value="first"  name="after_col" />&#160;
              $sEnde&#160;<input type="radio" class="radioButton" value="last"  name="after_col" checked="checked"/>&#160;
              $sAfter&#160;<input type="radio" class="radioButton" value="after"  name="after_col"/>
              $clmns&#160;
              <input type="submit" value="$si"/>
              </td>
              </td>
              </tr>
              </table>
              <input type="hidden" name="create_new_col_seesion" value="$qstringCol"/>
              </form>
              </div>
              </td></tr>
              </table>
              </form>
              </td></tr></table>
              </div>
       ) . br();
        my @index = $m_oDatabase->fetch_AoH("SHOW INDEX FROM $tbl2");
        $m_sContent .= '<table align="center" border="0" cellpadding="2" cellspacing="0" class="indexTable">';
        $m_sContent .= '
        <tr class="caption">
           <td class="caption">Non_unique</td>
           <td class="caption">Key_name</td>
           <td class="caption">Seq_in_index</td>
           <td class="caption">Column_name</td>
           <td class="caption">Cardinality</td>
           <td class="caption">Sub_part</td>
           <td class="caption">Packed</td>
           <td class="caption">Null</td>
           <td class="caption">Index_type</td>
           <td class="caption">Comment</td>
           <td class="caption"></td>
           <td class="caption"></td>
       </tr>';
        $m_sContent .= qq|
       <tr onmouseover="this.className='overDb';" onmouseout="this.className='';">
       <td class="values">$_->{'Non_unique'}</td>
       <td class="values">$_->{'Key_name'}</td>
       <td class="values">$_->{'Seq_in_index'}</td>
       <td class="values">$_->{'Column_name'}</td>
       <td class="values">$_->{'Cardinality'}</td>
       <td class="values">$_->{'Sub_part'}</td>
       <td class="values">$_->{'Packed'}</td>
       <td class="values">$_->{'Null'}</td>
       <td class="values">$_->{'Index_type'}</td>
       <td class="values">$_->{'Comment'}</td>
       <td class="values"><a href="$ENV{SCRIPT_NAME}?action=ShowEditIndex;&amp;tbl=$tbl&amp;index=$_->{'Key_name'}&amp;editIndexOlp145656=1" title="Edit Index $_->{'Key_name'}"><img src="/style/$m_sStyle/buttons/edit.png" alt="Edit Index $_->{'Key_name'}" width="16" height="16" align="left" border="0"/></a></td>
       <td class="values"><a href="$ENV{SCRIPT_NAME}?action=DropIndex;&amp;table=$tbl&amp;index=$_->{'Key_name'}" title="Drop Index $_->{'Key_name'}"><img src="/style/$m_sStyle/buttons/delete.png" alt="Drop Index $_->{'Key_name'}" width="16" height="16" align="left" border="0"/></a></td>
       </tr>| foreach @index;
        $m_sContent .= '</table>';
        my $sIndexOver = translate('IndexOver');
        my $sSubmit    = translate('create');
        $m_sContent .= qq|
              <div align="center"><form action="$ENV{SCRIPT_NAME}" method="post" enctype="multipart/form-data">
              $sIndexOver&#160;<input type="text" class="text" value="1"  name="over_cols" style="width:40px"/>&#160;
              &#160;<input type="submit" class="button" value="$sSubmit"  name="submit"/>
              <input type="hidden" value="ShowEditIndex" name="action"/>
              <input type="hidden" value="$tbl" name="tbl"/>
              </form></div>
       |;
        $m_sContent .= $window->windowFooter();
    } else {
        ShowTables();
    }
}

=head2 ShowEditIndex()

action

=cut

sub ShowEditIndex
{
    my %parameter = (
                     path     => $m_hrSettings->{cgi}{bin} . '/templates',
                     style    => $m_sStyle,
                     template => 'wnd.htm',
                     title    => translate("NewIndex"),
                     server   => $m_hrSettings->{serverName},
                     id       => 'NewIndex',
                     class    => 'none',
    );
    my $window = new HTML::Window(\%parameter);
    $RIBBONCONTENT .= $window->windowHeader();
    my $tbl                = param('tbl');
    my $tbl2               = $m_dbh->quote_identifier($tbl);
    my $cls                = param('over_cols');
    my $m_hUniqueTyp       = Unique();
    my $m_hUniqueIndexName = Unique();
    my $sField             = translate('field');
    my $sSize              = translate('size');
    my $sName              = translate('name');
    my $sTyp               = translate('type');
    my $iname              = param('index') ? param('index') : '';
    my $hashref            = $m_oDatabase->fetch_hashref("SHOW INDEX FROM $tbl2 where `Key_name` = ?", $iname);
    $RIBBONCONTENT .= qq|
              <div align="center">
              <form action="$ENV{SCRIPT_NAME}" method="post" enctype="multipart/form-data">
              <table cellspacing="0" cellpadding="2" border="0" align="center" summary="ShowEditIndex" width="100%">
                     <tr><td>
                            $sName&#160; <input type="text" value="$iname" name="$m_hUniqueIndexName"/>
                     </td><td>
                            $sTyp&#160;
                            <select name="$m_hUniqueTyp">
                            <option  value="PRIMARY" |
      . ($hashref->{Key_name} eq 'PRIMARY' ? 'selected="selected"' : '') . qq|>PRIMARY</option>
                            <option value="INDEX" |
      . ($hashref->{Index_type} eq 'BTREE' ? 'selected="selected"' : '') . qq|>INDEX</option>
                            <option value="UNIQUE" >UNIQUE</option>
                            <option value="FULLTEXT" |
      . ($hashref->{Index_type} eq 'FULLTEXT' ? 'selected="selected"' : '') . qq|>FULLTEXT</option>
                            </select>
                     </td></tr>
                     <tr><td class="caption">$sField</td><td class="caption">$sSize</td></tr>
       |;

    if (param('editIndexOlp145656')) {
        my $keyName = param('index');
        my @index   = $m_oDatabase->fetch_AoH("SHOW INDEX FROM $tbl2");
        for (my $i = 0; $i < $#index; ++$i) {
            next if $index[$i]->{Key_name} ne $keyName;
            my $uName   = Unique();
            my $uSize   = Unique();
            my $columns = $m_oDatabase->GetColumns($tbl, $uName, $index[$i]->{Column_name});
            $RIBBONCONTENT .=
qq|<tr><td class="values">$columns</td><td class="values"><input type="text" value="$index[$i]->{Sub_part}" name="$uSize" style="width:40px;"/></td></tr>|;
            push @FILDS,
              {
                name => $uName,
                size => $uSize,
              };
        }
    } else {
        for (my $i = 0; $i < $cls; $i++) {
            my $uName   = Unique();
            my $uSize   = Unique();
            my $columns = $m_oDatabase->GetColumns($tbl, $uName,);
            $RIBBONCONTENT .= qq|<tr><td>$columns</td><td><input type="text" value="" name="$uSize" style="width:40px;"/></td></tr>|;
            push @FILDS,
              {
                name => $uName,
                size => $uSize,
              };
        }
    }
    my $qstring = createSession(
                                {
                                 user   => $m_sUser,
                                 action => 'SaveNewIndex',
                                 table  => $tbl,
                                 name   => $m_hUniqueIndexName,
                                 typ    => $m_hUniqueTyp,
                                 fields => [@FILDS],
                                }
    );
    my $ers = translate('createIndex');
    $RIBBONCONTENT .= qq|
                     <tr><td colspan="2" align="right"><input type="submit" class="button" value="$ers" name="submit"/></td></tr>
                     </table>
                     <input type="hidden" value="SaveNewIndex" name="action"/>
                     <input type="hidden" value="$qstring" name="save_new_indexhjfgzu"/>
                     <input type="hidden" value="$iname" name="oldname"/>
      |;
    $RIBBONCONTENT .= '<input type="hidden" value="1" name="editIndexOlp145656"/>' if param('editIndexOlp145656');
    $RIBBONCONTENT .= '</form></div>' . $window->windowFooter();
    EditTable($tbl);
}

=head2 SaveNewIndex()

action

=cut

sub SaveNewIndex
{
    my $session = param('save_new_indexhjfgzu');
    session($session, $m_sUser);
    my $tbl = $m_hrParams->{table};
    if (defined $tbl and defined $session) {
        my $tbl2  = $m_dbh->quote_identifier($tbl);
        my $name  = $m_dbh->quote_identifier(param($m_hrParams->{name}));
        my $oname = $m_dbh->quote_identifier(param('oldname'));
        my $typ   = param($m_hrParams->{typ});
        my $sql =
            qq|ALTER TABLE $tbl2 |
          . (param('editIndexOlp145656') ? (param('oldname') eq 'PRIMARY' ? 'DROP PRIMARY KEY' : "DROP INDEX $oname,") : '') . " ADD "
          . ($typ eq 'PRIMARY' ? 'PRIMARY KEY' : "$typ $name") . "(";
        for (my $i = 0; $i <= $#{$m_hrParams->{fields}}; $i++) {
            my $field = $m_dbh->quote_identifier(param($m_hrParams->{fields}[$i]{name}));
            my $m_nSize = param($m_hrParams->{fields}[$i]{size}) =~ /(\d+)/ ? $1 : 0;
            $sql .= qq|$field|;
            $sql .= qq|($m_nSize)| if $m_nSize;
            $sql .= ',' unless $i == $#{$m_hrParams->{fields}};
        }
        $sql .= ')';
        ExecSql($sql);
        EditTable($tbl);
    } else {
        ShowTables();
    }
}

=head2 SaveEditTable()

action

=cut

sub SaveEditTable
{
    my $session = param('change_col_sessionRTZHBG');
    session($session, $m_sUser);
    my $tbl = $m_hrParams->{table};
    if (defined $tbl and defined $session) {
        my $tbl2 = $m_dbh->quote_identifier($tbl);
        my $sql;
        my @prims;
        foreach my $row (keys %{$m_hrParams->{rows}}) {
            my $newrow = param($m_hrParams->{rows}{$row}{Field});
            my $type   = param($m_hrParams->{rows}{$row}{Type});
            my $length = param($m_hrParams->{rows}{$row}{Length});
            $type = $type =~ /Blob|TEXT|TIMESTAMP/ ? $type : $length ? $type . "($length)" : $type;
            my $character_set = $m_oDatabase->GetCharacterSet(param($m_hrParams->{rows}{$row}{Collation}));
            my $collation     = param($m_hrParams->{rows}{$row}{Collation});
            my $null          = param($m_hrParams->{rows}{$row}{Null});
            my $comment       = param($m_hrParams->{rows}{$row}{Comment});
            my $extra         = param($m_hrParams->{rows}{$row}{Extra});
            my $default       = param($m_hrParams->{rows}{$row}{Default});
            my $attrs         = param($m_hrParams->{rows}{$row}{Attrs});
            my $row2          = $m_dbh->quote_identifier($row);
            my $newrow2       = $m_dbh->quote_identifier($newrow);
            my $prim          = param($m_hrParams->{rows}{$row}{Primary});
            push @prims, $newrow if $prim eq 'on';
            $default = (($default || $default =~ /0/) && $default ne "CURRENT_TIMESTAMP") ? ' default ' . $m_dbh->quote($default) : '';
            my $vcomment = $m_dbh->quote($comment);
            $sql .= "ALTER TABLE $tbl2 CHANGE $row2 $newrow2 $type";
            $sql .= " auto_increment " if $extra eq 'auto_increment';
            if ($collation) {$sql .= " CHARACTER SET $character_set COLLATE $collation" unless $character_set eq 'binary' or $collation eq 'NULL';}
            $sql .= " $attrs";
            $sql .= " $null ";
            $sql .= " COMMENT $vcomment" if $comment;
            $sql .= $default if $default;
            $sql .= ";$/";
        }
        my $key = join(' , ', @prims);
        $sql .= "ALTER TABLE $tbl2 DROP PRIMARY KEY, ADD constraint PRIMARY KEY ($key);$/";
        ExecSql($sql);
        EditTable($tbl);
    } else {
        ShowTables();
    }
}

=head2 SaveNewColumn()

action

=cut

sub SaveNewColumn
{
    my $session   = param('create_new_col_seesion');
    my $after_col = param('after_col');
    session($session, $m_sUser);
    my $tbl = $m_hrParams->{table};
    if (defined $tbl and defined $session) {
        my $tbl2 = $m_dbh->quote_identifier($tbl);
        my $sql;
        my $newrow = param($m_hrParams->{rows}{Field});
        my $type   = param($m_hrParams->{rows}{Type});
        my $length = param($m_hrParams->{rows}{Length});
        $type = $type =~ /Blob|TEXT|TIMESTAMP/ ? $type : $length ? $type . "($length)" : $type;
        my $character_set = $m_oDatabase->GetCharacterSet(param($m_hrParams->{Collation}));
        my $collation     = param($m_hrParams->{Collation});
        my $null          = param($m_hrParams->{rows}{Null});
        my $comment       = param($m_hrParams->{rows}{Comment});
        my $extra         = param($m_hrParams->{rows}{Extra});
        my $default       = param($m_hrParams->{rows}{Default});
        my $attrs         = param($m_hrParams->{rows}{Attrs});
        my $newrow2       = $m_dbh->quote_identifier($newrow);
        $default = (($default || $default =~ /0/) && $default ne "CURRENT_TIMESTAMP") ? ' default ' . $m_dbh->quote($default) : '';
        my $vcomment = $m_dbh->quote($comment);
        $sql .= "ALTER TABLE $tbl2 ADD  $newrow2 $type";
        $sql .= " auto_increment " if $extra eq 'auto_increment';
        if ($collation) {$sql .= " CHARACTER SET $character_set COLLATE $collation" unless ($character_set eq 'binary' or $collation eq 'NULL');}
        $sql .= " $attrs";
        $sql .= " $null ";
        $sql .= " COMMENT $vcomment" if $comment;
        $sql .= $default if $default;
        $sql .= ' first' if $after_col eq ' first';
        $sql .= 'after ' . param('after_name') if $after_col eq 'after';
        $sql .= ";$/";
        ExecSql($sql);
        EditTable($tbl);
    } else {
        ShowTables();
    }
}

=head2 RenameTable()

action

=cut

sub RenameTable
{
    my $tbl    = param('table')    ? param('table')    : shift;
    my $newtbl = param('newTable') ? param('newTable') : shift;
    if (defined $tbl && defined $newtbl) {
        my $tbl2    = $m_dbh->quote_identifier($tbl);
        my $newtbl2 = $m_dbh->quote_identifier($newtbl);
        ExecSql("ALTER TABLE $tbl2 RENAME $newtbl2;");
        EditTable($newtbl);
    } else {
        ShowTables();
    }
}

=head2 ChangeEngine()

action

=cut

sub ChangeEngine
{
    my $tbl    = param('table')  ? param('table')  : shift;
    my $engine = param('engine') ? param('engine') : shift;
    if (defined $engine && defined $tbl) {
        my $tbl2 = $m_dbh->quote_identifier($tbl);
        $engine = $m_oDatabase->quote($engine);
        ExecSql("ALTER TABLE $tbl2 ENGINE = $engine");
        EditTable($tbl);
    } else {
        ShowTables();
    }
}

=head2 ChangeAutoInCrementValue()

action

=cut

sub ChangeAutoInCrementValue
{
    my $tbl   = param('table')          ? param('table')          : shift;
    my $p_key = param('AUTO_INCREMENT') ? param('AUTO_INCREMENT') : shift;
    if (defined $p_key && defined $tbl) {
        my $tbl2 = $m_dbh->quote_identifier($tbl);
        ExecSql("ALTER TABLE $tbl2 AUTO_INCREMENT = $p_key");
        EditTable($tbl);
    } else {
        ShowTables();
    }
}

#Html elemente

=head2 ShowDbHeader()

        gibt die navigationszeile für eine tabelle aus

=cut

sub ShowDbHeader
{
    my $tbl      = shift;
    my $selected = shift;
    my $current  = shift;
    my %parameter = (
                     style      => $m_sStyle,
                     path       => "$m_hrSettings->{cgi}{bin}/templates",
                     template   => 'ribbon.htm',
                     action     => $m_sAction,
                     scriptname => $ENV{SCRIPT_NAME},
                     style      => $m_sStyle,
                     path       => "$m_hrSettings->{cgi}{bin}/templates",
                     template   => 'ribbon.htm',
                     action     => $m_sAction,
                     scriptname => $ENV{SCRIPT_NAME},
                     anchors    => [
                                 {
                                  text    => translate('database'),
                                  src     => 'link.png',
                                  href    => 'javascript:void(0);',
                                  onclick => "showDatabaseMenu(this.id)",
                                  class   => $selected || param('sql') ? 'link' : 'currentLink',
                                 },
                                 {
                                  text    => translate('Sql'),
                                  onclick => "showSqlEditor(this.id)",
                                  href    => 'javascript:void(0);',
                                  class   => param('sql') ? 'currentLink' : 'link',
                                 },
                     ],
    );
    push @{$parameter{anchors}},
      {
        text    => translate('table'),
        onclick => "showTableMenu(this.id)",
        class   => 'currentLink',
        href    => 'javascript:void(0);',
      }
      if $selected;
    my $rb = new HTML::TabWidget();
    $m_sContent .= $rb->Menu(\%parameter);
    $m_sContent .= tabwidgetHeader();
    $m_sContent .= '<div id="TableMenu" ' . ($selected ? 'style="width:100%;"' : 'style="display:none;width:100%;"') . '>';
    $m_sContent .= a(
                     {
                      class => $current eq "Show" ? 'currentLink' : 'link',
                      href  => "$ENV{SCRIPT_NAME}?action=ShowTable&amp;table=$tbl",
                      title => translate("Show") . "($tbl)"
                     },
                     translate("Daten") . "($tbl)"
    ) . '&#160;|&#160;';
    $m_sContent .= a(
                     {
                      class => $current eq "Edit" ? 'currentLink' : 'link',
                      href  => "$ENV{SCRIPT_NAME}?action=EditTable&amp;table=$tbl",
                      title => translate("Edit")
                     },
                     translate("Edit")
    ) . '&#160;|&#160;';
    $m_sContent .= a(
                     {
                      class => $current eq "Details" ? 'currentLink' : 'link',
                      href  => "$ENV{SCRIPT_NAME}?action=ShowTableDetails&amp;table=$tbl",
                      title => translate("Details")
                     },
                     translate("Details")
    ) . '&#160;|&#160;';
    $m_sContent .= a(
                     {
                      class => $current eq "Export" ? 'currentLink' : 'link',
                      href  => "$ENV{SCRIPT_NAME}?action=ShowDumpTable&amp;table=$tbl",
                      title => translate("Export")
                     },
                     translate("Export")
    ) . '&#160;|&#160;';
    $m_sContent .= a(
                     {
                      class => $current eq "AnalyzeTable" ? 'currentLink' : 'link',
                      href  => "$ENV{SCRIPT_NAME}?action=AnalyzeTable&amp;table=$tbl",
                      title => translate("AnalyzeTable")
                     },
                     translate("AnalyzeTable")
    ) . '&#160;|&#160;';
    $m_sContent .= a(
                     {
                      class => $current eq "OptimizeTable" ? 'currentLink' : 'link',
                      href  => "$ENV{SCRIPT_NAME}?action=OptimizeTable&amp;table=$tbl",
                      title => translate("OptimizeTable")
                     },
                     translate("OptimizeTable")
    ) . '&#160;|&#160;';
    $m_sContent .= a(
                     {
                      class => $current eq "RepairTable" ? 'currentLink' : 'link',
                      href  => "$ENV{SCRIPT_NAME}?action=RepairTable&amp;table=$tbl",
                      title => translate("RepairTable")
                     },
                     translate("RepairTable")
    ) . '&#160;|&#160;';
    $m_sContent .= a(
                     {
                      class => $current eq "NewEntry" ? 'currentLink' : 'link',
                      href  => "javascript:showNewEntry()",
                      title => translate("showNewEntry")
                     },
                     translate("NewEntry")
    ) . '&#160;|&#160;';
    $m_sContent .= a(
                     {
                      href    => "$ENV{SCRIPT_NAME}?action=DropTable&amp;table=$tbl",
                      title   => translate("Delete"),
                      onclick => "return confirm('" . translate("Delete") . "?')"
                     },
                     translate("Delete")
    );
    $m_sContent .= qq|</div><div id="NewEntry" style="display:none;">|;
    &ShowNewEntry($tbl) if $m_oDatabase->tableExists($tbl);
    $m_sContent .= qq|</div><div id="DatabaseMenu" | . ($selected ? 'style="display:none;width:100%;"' : 'style="width:100%"') . '>';
    $m_sContent .= a(
                     {
                      class => $current eq "ShowDatabases" ? 'currentLink' : 'link',
                      href  => "$ENV{SCRIPT_NAME}?action=ShowDatabases",
                      title => translate("Databases")
                     },
                     translate("Databases")
    ) . '&#160;|&#160;';
    $m_sContent .= a(
                     {
                      class => $current eq "Show" ? 'currentLink' : 'link',
                      href  => "$ENV{SCRIPT_NAME}?action=ShowTables&database=$m_sCurrentDb",
                      title => translate("ShowTables") . "($m_sCurrentDb)"
                     },
                     translate("Database") . "($m_sCurrentDb)"
    ) . '&#160;|&#160;';
    $m_sContent .= a(
                     {
                      class => $current eq "ShowUsers" ? 'currentLink' : 'link',
                      href  => "$ENV{SCRIPT_NAME}?action=ShowUsers&database=$m_sCurrentDb",
                      title => translate('ShowUsers') . "($m_sCurrentDb)"
                     },
                     translate('ShowUsers') . "($m_sCurrentDb)"
    ) . '&#160;|&#160;';
    $m_sContent .= a(
                     {
                      class => $current eq "Export" ? 'currentLink' : 'link',
                      href  => "$ENV{SCRIPT_NAME}?action=ShowDumpDatabase&database=$m_sCurrentDb",
                      title => translate("ExportDatabase"),
                     },
                     translate("Export")
    );
    my $sql      = defined param('sql') ? param('sql') : $SQL;
    my $exec     = translate('ExecSql');
    my $newtable = translate('CreateTable');
    my $newUser  = translate('createuser');
    my $connect  = translate('connect');
    my $fields   = translate('fields');
    $m_sContent .= qq|<br/>
   <table align="left" border="0" cellspacing="5" cellpadding="0"  summary="layout">
    <tr>  <td valign="top">
    <table align="left" border="0" cellspacing="5" cellpadding="0"  summary="layout" >
    <tr>
    <td valign="top" align="left">
<form name="CreateDatabase" action="$ENV{SCRIPT_NAME}" method="post" enctype="multipart/form-data" onsubmit="return CheckFormCreateDatabase()">
<table align="left" border="0" cellspacing="0" cellpadding="2"  summary="newTable">
    <tr>
      <td class="caption" colspan="4" onclick="DisplayDbHeader('CreateDatabase')" style="cursor:pointer;">|
      . translate('CreateDatabase') . qq|</td>
    </tr>
    <tr id="CreateDatabase" style="display:none;">
      <td class="values"><input type="text" name="name" value="|
      . translate('name') . qq|" onfocus="this.value=''" style="width:120px;" /></td>
      <td class="values"><input type="submit" name="submit" value="|
      . translate('create') . qq|" /></td>
    </tr>
</table>
<input type="hidden" name="action" value="CreateDatabase" />
</form>
</td>
<td valign="top" align="left">
<form name="CreateUser" action="$ENV{SCRIPT_NAME}" method="post" enctype="multipart/form-data" onsubmit="return CheckFormCreateUser()">
<table align="left" border="0" cellspacing="0" cellpadding="2"  summary="newTable" width="100%">
    <tr>
      <td class="caption" colspan="4" onclick="DisplayDbHeader('CreateUser')" style="cursor:pointer;">|
      . translate('CreateUser') . qq|</td>
    </tr>
    <tr id="CreateUser" style="display:none;">
      <td class="values"><input type="text" name="name" value="Name" onfocus="this.value=''" style="width:80px;" /></td>
      <td class="values"><input type="text" name="host" value="Host" onfocus="this.value=''" style="width:80px;" /></td>
      <td class="values"><input type="password" name="password" value="" style="width:80px;" /></td>
      <td class="values"><input type="submit" name="submit" value="$newUser" /></td>
    </tr>
</table>
<input type="hidden" name="action" value="CreateUser" />
</form>
</td>
      <td valign="top" align="left">
<form action="$ENV{SCRIPT_NAME}" method="post" enctype="multipart/form-data" onsubmit="return CheckFormNewTable()"  name="NewTable">
<table align="left" border="0" cellspacing="0" cellpadding="2"  summary="newTable">
    <tr>
      <td class="caption" colspan="4" onclick="DisplayDbHeader('CreateTable')" style="cursor:pointer;">|
      . translate('CreateTable') . qq|</td>
    </tr>
    <tr id="CreateTable" style="display:none;">
      <td class="values"><input type="text" name="table" value="Name" onfocus="this.value=''" style="width:80px;" /></td>
      <td class="values">$fields:</td>
      <td class="values"><input type="text" name="count" value="1" style="width:40px;" id="fields4tbl" onkeyup="intputMask('fields4tbl',/(\\d+)/)" /></td>
      <td class="values"><input type="submit" name="submit" value="$newtable" /></td>
    </tr>
</table>
<input type="hidden" name="action" value="ShowNewTable" />
</form>
</td><td valign="top" align="left">
<form action="$ENV{SCRIPT_NAME}" method="post" enctype="multipart/form-data" onsubmit="return CheckFormCurrentDb()" name="CurrentDb">
    <input type="hidden" name="m_ChangeCurrentDb" value="$m_sCurrentDb"/>
    <table align="left" border="0" cellspacing="0" cellpadding="2" summary="M_currentDb">
    <tr >
      <td class="caption" colspan="4" onclick="DisplayDbHeader('m_ChangeCurrentDb')" style="cursor:pointer;">|
      . translate('ChangeCurrentDb') . qq|</td>
    </tr>
    <tr id="m_ChangeCurrentDb" style="display:none;">
      <td class="values"><input type="text" name="m_shost" value="$m_sCurrentHost"/></td>
      <td class="values"><input type="text" name="m_suser" value="$m_sCurrentUser"/></td>
      <td class="values"><input type="password" name="m_spass" value="$m_sCurrentPass"/></td>
      <td class="values"><input type="submit" name="submit" value="$connect" /></td>
    </tr>
</table>
</form>
</td>
    </tr>
</table>
</td>
    </tr>
</table>
</div>
<div id="SQLRIGHTS">
</div>
| . tabwidgetFooter() . qq(
<div id="SqlEditor" style="display:none;">
<form action ="$ENV{SCRIPT_NAME}" method="post">
<table cellspacing="5" cellpadding="0" border="0" align="center" summary="SQL" width="100%">
<tr>
<td colspan="2" align="left">$exec</td>
</tr>
<tr>
<td valign="top" width="120">
) . _insertTables() . qq(</td><td>
<textarea cols="150" rows="20" name="sql" class="sqlEdit" id="sqlEdit"  style="width:100%;height:215px;" >$sql</textarea></td>
</tr>
<tr><td></td>
<td align="right"><input type="hidden" value="$current" name="goto"/><input type="hidden" value="SQL" name="action"/><input type="submit" value="Exec"/></td>
</tr>
</table>
</form>
</div>
<div>
<div id="EXECSQL">$RIBBONCONTENT</div>
</div>
<div align="center">$PAGES</div>);
}

=head2 _insertTables()

Action

=cut

sub _insertTables
{
    my $selected = lc(shift);
    my @tables   = $m_oDatabase->fetch_array("show Tables;");
    my $list     = qq|
<script language="JavaScript" >
var nCurrentShown = 0;
function DisplayTable(id){
        hide( nCurrentShown);
        visible(id);
        nCurrentShown = id;
}
function DisplayKeyWords(b){
        if(b){
        document.getElementById('akeywods').className = 'currentLink';
        document.getElementById('afieldNames').className = 'link';
        hide( 'divTables');
        hide( nCurrentShown);
        visible('selKeyword');
        }else{
        document.getElementById('akeywods').className = 'link';
        document.getElementById('afieldNames').className = 'currentLink';
        hide( 'selKeyword');
        visible('divTables');
        }
}
</script>
<a id="akeywods" onclick="DisplayKeyWords(true)">Keywords</a>&#160;<a id="afieldNames" onclick="DisplayKeyWords(false)" class="currentLink">Field Names</a>
<div id="divTables">
<select id="tablelist" name="tablelist" size="10"  style="width:150px;height:100px;">|;

    for (my $i = 0; $i <= $#tables; $i++) {
        my $name = $m_dbh->quote_identifier($tables[$i]);
        $list .=
qq(<option " onclick="DisplayTable('$tables[$i]');" ondblclick="var e = document.getElementById('sqlEdit');e.value +='$name';e.focus();">$tables[$i]</option>);
    }
    $list .= '</select>';

    for (my $i = 0; $i <= $#tables; $i++) {
        my $table = $tables[$i];
        $table = $m_dbh->quote_identifier($table);
        my @tables2 = $m_oDatabase->fetch_AoH("show columns from $table");
        $list .= qq|<select id="$tables[$i]" size="10"  style="display:none;width:150px;height:100px;">|;
        for (my $i = 0; $i <= $#tables2; $i++) {
            my $name = $m_dbh->quote_identifier($tables2[$i]->{'Field'});
            $list .= qq(<option " onclick="var e = document.getElementById('sqlEdit');e.value +='$name';e.focus();">$tables2[$i]->{'Field'}</option>);
        }
        $list .= '</select></div>';
    }
    @tables = $m_oDatabase->fetch_array("select * from reserved_words");
    $list .= qq|<select id="selKeyword" size="10"  style="display:none;width:150px;height:200px;">|;
    for (my $i = 0; $i <= $#tables; $i++) {
        $list .= qq(<option " onclick="var e = document.getElementById('sqlEdit');e.value +='$tables[$i]';e.focus();">$tables[$i]</option>);
    }
    $list .= '</select>';

    return $list;
}

=head2 AnalyzeTable()

Action

=cut

sub AnalyzeTable
{
    my $tbl = param('table') ? param('table') : shift;
    if (defined $tbl) {
        my $tbl2 = $m_dbh->quote_identifier($tbl);
        ExecSql("ANALYZE TABLE $tbl2", 1);
        ShowTable($tbl);
    } else {
        ShowTables();
    }
}

=head2 RepairTable()

Action

=cut

sub RepairTable
{
    my $tbl = param('table') ? param('table') : shift;
    if (defined $tbl) {
        my $tbl2 = $m_dbh->quote_identifier($tbl);
        ExecSql("REPAIR TABLE $tbl2", 1);
        ShowTable($tbl);
    } else {
        ShowTables();
    }
}

=head2 OptimizeTable()

action

=cut

sub OptimizeTable
{
    my $tbl = param('table') ? param('table') : shift;
    if (defined $tbl) {
        my $tbl2 = $m_dbh->quote_identifier($tbl);
        ExecSql("OPTIMIZE TABLE $tbl2", 1);
        ShowTable($tbl);
    } else {
        ShowTables();
    }
}

=head2 ShowUsers()

action

=cut

sub ShowUsers
{
    my @a = $m_oDatabase->fetch_AoH("SELECT * FROM mysql.user");
    my %parameter = (
                     path     => $m_hrSettings->{cgi}{bin} . '/templates',
                     style    => $m_sStyle,
                     template => "wnd.htm",
                     server   => $m_hrSettings->{serverName},
                     id       => 'ShowUsers',
                     class    => 'max',
    );
    my $window = new HTML::Window(\%parameter);
    $m_sContent .= br() . $window->windowHeader();
    ShowDbHeader($m_sCurrentDb, 0, 'ShowUsers');
    $m_sContent .= qq(
              <div align="center" style="overflow:auto;width:100%">
              <form action="$ENV{SCRIPT_NAME}" method="get" enctype="multipart/form-data">
              <input type="hidden" name="action" value="MultipleAction"/>
              <input type="hidden" name="table" value="mysql"/>
              <table align="left" border="0" cellpadding="2" cellspacing="0" summary="ShowTables" width="100%">
              <tr>
                     <td class="caption"></td>
                     <td class="caption">User</td>
                     <td class="caption">Host</td>
                     <td class="caption">Rights</td>
                     <td class="caption"></td>
                     <td class="caption"></td>
              </tr>
    );
    for (my $i = 0; $i <= $#a; $i++) {
        my $trdatabase = translate('database');
        my $trdelete   = translate('delete');
        my $change     = translate('EditMysqlUserRights');
        initRights($a[$i]->{User}, $a[$i]->{Host});
        my $sRights;
        foreach my $k (sort keys %m_hUserRights) {$sRights .= $m_hUserRights{$k} ? $k =~ /^[a-z]+/ ? "$k " : '' : '';}
        $m_sContent .= qq(
              <tr onmouseover="this.className = 'overDb';" onmouseout="this.className = '';">
                     <td width="20" class="values"><input type="checkbox" name="markBox$i" class="markBox" value="$a[$i]->{User}/$a[$i]->{Host}" /></td>
                     <td class="values"><a href="$ENV{SCRIPT_NAME}?action=ShowRights&amp;user=$a[$i]->{User}&amp;host=$a[$i]->{Host}">$a[$i]->{User}</a></td>
                     <td class="values">$a[$i]->{Host}</td>
                     <td class="values">$sRights</td>
                     <td class="values" width="16"><a href="$ENV{SCRIPT_NAME}?action=DeleteUser&amp;table=mysql&amp;user=$a[$i]->{User}&amp;host=$a[$i]->{Host}" onclick="return confirm(' $trdelete?')"><img src="/style/$m_sStyle/buttons/delete.png" align="middle" alt="" border="0"/></a></td>
                     <td class="values" width="16"><a href="$ENV{SCRIPT_NAME}?action=ShowRights&amp;user=$a[$i]->{User}&amp;host=$a[$i]->{Host}"><img src="/style/$m_sStyle/buttons/edit.png" border="0" alt="$change" title="$change"/></a></td>
              </tr>
       );
    }
    my $delete   = translate('delete');
    my $mmark    = translate('selected');
    my $markAll  = translate('select_all');
    my $umarkAll = translate('unselect_all');
    $m_sContent .= qq|
              <tr>
              <td><img src="/style/$m_sStyle/buttons/feil.gif" border="0" alt=""/></td>
              <td colspan="7" align="left">
              <table align="center" border="0" cellpadding="0"  cellspacing="0" summary="ShowTables" width="100%">
              <tr><td colspan="2" align="left">
              <a id="markAll" href="javascript:markInput(true);" class="links">$markAll</a>
              <a class="links" id="umarkAll" style="display:none;" href="javascript:markInput(false);">$umarkAll</a></td>
              <td  align="right">
              <select name="MultipleAction" onchange="if(this.value != '$mmark' )this.form.submit();">
              <option value="$mmark" selected="selected">$mmark</option>
              <option value="deleteUser" >$delete</option>
              </select>
              </td>
              </tr></table>
              </td>
              </tr>
               <tr>
              <td colspan="6">&#160;</td>
              </tr>
              </table>
              <br/>
              </div>
              </form>
    |;
    $m_sContent .= $window->windowFooter();
}

=head2 ShowRights()

action

=cut

sub ShowRights
{
    my $UNIQUE_UPDATE                   = Unique();
    my $UNIQUE_DELETE                   = Unique();
    my $UNIQUE_CREATE                   = Unique();
    my $UNIQUE_DROP                     = Unique();
    my $UNIQUE_RELOAD                   = Unique();
    my $UNIQUE_SHUTDOWN                 = Unique();
    my $UNIQUE_PROCESS                  = Unique();
    my $UNIQUE_FILE                     = Unique();
    my $UNIQUE_REFERENCES               = Unique();
    my $UNIQUE_INDEX                    = Unique();
    my $UNIQUE_ALTER                    = Unique();
    my $UNIQUE_SHOWDATABASES            = Unique();
    my $UNIQUE_SUPER                    = Unique();
    my $UNIQUE_CREATETEMPORARYTABLES    = Unique();
    my $UNIQUE_LOCKTABLES               = Unique();
    my $UNIQUE_REPLICATIONCLIENT        = Unique();
    my $UNIQUE_CREATEVIEW               = Unique();
    my $UNIQUE_SHOWVIEW                 = Unique();
    my $UNIQUE_CREATEROUTINE            = Unique();
    my $UNIQUE_ALTERROUTINE             = Unique();
    my $UNIQUE_CREATEUSER               = Unique();
    my $UNIQUE_REPLICATIONSLAVE         = Unique();
    my $UNIQUE_MAX_QUERIES_PER_HOUR     = Unique();
    my $UNIQUE_MAX_CONNECTIONS_PER_HOUR = Unique();
    my $UNIQUE_MAX_UPDATES_PER_HOUR     = Unique();
    my $UNIQUE_INSERT                   = Unique();
    my $UNIQUE_SELECT                   = Unique();
    my $UNIQUE_EXECUTE                  = Unique();
    my $UNIQUE_HOST                     = Unique();
    my $UNIQUE_DB                       = Unique();
    my $UNIQUE_TBL                      = Unique();
    my $UNIQUE_USER                     = Unique();
    my $UNIQUE_MAX_USER_CONNECTIONS     = Unique();
    my $UNIQUE_update                   = Unique();
    my $UNIQUE_grant                    = Unique();
    my $uname                           = $_[0] ? shift : param('user');
    my $hostname                        = $_[0] ? shift : param('host');
    my $qstring = createSession(
                                {
                                 action => 'SaveRights',
                                 user   => $m_sUser,
                                 TBL    => $UNIQUE_TBL,
                                 DB     => $UNIQUE_DB,
                                 DBUSER => $UNIQUE_USER,
                                 uname  => $uname,
                                 HOST   => $UNIQUE_HOST,
                                 BOOL   => {
                                          UPDATE                => $UNIQUE_UPDATE,
                                          DELETE                => $UNIQUE_DELETE,
                                          CREATE                => $UNIQUE_CREATE,
                                          DROP                  => $UNIQUE_DROP,
                                          RELOAD                => $UNIQUE_RELOAD,
                                          SHUTDOWN              => $UNIQUE_SHUTDOWN,
                                          PROCESS               => $UNIQUE_PROCESS,
                                          FILE                  => $UNIQUE_FILE,
                                          REFERENCES            => $UNIQUE_REFERENCES,
                                          INDEX                 => $UNIQUE_INDEX,
                                          ALTER                 => $UNIQUE_ALTER,
                                          SHOWDATABASES         => $UNIQUE_SHOWDATABASES,
                                          SUPER                 => $UNIQUE_SUPER,
                                          CREATETEMPORARYTABLES => $UNIQUE_CREATETEMPORARYTABLES,
                                          LOCKTABLES            => $UNIQUE_LOCKTABLES,
                                          REPLICATIONCLIENT     => $UNIQUE_REPLICATIONCLIENT,
                                          CREATEVIEW            => $UNIQUE_CREATEVIEW,
                                          SHOWVIEW              => $UNIQUE_SHOWVIEW,
                                          CREATEROUTINE         => $UNIQUE_CREATEROUTINE,
                                          ALTERROUTINE          => $UNIQUE_ALTERROUTINE,
                                          CREATEUSER            => $UNIQUE_CREATEUSER,
                                          REPLICATIONSLAVE      => $UNIQUE_REPLICATIONSLAVE,
                                          INSERT                => $UNIQUE_INSERT,
                                          SELECT                => $UNIQUE_SELECT,
                                          EXECUTE               => $UNIQUE_EXECUTE,
                                          UPDATE                => $UNIQUE_update,
                                          GRANT                 => $UNIQUE_grant,
                                 },
                                 NUMBER => {
                                            MAX_QUERIES_PER_HOUR     => $UNIQUE_MAX_QUERIES_PER_HOUR,
                                            MAX_CONNECTIONS_PER_HOUR => $UNIQUE_MAX_CONNECTIONS_PER_HOUR,
                                            MAX_UPDATES_PER_HOUR     => $UNIQUE_MAX_UPDATES_PER_HOUR,
                                            MAX_USER_CONNECTIONS     => $UNIQUE_MAX_USER_CONNECTIONS,
                                 }
                                }
    );
    initRights($uname, $hostname);
    my $windowa = new HTML::Window(
                                   {
                                    path     => $m_hrSettings->{cgi}{bin} . '/templates',
                                    style    => $m_sStyle,
                                    template => "wnd.htm",
                                    server   => $m_hrSettings->{serverName},
                                    id       => 'ShowRights',
                                    class    => 'max',
                                   }
    );
    $m_sContent .= $windowa->windowHeader();
    ShowDbHeader($m_sCurrentDb, 0, 'ShowRights');
    my $save = translate('save');
    $m_sContent .= qq|
    <br/>
    <div align="center">
    <form action="$ENV{SCRIPT_NAME}" method="get" enctype="multipart/form-data">
    <input type="hidden" name="action" value="SaveRights"/>
    <input type="hidden" name="session" value="$qstring"/>
    <table cellspacing="0" border="0" cellpadding="2" summary="rightsLayout">
    <tr>
      <td class="caption" colspan="8">| . translate('rights') . qq|</td>
    </tr>
    <tr onmouseover="this.className='overDb';" onmouseout="this.className='';">
      <td class="values"><input type="checkbox" class="markBox" name="marksBox$UNIQUE_UPDATE" |
      . (HasRight('update') ? 'checked="checked"' : "") . qq| /></td><td class="values">UPDATE</td>
      <td class="values"><input type="checkbox" class="markBox" name="marksBox$UNIQUE_DELETE" |
      . (HasRight('delete') ? 'checked="checked"' : "") . qq| /></td><td class="values">DELETE</td>
      <td class="values"><input type="checkbox" class="markBox" name="marksBox$UNIQUE_CREATE" |
      . (HasRight('create') ? 'checked="checked"' : "") . qq| /></td><td class="values">CREATE</td>
      <td class="values"><input type="checkbox" class="markBox" name="marksBox$UNIQUE_DROP" |
      . (HasRight('drop') ? 'checked="checked"' : "") . qq| /></td><td class="values">DROP</td>
    </tr>
    <tr onmouseover="this.className='overDb';" onmouseout="this.className='';">
      <td class="values"><input type="checkbox" class="markBox" name="marksBox$UNIQUE_RELOAD" |
      . (HasRight('reload') ? 'checked="checked"' : "") . qq| /></td><td class="values">RELOAD</td>
      <td class="values"><input type="checkbox" class="markBox" name="marksBox$UNIQUE_SHUTDOWN" |
      . (HasRight('shutdown') ? 'checked="checked"' : "") . qq| /></td><td class="values">SHUTDOWN</td>
      <td class="values"><input type="checkbox" class="markBox" name="marksBox$UNIQUE_PROCESS" |
      . (HasRight('process') ? 'checked="checked"' : "") . qq| /></td><td class="values">PROCESS</td>
      <td class="values"><input type="checkbox" class="markBox" name="marksBox$UNIQUE_FILE" |
      . (HasRight('file') ? 'checked="checked"' : "") . qq| /></td><td class="values">FILE</td>
    </tr>
    <tr onmouseover="this.className='overDb';" onmouseout="this.className='';">
      <td class="values"><input type="checkbox" class="markBox" name="marksBox$UNIQUE_REFERENCES" |
      . (HasRight('references') ? 'checked="checked"' : "") . qq| /></td><td class="values">REFERENCES</td>
      <td class="values"><input type="checkbox" class="markBox" name="marksBox$UNIQUE_INDEX" |
      . (HasRight('index') ? 'checked="checked"' : "") . qq| /></td><td class="values">INDEX</td>
      <td class="values"><input type="checkbox" class="markBox" name="marksBox$UNIQUE_SHOWDATABASES" |
      . (HasRight('show_db') ? 'checked="checked"' : "") . qq| /></td><td class="values">SHOW DATABASES</td>
      <td class="values"><input type="checkbox" class="markBox" name="marksBox$UNIQUE_SUPER" |
      . (HasRight('super') ? 'checked="checked"' : "") . qq| /></td><td class="values">SUPER</td>
    </tr>
    <tr onmouseover="this.className='overDb';" onmouseout="this.className='';">
      <td class="values"><input type="checkbox" class="markBox" name="marksBox$UNIQUE_CREATETEMPORARYTABLES" |
      . (HasRight('create_tmp_table') ? 'checked="checked"' : "") . qq| /></td><td class="values">CREATE TEMPORARY TABLES</td>
      <td class="values"><input type="checkbox" class="markBox" name="marksBox$UNIQUE_LOCKTABLES" |
      . (HasRight('lock_tables') ? 'checked="checked"' : "") . qq| /></td><td class="values">LOCK TABLES</td>
      <td class="values"><input type="checkbox" class="markBox" name="marksBox$UNIQUE_REPLICATIONSLAVE" |
      . (HasRight('repl_slave') ? 'checked="checked"' : "") . qq| /></td><td class="values">REPLICATION SLAVE</td>
      <td class="values"><input type="checkbox" class="markBox" name="marksBox$UNIQUE_REPLICATIONCLIENT" |
      . (HasRight('repl_client') ? 'checked="checked"' : "") . qq| /></td><td class="values">REPLICATION CLIENT</td>
    </tr>
    <tr onmouseover="this.className='overDb';" onmouseout="this.className='';">
      <td class="values"><input type="checkbox" class="markBox" name="marksBox$UNIQUE_INSERT" |
      . (HasRight('insert') ? 'checked="checked"' : "") . qq| /></td><td class="values">INSERT</td>
      <td class="values"><input type="checkbox" class="markBox" name="marksBox$UNIQUE_CREATEVIEW" |
      . (HasRight('create_view') ? 'checked="checked"' : "") . qq| /></td><td class="values">CREATE VIEW</td>
      <td class="values"><input type="checkbox" class="markBox" name="marksBox$UNIQUE_SHOWVIEW" |
      . (HasRight('show_view') ? 'checked="checked"' : "") . qq| /></td><td class="values">SHOW VIEW</td>
      <td class="values"><input type="checkbox" class="markBox" name="marksBox$UNIQUE_CREATEROUTINE" |
      . (HasRight('create_routine') ? 'checked="checked"' : "") . qq| /></td><td class="values">CREATE ROUTINE</td>
    </tr>
    <tr onmouseover="this.className='overDb';" onmouseout="this.className='';">
      <td class="values"><input type="checkbox" class="markBox" name="marksBox$UNIQUE_SELECT" |
      . (HasRight('select') ? 'checked="checked"' : "") . qq| /></td><td class="values">SELECT</td>
      <td class="values"><input type="checkbox" class="markBox" name="marksBox$UNIQUE_ALTERROUTINE" |
      . (HasRight('alter_routine') ? 'checked="checked"' : "") . qq| /></td><td class="values">ALTER ROUTINE</td>
      <td class="values"><input type="checkbox" class="markBox" name="marksBox$UNIQUE_CREATEUSER" |
      . (HasRight('create_user') ? 'checked="checked"' : "") . qq| /></td><td class="values">CREATE USER</td>
      <td class="values"><input type="checkbox" class="markBox" name="marksBox$UNIQUE_EXECUTE" |
      . (HasRight('execute') ? 'checked="checked"' : "") . qq| /></td><td class="values">EXECUTE</td>
    </tr>

    <tr onmouseover="this.className='overDb';" onmouseout="this.className='';">
      <td class="values"><input type="checkbox" class="markBox" name="marksBox$UNIQUE_ALTER" |
      . (HasRight('alter') ? 'checked="checked"' : "") . qq| /></td><td class="values">ALTER</td>
      <td class="values"><input type="checkbox" class="markBox" name="marksBox$UNIQUE_update" |
      . (HasRight('update') ? 'checked="checked"' : "") . qq| /></td><td class="values">UPDATE</td>
      <td class="values"><input type="checkbox" class="markBox" name="marksBox$UNIQUE_grant" |
      . (HasRight('grant') ? 'checked="checked"' : "") . qq| /></td><td class="values">GRANT</td>
      <td class="values"></td><td class="values"></td>
    </tr>
    <tr >
      <td class="caption" colspan="2">MAX_QUERIES_PER_HOUR</td>
      <td class="caption" colspan="2">MAX_CONNECTIONS_PER_HOUR</td>
      <td class="caption" colspan="2">MAX_UPDATES_PER_HOUR</td>
      <td class="caption" colspan="2">MAX_UPDATES_PER_HOUR</td>
    </tr>
    <tr onmouseover="this.className='overDb';" onmouseout="this.className='';">
      <td class="values" colspan="2"><input type="text" name="$UNIQUE_MAX_QUERIES_PER_HOUR" value="|
      . HasRight('max_questions') . qq|"/></td>
      <td class="values" colspan="2"><input type="text" name="$UNIQUE_MAX_CONNECTIONS_PER_HOUR" value="|
      . HasRight('max_connections') . qq|"/></td>
      <td class="values" colspan="2"><input type="text" name="$UNIQUE_MAX_UPDATES_PER_HOUR" value="|
      . HasRight('max_updates') . qq|"/></td>
      <td class="values" colspan="2"><input type="text" name="$UNIQUE_MAX_USER_CONNECTIONS" value="|
      . HasRight('max_user_connections') . qq|"/></td>
    </tr>
        <tr>
      <td class="caption" colspan="2">| . translate("Host") . qq|</td>
      <td class="caption" colspan="2">| . translate("database") . qq|</td>
      <td class="caption" colspan="2">| . translate("table") . qq|</td>
      <td class="caption" colspan="2">| . translate("User") . qq|</td>
    </tr>
    <tr onmouseover="this.className='overDb';" onmouseout="this.className='';">
      <td class="values" colspan="2"><input type="text" name="$UNIQUE_HOST" value="$hostname"/></td>
      <td class="values" colspan="2">| . GetDatabases($UNIQUE_DB) . qq|</td>
      <td class="values" colspan="2">| . GetTables($UNIQUE_TBL) . qq|</td>
      <td class="values" colspan="2">|
      . GetUsers($UNIQUE_USER, $uname) . qq|</td>
    </tr>
     <tr>
        <td><a id="markAll" href="javascript:markInput(true);" class="links">$markAll</a><a class="links" id="umarkAll" style="display:none;" href="javascript:markInput(false);">$umarkAll</a>
        </td><td align="right" colspan="7"><input type="submit" name="submit" value="$save"></td>
    </tr>
    </table>
    </form></div>|;
    $m_sContent .= br() . $windowa->windowFooter();
}

=head2 initRights()

rechte für $m_hUserRights werden initialisiert

       initRights($p_sUser,$p_sHost )

=cut

sub initRights
{
    my $p_sUser = shift;
    my $p_sHost = shift;
    my $hr      = $m_oDatabase->fetch_hashref("SELECT * FROM mysql.user where USER = ? && Host = ?", $p_sUser, $p_sHost);
    foreach (keys %{$hr}) {
        if ($_ =~ /(.*)_priv$/) {
            my $key = lc($1);
            $m_hUserRights{$key} = $hr->{$_} eq 'Y' ? 1 : 0;
        } elsif ($_ =~ /(max_.*)$/) {
            my $key = lc($1);
            $m_hUserRights{$key} = $hr->{$_} ? $hr->{$_} : 0;
        } else {
            $m_hUserRights{$_} = $hr->{$_};
        }
    }
}

=head2 HasRight()

private

=cut

sub HasRight {return $m_hUserRights{lc($_[0])};}

=head2 GetTables()

Auswahliste (select) wird zurück gegeben

       GetTables(name)

=cut

sub GetTables
{
    my $name     = shift;
    my $selected = $_[0] ? $_[0] : 0;
    my @dbs      = $m_oDatabase->fetch_array("show tables");
    my $return   = qq|<select name="$name" style="width:75%;">
                      <option value="*"></option>|;
    $return .= qq|<option  value="$_" | . ($selected eq $_ ? 'selected="selected"' : '') . qq|>$_</option>| foreach @dbs;
    $return .= '</select>';
    return $return;
}

=head2 GetDatabases()

Auswahliste (select) wird zurück gegeben

       GetDatabases(name)

=cut

sub GetDatabases
{
    my $name     = shift;
    my $selected = $_[0] ? $_[0] : 0;
    my @dbs      = $m_oDatabase->fetch_array("show databases");
    my $return   = qq|<select name="$name" style="width:75%;">   
                    <option value="*"></option>|;
    $return .= qq|<option  value="$_" | . ($selected eq $_ ? 'selected="selected"' : '') . qq|>$_</option>| foreach @dbs;
    $return .= '</select>';
    return $return;
}

=head2 GetUsers()

Auswahliste (select) wird zurück gegeben

       GetUsers(name)

=cut

sub GetUsers
{
    my $name = shift;
    my $selected = $_[0] ? $_[0] : 0;
    my %users;
    my @dbs = $m_oDatabase->fetch_array("select User from mysql.user");
    $users{$_} = $_ foreach @dbs;
    my $return = qq|<select name="$name" style="width:75%;">|;
    $return .= qq|<option  value="$_" | . ($selected eq $_ ? 'selected="selected"' : '') . qq|>$_</option>| foreach keys %users;
    $return .= '</select>';
    return $return;
}

=head2 SaveRights()

action:
       SaveRights()

=cut

sub SaveRights
{
    my $session = param('session');
    session($session, $m_sUser);
    if (defined $session) {
        my $sql = 'GRANT ';
        my @BOOL;
        push @BOOL, "UPDATE"                  if param('marksBox' . $m_hrParams->{BOOL}{UPDATE})                eq 'on';
        push @BOOL, "DELETE"                  if param('marksBox' . $m_hrParams->{BOOL}{DELETE})                eq 'on';
        push @BOOL, "CREATE"                  if param('marksBox' . $m_hrParams->{BOOL}{CREATE})                eq 'on';
        push @BOOL, "DROP"                    if param('marksBox' . $m_hrParams->{BOOL}{DROP})                  eq 'on';
        push @BOOL, "RELOAD"                  if param('marksBox' . $m_hrParams->{BOOL}{RELOAD})                eq 'on';
        push @BOOL, "SHUTDOWN"                if param('marksBox' . $m_hrParams->{BOOL}{SHUTDOWN})              eq 'on';
        push @BOOL, "PROCESS"                 if param('marksBox' . $m_hrParams->{BOOL}{PROCESS})               eq 'on';
        push @BOOL, "FILE"                    if param('marksBox' . $m_hrParams->{BOOL}{FILE})                  eq 'on';
        push @BOOL, "REFERENCES"              if param('marksBox' . $m_hrParams->{BOOL}{REFERENCES})            eq 'on';
        push @BOOL, "INDEX"                   if param('marksBox' . $m_hrParams->{BOOL}{INDEX})                 eq 'on';
        push @BOOL, "ALTER"                   if param('marksBox' . $m_hrParams->{BOOL}{ALTER})                 eq 'on';
        push @BOOL, "SHOW DATABASES"          if param('marksBox' . $m_hrParams->{BOOL}{SHOWDATABASES})         eq 'on';
        push @BOOL, "SUPER"                   if param('marksBox' . $m_hrParams->{BOOL}{SUPER})                 eq 'on';
        push @BOOL, "CREATE TEMPORARY TABLES" if param('marksBox' . $m_hrParams->{BOOL}{CREATETEMPORARYTABLES}) eq 'on';
        push @BOOL, "LOCK TABLES"             if param('marksBox' . $m_hrParams->{BOOL}{LOCKTABLES})            eq 'on';
        push @BOOL, "REPLICATION CLIENT"      if param('marksBox' . $m_hrParams->{BOOL}{REPLICATIONCLIENT})     eq 'on';
        push @BOOL, "CREATE VIEW"             if param('marksBox' . $m_hrParams->{BOOL}{CREATEVIEW})            eq 'on';
        push @BOOL, "SHOW VIEW"               if param('marksBox' . $m_hrParams->{BOOL}{SHOWVIEW})              eq 'on';
        push @BOOL, "CREATE ROUTINE"          if param('marksBox' . $m_hrParams->{BOOL}{CREATEROUTINE})         eq 'on';
        push @BOOL, "ALTER ROUTINE"           if param('marksBox' . $m_hrParams->{BOOL}{ALTERROUTINE})          eq 'on';
        push @BOOL, "CREATE USER"             if param('marksBox' . $m_hrParams->{BOOL}{CREATEUSER})            eq 'on';
        push @BOOL, "REPLICATION SLAVE"       if param('marksBox' . $m_hrParams->{BOOL}{REPLICATIONSLAVE})      eq 'on';
        push @BOOL, "INSERT"                  if param('marksBox' . $m_hrParams->{BOOL}{INSERT})                eq 'on';
        push @BOOL, "SELECT"                  if param('marksBox' . $m_hrParams->{BOOL}{SELECT})                eq 'on';
        push @BOOL, "EXECUTE"                 if param('marksBox' . $m_hrParams->{BOOL}{EXECUTE})               eq 'on';
        push @BOOL, "UPDATES"                 if param('marksBox' . $m_hrParams->{BOOL}{UPDATES})               eq 'on';
        push @BOOL, "GRANT OPTION"            if param('marksBox' . $m_hrParams->{BOOL}{GRANT})                 eq 'on';
        if ($#BOOL > 0) {
            @BOOL = sort(@BOOL);
            for (my $i = 0; $i < $#BOOL; $i++) {$sql .= $BOOL[$i] . ",\n";}
            $sql .=
                $BOOL[$#BOOL] . ' ON '
              . (param($m_hrParams->{DB})  ? param($m_hrParams->{DB})  : '*') . '.'
              . (param($m_hrParams->{TBL}) ? param($m_hrParams->{TBL}) : '*') . " TO '"
              . param($m_hrParams->{DBUSER}) . "'\@'"
              . param($m_hrParams->{HOST}) . "'";
            $sql .= qq| WITH GRANT OPTION |;
            $sql .= 'MAX_QUERIES_PER_HOUR ' . param($m_hrParams->{NUMBER}{MAX_QUERIES_PER_HOUR});
            $sql .= ' MAX_CONNECTIONS_PER_HOUR ' . param($m_hrParams->{NUMBER}{MAX_CONNECTIONS_PER_HOUR});
            $sql .= ' MAX_UPDATES_PER_HOUR ' . param($m_hrParams->{NUMBER}{MAX_UPDATES_PER_HOUR});
            $sql .= ' MAX_USER_CONNECTIONS ' . param($m_hrParams->{NUMBER}{MAX_USER_CONNECTIONS});
            $sql .= ';';
            ExecSql($sql);
        }
        $sql = 'REVOKE ';
        my @REVEOKE;
        push @REVEOKE, "UPDATE"                  if param('marksBox' . $m_hrParams->{BOOL}{UPDATE})                ne 'on';
        push @REVEOKE, "DELETE"                  if param('marksBox' . $m_hrParams->{BOOL}{DELETE})                ne 'on';
        push @REVEOKE, "CREATE"                  if param('marksBox' . $m_hrParams->{BOOL}{CREATE})                ne 'on';
        push @REVEOKE, "DROP"                    if param('marksBox' . $m_hrParams->{BOOL}{DROP})                  ne 'on';
        push @REVEOKE, "RELOAD"                  if param('marksBox' . $m_hrParams->{BOOL}{RELOAD})                ne 'on';
        push @REVEOKE, "SHUTDOWN"                if param('marksBox' . $m_hrParams->{BOOL}{SHUTDOWN})              ne 'on';
        push @REVEOKE, "PROCESS"                 if param('marksBox' . $m_hrParams->{BOOL}{PROCESS})               ne 'on';
        push @REVEOKE, "FILE"                    if param('marksBox' . $m_hrParams->{BOOL}{FILE})                  ne 'on';
        push @REVEOKE, "REFERENCES"              if param('marksBox' . $m_hrParams->{BOOL}{REFERENCES})            ne 'on';
        push @REVEOKE, "INDEX"                   if param('marksBox' . $m_hrParams->{BOOL}{INDEX})                 ne 'on';
        push @REVEOKE, "ALTER"                   if param('marksBox' . $m_hrParams->{BOOL}{ALTER})                 ne 'on';
        push @REVEOKE, "SHOW DATABASES"          if param('marksBox' . $m_hrParams->{BOOL}{SHOWDATABASES})         ne 'on';
        push @REVEOKE, "SUPER"                   if param('marksBox' . $m_hrParams->{BOOL}{SUPER})                 ne 'on';
        push @REVEOKE, "CREATE TEMPORARY TABLES" if param('marksBox' . $m_hrParams->{BOOL}{CREATETEMPORARYTABLES}) ne 'on';
        push @REVEOKE, "LOCK TABLES"             if param('marksBox' . $m_hrParams->{BOOL}{LOCKTABLES})            ne 'on';
        push @REVEOKE, "REPLICATION CLIENT"      if param('marksBox' . $m_hrParams->{BOOL}{REPLICATIONCLIENT})     ne 'on';
        push @REVEOKE, "CREATE VIEW"             if param('marksBox' . $m_hrParams->{BOOL}{CREATEVIEW})            ne 'on';
        push @REVEOKE, "SHOW VIEW"               if param('marksBox' . $m_hrParams->{BOOL}{SHOWVIEW})              ne 'on';
        push @REVEOKE, "CREATE ROUTINE"          if param('marksBox' . $m_hrParams->{BOOL}{CREATEROUTINE})         ne 'on';
        push @REVEOKE, "ALTER ROUTINE"           if param('marksBox' . $m_hrParams->{BOOL}{ALTERROUTINE})          ne 'on';
        push @REVEOKE, "CREATE USER"             if param('marksBox' . $m_hrParams->{BOOL}{CREATEUSER})            ne 'on';
        push @REVEOKE, "REPLICATION SLAVE"       if param('marksBox' . $m_hrParams->{BOOL}{REPLICATIONSLAVE})      ne 'on';
        push @REVEOKE, "INSERT"                  if param('marksBox' . $m_hrParams->{BOOL}{INSERT})                ne 'on';
        push @REVEOKE, "SELECT"                  if param('marksBox' . $m_hrParams->{BOOL}{SELECT})                ne 'on';
        push @REVEOKE, "EXECUTE"                 if param('marksBox' . $m_hrParams->{BOOL}{EXECUTE})               ne 'on';
        push @REVEOKE, "UPDATE"                  if param('marksBox' . $m_hrParams->{BOOL}{UPDATE})                ne 'on';
        push @REVEOKE, "GRANT OPTION"            if param('marksBox' . $m_hrParams->{BOOL}{GRANT})                 ne 'on';

        if ($#REVEOKE > 0) {
            @REVEOKE = sort(@REVEOKE);
            for (my $i = 0; $i < $#REVEOKE; $i++) {$sql .= $REVEOKE[$i] . ",\n";}
            $sql .=
                $REVEOKE[$#REVEOKE] . ' ON '
              . (param($m_hrParams->{DB})  ? param($m_hrParams->{DB})  : '*') . '.'
              . (param($m_hrParams->{TBL}) ? param($m_hrParams->{TBL}) : '*')
              . " FROM '"
              . param($m_hrParams->{DBUSER}) . "'\@'"
              . param($m_hrParams->{HOST}) . "'";
            $sql .= ';';
            ExecSql($sql);
        }
    }
    ShowRights(param($m_hrParams->{DBUSER}), param($m_hrParams->{HOST}));
}

=head2 CreateUser()

action

=cut

sub CreateUser
{
    my $password = $m_oDatabase->quote(param('password'));
    my $name     = $m_oDatabase->quote(param('name'));
    my $host     = $m_oDatabase->quote(param('host'));
    ExecSql("CREATE USER $name\@$host IDENTIFIED BY $password");
    ShowUsers();
}

=head2 DeleteUser()

action

=cut

sub DeleteUser
{
    my $name = $m_oDatabase->quote(param('user'));
    my $host = $m_oDatabase->quote(param('host'));
    $name .= "\@$host" if (defined $host);
    ExecSql("DROP USER $name");
    ShowUsers();
}

=head2 ShowDatabases()

Action

=cut

sub ShowDatabases
{
    my @a = $m_oDatabase->fetch_AoH("SHOW DATABASES");
    for (my $i = 0; $i <= $#a; $i++) {
        my $kb = 0;
        my $db = $m_dbh->quote_identifier($a[$i]->{Database});
        my @b  = $m_oDatabase->fetch_AoH("SHOW TABLE STATUS from $db ");
        for (my $j = 0; $j <= $#b; $j++) {$kb += $b[$j]->{Index_length} + $b[$i]->{Data_length};}
        $a[$i]->{Size} = $kb > 0 ? sprintf("%.2f", $kb / 1024) : 0;
        $a[$i]->{Tables} = $#b > 0 ? $#b : 0;
    }
    my %parameter = (
                     path     => $m_hrSettings->{cgi}{bin} . '/templates',
                     style    => $m_sStyle,
                     template => "wnd.htm",
                     server   => $m_hrSettings->{serverName},
                     id       => 'ShowDatabases',
                     class    => 'max',
    );
    my $window = new HTML::Window(\%parameter);
    $m_sContent .= br() . $window->windowHeader();
    my $orderby = defined param('orderBy')        ? param('orderBy')        : 'Name';
    my $state   = param('desc')                   ? 1                       : 0;
    my $nstate  = $state                          ? 0                       : 1;
    my $lpp     = defined param('links_pro_page') ? param('links_pro_page') : 30;
    $lpp = $lpp =~ /(\d\d\d?)/ ? $1 : $lpp;
    my $end = $m_nStart + $lpp > $#a ? $#a : $m_nStart + $lpp;

    if ($#a > $lpp) {
        my %needed = (
                      start          => $m_nStart,
                      length         => $#a,
                      style          => $m_sStyle,
                      mod_rewrite    => 0,
                      action         => "ShowDatabases",
                      append         => "&links_pro_page=$lpp&orderBy=$orderby&desc=$state",
                      path           => $m_hrSettings->{cgi}{bin},
                      links_pro_page => $lpp,
        );
        $PAGES = makePages(\%needed);
    } else {
        $end = $#a;
    }
    @a = sort {round($a->{$orderby}) <=> round($b->{$orderby})} @a;
    @a = reverse @a if $state;
    ShowDbHeader($m_sCurrentDb, 0, 'ShowDatabases');
    $m_sContent .= div(
                       {align => 'right'},
                       translate('links_pro_page') 
                         . '&#160;|&#160;'
                         . (
                            $#a > 10
                            ? a(
                                {
                                 href  => "$ENV{SCRIPT_NAME}?action=ShowDatabases&links_pro_page=10&von=$m_nStart&orderBy=$orderby&desc=$state",
                                 class => $lpp == 10 ? 'menuLink2' : 'menuLink3'
                                },
                                '10'
                              )
                            : ''
                         )
                         . (
                            $#a > 20
                            ? '&#160;'
                              . a(
                                  {
                                   href  => "$ENV{SCRIPT_NAME}?action=ShowDatabases&links_pro_page=20&von=$m_nStart&orderBy=$orderby&desc=$state",
                                   class => $lpp == 20 ? 'menuLink2' : 'menuLink3'
                                  },
                                  '20'
                              )
                            : ''
                         )
                         . (
                            $#a > 30
                            ? '&#160;'
                              . a(
                                  {
                                   href  => "$ENV{SCRIPT_NAME}?action=ShowDatabases&links_pro_page=30&von=$m_nStart&orderBy=$orderby&desc=$state",
                                   class => $lpp == 30 ? 'menuLink2' : 'menuLink3'
                                  },
                                  '30'
                              )
                            : ''
                         )
                         . (
                            $#a > 100
                            ? '&#160;'
                              . a(
                                  {
                                   href  => "$ENV{SCRIPT_NAME}?action=ShowDatabases&links_pro_page=100&von=$m_nStart&orderBy=$orderby&desc=$state",
                                   class => $lpp == 100 ? 'menuLink2' : 'menuLink3'
                                  },
                                  '100'
                              )
                            : ''
                         )
    ) if $#a > 20;
    $m_sContent .= qq(
              <form action="$ENV{SCRIPT_NAME}" method="post" enctype="multipart/form-data">
              <input type="hidden" name="action" value="MultipleDbAction"/>
              <div align="center" style="padding-top:5px;overflow:auto;width:100%">
              <table align="left" border="0" cellpadding="2"  cellspacing="0" summary="ShowDatabases" width="100%">
              <tr>
              <td class="caption"></td>
              <td class="caption" > )
      . qq(<a href="$ENV{SCRIPT_NAME}?action=ShowDatabases&amp;links_pro_page=$lpp&amp;von=$m_nStart&amp;orderBy=Name&amp;desc=$nstate">Name</a>)
      . (
           $orderby eq "Name"
         ? $state
               ? qq|&#160;<img src="/style/$m_sStyle/$m_nSize/mimetypes/up.png" border="0" alt="up" title="up" width="16" height="16"/>|
               : qq|&#160;<img src="/style/$m_sStyle/$m_nSize/mimetypes/down.png" border="0" alt="down" title="down"/>|
         : ''
      )
      . q(</td>
              <td class="caption"> )
      . qq(<a href="$ENV{SCRIPT_NAME}?action=ShowDatabases&amp;links_pro_page=$lpp&amp;von=$m_nStart&amp;orderBy=Tables&amp;desc=$nstate">Tables</a>)
      . (
           $orderby eq "Tables"
         ? $state
               ? qq|&#160;<img src="/style/$m_sStyle/$m_nSize/mimetypes/up.png"   border="0" alt="up" title="up" width="16" height="16"/>|
               : qq|&#160;<img src="/style/$m_sStyle/$m_nSize/mimetypes/down.png" border="0" alt="down" title="down"/>|
         : ''
      )
      . q(</td>
              <td class="caption"> )

      . qq(<a href="$ENV{SCRIPT_NAME}?action=ShowDatabases&amp;links_pro_page=$lpp&amp;von=$m_nStart&amp;orderBy=Size&amp;desc=$nstate">Size (kb)</a>)
      . (
           $orderby eq "Size"
         ? $state
               ? qq|&#160;<img src="/style/$m_sStyle/$m_nSize/mimetypes/up.png" border="0" alt="up" title="up" width="16" height="16"/>|
               : qq|&#160;<img src="/style/$m_sStyle/$m_nSize/mimetypes/down.png" border="0" alt="down" title="down"/>|
         : ''
      )
      . q(</td>
              <td class="caption"></td>
              </tr>
    );

    for (my $i = $m_nStart; $i <= $end; $i++) {
        my $trdatabase = translate('database');
        my $trdelete   = translate('delete');
        my $change     = translate('EditTable');
        $m_sContent .= qq(
              <tr onmouseover="this.className = 'overDb';" onmouseout="this.className = '';">
              <td width="20" class="values"><input type="checkbox" name="markBox$i" class="markBox" value="$a[$i]->{Database}" /></td>
              <td class="values"><a href="$ENV{SCRIPT_NAME}?action=ShowTables&amp;m_ChangeCurrentDb=$a[$i]->{Database}&amp;desc=0">$a[$i]->{Database}</a></td>
              <td class="values">$a[$i]->{Tables}</td>
              <td class="values">$a[$i]->{Size}</td>
              <td class="values" align="right"><a href="$ENV{SCRIPT_NAME}?action=DropDatabase&amp;db=$a[$i]->{Database}" onclick="return confirm(' $trdelete?')"><img src="/style/$m_sStyle/buttons/delete.png" align="right" alt="" border="0"/></a></td>
              </tr>
       );
    }
    my $drop     = translate('drop_database');
    my $mmark    = translate('selected');
    my $markAll  = translate('select_all');
    my $umarkAll = translate('unselect_all');
    my $export   = translate('export');
    $m_sContent .= qq|
              <tr>
              <td><img src="/style/$m_sStyle/buttons/feil.gif" border="0" alt=""/></td>
              <td colspan="7" align="left">
              <table align="center" border="0" cellpadding="0"  cellspacing="0" summary="ShowDatabases" width="100%">
              <tr><td colspan="2" align="left">
              <a id="markAll" href="javascript:markInput(true);" class="links">$markAll</a><a class="links" id="umarkAll" style="display:none;" href="javascript:markInput(false);">$umarkAll</a></td>
              <td  align="right">
              <select name="MultipleDbAction" onchange="if(this.value != '$mmark' )this.form.submit();">
              <option value="$mmark" selected="selected">$mmark</option>
              <option value="dropDb">$drop</option>
              <option value="exportDb">$export</option>
              </select>
              </td>
              </tr></table>
              </td>
              </tr>
              </table>
              </form>
              </div>
    |;
    $m_sContent .= $window->windowFooter();
}

=head2 DropDatabase()

Action

=cut

sub DropDatabase
{
    my $db = param('db') ? param('db') : shift;
    my $db2 = $m_dbh->quote_identifier($db);
    ExecSql("Drop DATABASE $db2");
    ChangeDb(
             {
              name     => 'LZE',
              host     => $m_sCurrentHost,
              user     => $m_sCurrentUser,
              password => $m_sCurrentPass,
             }
    );
    ShowDatabases();
}

=head2 CreateDatabase()

Action

=cut

sub CreateDatabase
{
    my $db = param('name') ? param('name') : shift;
    my $db2 = $m_dbh->quote_identifier($db);
    ExecSql("Create DATABASE $db2");
    ShowDatabases();
}

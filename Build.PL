use strict;
use vars qw($m_hrSettings $skip $cwd $prefix);
use Module::Build;
my $class = Module::Build->subclass(
    class => "Module::Build::Custom",
    code  => <<'END');
use vars qw($m_hrSettings $cwd);
use File::Copy;
use File::Path;
use Cwd;
$cwd = cwd;
my $release = "$cwd/blib/rhtml/";
my $dir     = "$cwd/htdocs/";
my $path    = '.';

loadSettings("$cwd/cgi-bin/config/settings.pl");

sub ACTION_build
{
    my $self = shift;
    mkpath($release);
    &change($dir);
    $release = "$cwd/blib/perl/";
    $dir     = "$cwd/cgi-bin/";
    mkpath($release);
    &change($dir);
    $self->SUPER::ACTION_build;
    &replace('%PATH%', $m_hrSettings->{cgi}{bin}, "$cwd/blib/perl/lze.pl");
    &replace('%PATH%', $m_hrSettings->{cgi}{bin}, "$cwd/blib/perl/rpc.pl");

    if (-e "$m_hrSettings->{cgi}{bin}/config/links.pl") {
        copy("$m_hrSettings->{cgi}{bin}/config/links.pl", "$cwd/blib/perl/config/links.pl") or die "Copy failed: $m_hrSettings->{cgi}{bin}/config/links.pl $!";
    }
    if (-e "$m_hrSettings->{cgi}{bin}/config/tree.pl") {
        copy("$m_hrSettings->{cgi}{bin}/config/tree.pl", "$cwd/blib/perl/config/tree.pl") or die "Copy failed: $m_hrSettings->{cgi}{bin}/config/tree.pl $!";
    }
    if (-e "$m_hrSettings->{cgi}{DocumentRoot}/.htaccess") {
        copy("$m_hrSettings->{cgi}{DocumentRoot}/.htaccess", "$cwd/blib/rhtml/.htaccess") or die $!;
    } elsif ($m_hrSettings->{cgi}{mod_rewrite}) {
        copy("$cwd/extra/.htaccess", "$cwd/blib/rhtml/.htaccess") or die "Copy failed: $!";
        &replace('%ALIAS%', $m_hrSettings->{cgi}{alias}, "$cwd/blib/rhtml/.htaccess");
    }
    if (-e "$cwd/extra/startup.pl") {
        copy("$cwd/extra/startup.pl", "$cwd/blib/perl/config/startup.pl") or die "Copy failed: $cwd/extra/startup.pl $!";
    }
    &replace('%PATH%',   "$m_hrSettings->{cgi}{bin}", "$cwd/blib/perl/config/startup.pl"  );
    &replace('%host%',   $m_hrSettings->{cgi}{serverName}, "$cwd/blib/perl/config/startup.pl"  );
    &replace('%CONFIG%', "$cwd/t/config.pl",    "$cwd/blib/lib/MySQL/Admin/Config.pm");
    &replace('%CONFIG%', "$cwd/t/translate.pl", "$cwd/blib/lib/MySQL/Admin/Translate.pm");
    &replace('%CONFIG%', "$cwd/t/settings.pl",  "$cwd/blib/lib/MySQL/Admin/Settings.pm");
    &replace('%CONFIG%', "$cwd/t/session.pl",   "$cwd/blib/lib/MySQL/Admin/Session.pm");
    &replace('%CONFIG%', "$cwd/t/actions.pl",   "$cwd/blib/lib/MySQL/Admin/Actions.pm");
    &replace('%CONFIG%', "$cwd/t/settings.pl",  "$cwd/blib/lib/MySQL/Admin.pm");
    &replace('%CONFIG%', "$cwd/t/config.pl",    "$cwd/blib/lib/MySQL/Admin/Config.pm");
    &replace('%CONFIG%', "$cwd/t/settings.pl",  "$cwd/blib/lib/HTML/Editor.pm");
    &replace('%CONFIG%', "$cwd/t/settings.pl",  "$cwd/blib/lib/Template/Quick.pm");
}

sub ACTION_realclean
{
    my $self = shift;
    $m_hrSettings->{database}{password} = '';
    saveSettings("$cwd/cgi-bin/config/settings.pl");
    $self->SUPER::ACTION_realclean;
}

sub ACTION_install
{
    my $self = shift;

    &replace("$cwd/blib/perl",     $m_hrSettings->{cgi}{bin},                          "$cwd/blib/perl/config/startup.pl"  );
    &replace('%host%',             $m_hrSettings->{cgi}{serverName},                   "$cwd/blib/perl/config/startup.pl"  );
    &replace("$cwd/t/config.pl",    $m_hrSettings->{cgi}{bin} . '/config/config.pl',    "$cwd/blib/lib/MySQL/Admin/Config.pm");
    &replace("$cwd/t/translate.pl", $m_hrSettings->{cgi}{bin} . '/config/translate.pl', "$cwd/blib/lib/MySQL/Admin/Translate.pm");
    &replace("$cwd/t/settings.pl",  $m_hrSettings->{cgi}{bin} . '/config/settings.pl',  "$cwd/blib/lib/MySQL/Admin/Settings.pm");
    &replace("$cwd/t/session.pl",   $m_hrSettings->{cgi}{bin} . '/config/session.pl',   "$cwd/blib/lib/MySQL/Admin/Session.pm");
    &replace("$cwd/t/actions.pl",   $m_hrSettings->{cgi}{bin} . '/config/actions.pl',   "$cwd/blib/lib/MySQL/Admin/Actions.pm");
    &replace("$cwd/t/settings.pl",  $m_hrSettings->{cgi}{bin} . '/config/settings.pl',  "$cwd/blib/lib/MySQL/Admin.pm");
    &replace("$cwd/t/settings.pl",  $m_hrSettings->{cgi}{bin} . '/config/settings.pl',  "$cwd/blib/lib/HTML/Editor.pm");
    &replace("$cwd/t/settings.pl",  $m_hrSettings->{cgi}{bin} . '/config/settings.pl',  "$cwd/blib/lib//Template/Quick.pm");
    $self->SUPER::ACTION_install;
    my %conf = (
                name => $self->{'properties'}{dbname},
                host => $self->{'properties'}{sqlhost},
                user => $self->{'properties'}{dbuser},
    );
    $conf{password} = $self->{'properties'}{dbpass} unless $self->{'properties'}{dbpass} =~ /^$/;
    eval 'use lib qw(lib);use DBI::Library ';

    unless ($@) {
        my $m_oDatabase = new DBI::Library();
        $m_oDatabase->initDB(\%conf);
        open(IN, "extra/install.sql") or die $!;
        local $/;
        my $m_sFile = <IN>;
        foreach my $sql (split /;\n/, $m_sFile) {
            $m_oDatabase->void($sql);
            print $/, $sql, $/, $@ if $@;
        }
        eval 'use MD5';
        unless ($@) {
            my $md5 = new MD5;
            $md5->add('admin');
            $md5->add($self->{'properties'}{password});
            my $fingerprint = $md5->hexdigest();
            $m_oDatabase->void(qq/insert into users (user,pass,email,`right`,cats) values(?,?,?,5,'news|draft|member')/, 'admin', $fingerprint, $self->{'properties'}{email});
        } else {
            $m_oDatabase->void(qq/insert into users (user,pass,`right`,cats) values('admin','0008e525bc0894a780297b7f3aed6f58',5,'news|draft')/);
        }
    } else {
        warn $@;
    }

    my $prefix = defined $inctance->{phash}{runtime_params}{disk}{prefix} ? $inctance->{phash}{runtime_params}{disk}{prefix} : '';
    system("chmod $m_hrSettings->{files}{chmod} -R  $prefix/$m_hrSettings->{cgi}{DocumentRoot}");
    system("chmod $m_hrSettings->{files}{chmod} -R  $prefix/$m_hrSettings->{cgi}{bin}");
    system("chown $m_hrSettings->{files}{owner}:$m_hrSettings->{files}{group} -R  $prefix/$m_hrSettings->{cgi}{DocumentRoot}");
    system("chown $m_hrSettings->{files}{owner}:$m_hrSettings->{files}{group} -R  $prefix/$m_hrSettings->{cgi}{bin}");

}

sub ACTION_uninstall
{
    my %conf = (
                name => $self->{'properties'}{dbname},
                host => $self->{'properties'}{sqlhost},
                user => $self->{'properties'}{dbuser},
    );
    if (defined $self->{'properties'}{dbpass}) {
        $conf{password} = $self->{'properties'}{dbpass} unless $self->{'properties'}{dbpass} =~ /^$/;
    }
    eval 'use lib qw(lib);use DBI::Library ';
    unless ($@) {
        my $m_oDatabase = new DBI::Library();
        $m_oDatabase->initDB(\%conf);
        open(IN, "extra/uninstall.sql") or die $!;
        local $/;
        my $m_sFile = <IN>;
        foreach my $sql (split /;\n/, $m_sFile) {
            $m_oDatabase->void($sql . ";");
            print $@ if $@;
        }
    }
}

sub change
{
    my $d = shift;
    chomp($d);
    opendir(IN, $d) or die "Install failed: $d $!:$/";
    my @files = readdir(IN);
    closedir(IN);
    for (my $i = 0; $i <= $#files; $i++) {
        unless ($files[$i] =~ /^\./) {
            my $c = "$d/$files[$i]";
            my $e = $c;
            $e =~ s/^$dir(.*)/$1/;
            unless (-d $c) {
                copy($c, "$release/$e") or die "copy failed: $! $/ $c  $/ $release/$e";
            } else {
                mkpath("$release/$e") unless (-d "$release/$e");
                &change("$d/$files[$i]") unless $files[$i] =~ /^\./;
            }
        }
    }
}

sub replace
{
    my $replace = shift;
    my $with    = shift;
    my $f       = shift;
    chmod 0644, $f;
    open(EDIT, "+<$f") or die "$! $f $/";
    my $files = '';
    while (<EDIT>) {
        $_ =~ s/$replace/$with/g;
        $files .= $_;
    }
    seek(EDIT, 0, 0);
    print EDIT $files;
    truncate(EDIT, tell(EDIT));
    close(EDIT);
    chmod 0755, $f if ($f =~ /.pl$/);
}

sub ACTION_testdb
{
    my $self = shift;
    eval("use File::Copy;");
    unless ($@) {
        copy("extra/00-DBI-Database.t", "t/00-DBI-Database.t") or die "Copy failed: $!";
        copy("extra/00-DBI-OO.t",       "t/00-DBI-OO.t")       or die "Copy failed: $!";
        copy("extra/00-DBI-FO.t",       "t/00-DBI-FO.t")       or die "Copy failed: $!";
        $self->SUPER::ACTION_test;
        unlink("t/00-DBI-Database.t");
        unlink("t/00-DBI-OO.t");
        unlink("t/00-DBI-FO.t");
    }
}

sub ACTION_install_examples
{
    my $self = shift;
    my $prefix = defined $inctance->{phash}{runtime_params}{disk}{prefix} ? $inctance->{phash}{runtime_params}{disk}{prefix} . '/' : '';

    $release = "$prefix$self->{properties}{cgi}/examples";
    use Cwd;
    my $cwd = cwd;
    $dir = $cwd . '/examples';
    mkpath("$release") unless (-d "$release");
    &change($dir);
    system("chmod 0755 -R  $release");
}
use HTML::Menu::TreeView qw(:all);
my ($htdocs, $key);
my $style = 'Crystal';
my (@modules, @r, $p, $root);
my $size       = 32;
my $Changeroot = 1;
my %Paths;

sub ACTION_install_docs
{
    my $self = shift;
    my $prefix = defined $inctance->{phash}{runtime_params}{disk}{prefix} ? $inctance->{phash}{runtime_params}{disk}{prefix} . '/' : '';
    $htdocs      = "$prefix$self->{properties}{htd}";
    $key         = "$prefix$self->{properties}{cgi}/lib";
    $root        = $key;
    @r           = split "", $root;
    $Paths{$key} = $key;
    push @modules, &recursive($key);
    documentRoot($htdocs);
    Style($style);
    size(48);
    sortTree(1);
    folderFirst(1);
    my $tree = Tree(\@modules);
    open OUT, ">$htdocs/perldoc.htm" or warn "$!";
    print OUT qq(<?xml version="1.0" encoding="iso-8859-1"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
<title>Perldoc Navigation</title>
<meta name="description" content="module2treeview"/>
<meta name="author" content="Dirk Lindner"/>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1"/>
<meta name="robots" content="index"/>
<meta name="revisit-after" content="30 days"/>
<link href="/style/$style/48/html-menu-treeview/$style.css" rel="stylesheet" type="text/css"/>
<script language="JavaScript1.5"  type="text/javascript" src="/style/treeview.js"></script>
<script language="JavaScript1.5"  type="text/javascript" src="/style/$style/48/html-menu-treeview/preload.js"></script>
</head>
<body>
<table align="left" class="mainborder" cellpadding="0"  cellspacing="0" summary="mainLayout" width="100%" >
<tr>
<td align="center">$tree</td>
</tr>
</table>
</body>
</html>);
    close(OUT);
}

sub loadSettings
{
    my $do = shift;
    if (-e $do) {
        do $do;
    }
}

sub saveSettings
{
    my $saveAs = shift;
    use Data::Dumper;
    my $content = Dumper($m_hrSettings);
    $content .= "\$m_hrSettings =\$VAR1;";
    use Fcntl qw(:flock);
    use Symbol;
    my $fh = gensym();
    my $rsas = $saveAs =~ /^(\S+)$/ ? $1 : 0;

    if ($rsas) {
        open $fh, ">$rsas.bak" or die "$/saveSettings$/ $! $/ File: $rsas";
        flock $fh, 2;
        seek $fh, 0, 0;
        truncate $fh, 0;
        print $fh $content;
        close $fh;
    }
    if (-e "$rsas.bak") {
        rename "$rsas.bak", $rsas or die "$/saveSettings$/ $! $/ File: $rsas $/";
        do $rsas;
    }
}

sub module2treeview
{
    my $module    = shift;
    my $modulname = shift;
    my $ddir      = shift;
    recursiveMkDir("$htdocs/$ddir");
    my $module2path = $module;
    $module2path =~ s?::?/?g;
    my $module2html = $modulname ? $modulname : $module;
    $module2html =~ s?::?-?g;
    $module2html =~ s?/([^/])$?$1?g;
    my $infile = undef;

    if (-e $module) {
        $infile = $module;
        $module =~ s?.*/([^/]+)$?$1?;
    }
    foreach my $key (@INC) {
        if (-e $key . "/" . $module2path . ".pm") {
            $infile = $key . "/" . $module2path . ".pm";
            last;
        }
    }
    $module =~ s/\.pm//;
    my $ffsrc = "$ddir/$module" . 'frame.html';
    my @t = (
             {
              text    => $module,
              href    => $ffsrc,
              target  => 'rightFrame',
              subtree => [openTree($module, $infile, $module2html, $ddir),],
             },
    );
    documentRoot($htdocs);
    Style($style);
    size($size);
    my $nsrc  = "$htdocs/$ddir/$module" . 'navi.html';
    my $nnsrc = "$ddir/$module" . 'navi.html';
    open OUT, ">$nsrc" or warn "$!";
    my $tree = Tree(\@t);
    print OUT qq(<?xml version="1.0" encoding="iso-8859-1"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
<title>$module2html</title>
<meta name="description" content="$module2html"/>
<meta name="author" content="Dirk Lindner"/>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1"/>
<meta name="robots" content="index"/>
<meta name="revisit-after" content="30 days"/>
<link href="/style/$style/$size/html-menu-treeview/$style.css" rel="stylesheet" type="text/css"/>
<script language="JavaScript1.5"  type="text/javascript" src="/style/treeview.js"></script>
<script language="JavaScript1.5"  type="text/javascript" src="/style/$style/$size/html-menu-treeview/preload.js"></script>
<script language="JavaScript1.5"  type="text/javascript">
     if (parent.frames.length == 0){
     location.href = "$ddir/$module.html";
}
</script>
</head>
<body>
<table align="left" class="mainborder" cellpadding="0"  cellspacing="0" summary="mainLayout" width="100%" >
<tr>
<td align="left" >$tree</td>
</tr>
</table>
</body>
</html>);
    close(OUT);
    my $fsrc = "$htdocs/$ddir/$module" . '.html';
    open FRAME, ">$fsrc" or warn $!;
    print FRAME qq(<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Frameset//EN" "http://www.w3.org/TR/html4/frameset.dtd">
<html>
<head>
<title>$module</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<meta name="robots" content="index">
</head>
<frameset cols="300,*">
<frame src="$nnsrc" name="navi">
<frame src="$ffsrc" name="rightFrame">
</frameset>
</html>);
    close(FRAME);
}

sub recursive
{
    my $d = shift;
    my @DIR;
    chomp($d);
    opendir(IN, $d) or warn "$d $!:$/";
    my @files = readdir(IN);
    closedir(IN);
    for (my $i = 0; $i <= $#files; $i++) {
        my $newFile = "$d/$files[$i]";
        unless ($files[$i] =~ /^\./) {
            my $prefix = "";
            my @fields = split "", $d;
            for (my $j = 0; $j <= $#fields; $j++) {
                $prefix .= $fields[$j] if not defined $r[$j];
            }
            my $module2html = "$prefix/$files[$i]";
            $module2html =~ s/\.pm$//;
            if (-d $newFile && ((not defined $Paths{$newFile})) && ($files[$i] ne 'auto') && !(is_empty($newFile))) {
                my $node = {
                            text    => $files[$i],
                            subtree => [&recursive($newFile)]
                };
                $node->{href} = "$module2html.html" if (-e "$newFile.pm");
                push @DIR, $node;
            } else {
                if ($files[$i] =~ /^.*\.pm$/ && has_pod($newFile)) {
                    my $m = "$prefix/$files[$i]";
                    $m =~ s?(\w)/?$1::?g;
                    $m =~ s/\///g;
                    $m =~ s/\.pm$//;
                    module2treeview($newFile, $m, $prefix);
                    push @DIR,
                      {
                        text => $m,
                        href => "$module2html.html",
                      } unless -d $m
                          && !-e "$htdocs/$module2html.html";
                }
            }
        }
    }
    return @DIR;
}

sub has_pod
{
    my $m = shift;
    use Fcntl qw(:flock);
    use Symbol;
    my $fh = gensym;
    open $fh, $m or warn "$!: $m";
    seek $fh, 0, 0;
    my @lines = <$fh>;
    close $fh;
    for (@lines) {
        return 1 if ($_ =~ /^=head1/);
    }
    return 0;
}

sub openTree
{
    my ($module, $infile, $m2, $ddir) = @_;
    my @TREEVIEW;
    $module =~ s/\.pm$//;
    my $fsrc = "$htdocs/$ddir/$module" . 'frame.html';
    system("pod2html --quiet --noindex --title=$module --infile=$infile  --outfile=$fsrc");
    use Fcntl qw(:flock);
    use Symbol;
    my $fh = gensym;
    open $fh, $fsrc or warn "$!: $fsrc";
    seek $fh, 0, 0;
    my @lines = <$fh>;
    close $fh;

    for (@lines) {
        if ($_ =~ /<li><a href="([^"]+)">(.+)<\/a>/) {
            my $href  = $1;
            my $title = $2;
            push @TREEVIEW,
              {
                text   => $title,
                href   => "$ddir/$module" . "frame.html$href",
                target => 'rightFrame',
              };
        }

        $_ =~ s/<body([^>]+)>/<body $1 onload="if (parent.frames.length == 0){location.href = '$ddir\/$module.html';}">/;
        $_ =~ s/<a/<a target="_parent" /gi;
    }
    open OUT, ">$fsrc" or warn "$!: $fsrc";
    print OUT @lines;
    close OUT;
    return @TREEVIEW;
}

sub is_empty
{
    my ($path) = @_;
    opendir DIR, $path;
    while (my $entry = readdir DIR) {
        next if ($entry =~ /^\.\.?$/);
        closedir DIR;
        return 0;
    }
    closedir DIR;
    return 1;
}

sub recursiveMkDir
{
    my $d = shift;
    my @dirs = split "/", $d;
    my $x;
    for (my $i = 0; $i <= $#dirs; $i++) {
        $x = '/' if $i == 0;
        $x .= $dirs[$i] . '/' if $dirs[$i];
        mkdir $x unless -d $x;
    }
}
END

my $inctance = $class->new(
    get_options => {skip => {store => \$skip},},
    module_name => 'MySQL::Admin',
    requires    => {
        'Test::More'                      => ">=0.7",
        'Module::Build'                   => ">=0.2808",
        'HTML::Menu::TreeView'            => ">=1.11",
        'DBI'                             => ">=1.50",
        'CGI'                             => ">=3.47",
        'HTML::Parser'                    => ">=3.56",
        'Syntax::Highlight::Engine::Kate' => ">=0.04",
        'MD5'                             => ">=2.03",
        'Frontier::RPC2'                  => ">=0.07b4",
        'Authen::Captcha'                 => ">=1.023",
        'Mail::Sendmail'                  => ">=0.79",
        'Parse::BBCode'                   => ">=0.08",
        'Syntax::Highlight::Perl'         => ">=1.00",
        'URI'                             => ">=1.40",
    },
    ($] >= 5.005 ? (AUTHOR => 'Dirk Lindner <lze@cpan.org>') : ()),
    dist_abstract      => "Admin",
    license            => "lgpl",
    create_makefile_pl => 'passthrough',
);
use Cwd;
$cwd = cwd;
$prefix = $inctance->{phash}{runtime_params}{disk}{prefix} ? $inctance->{phash}{runtime_params}{disk}{prefix} : '';
eval 'use lib qw(/srv/www/cgi-bin/lib);' if -e '/srv/www/cgi-bin/lib';
eval 'use MySQL::Admin::Settings qw(loadSettings)';
unless ($@) {
    *m_hrSettings = \$MySQL::Admin::Settings::m_hrSettings;
    loadSettings();
    loadSettings("$cwd/cgi-bin/config/settings.pl") unless -e $m_hrSettings->{cgi}{bin};
} else {
    do "$cwd/cgi-bin/config/settings.pl";
}


$inctance->{properties}{htd}         = $m_hrSettings->{cgi}{DocumentRoot}  ? $m_hrSettings->{cgi}{DocumentRoot}  : '/srv/www//htdocs';
$inctance->{properties}{cgi}         = $m_hrSettings->{cgi}{bin}           ? $m_hrSettings->{cgi}{bin}           : '/srv/www/cgi-bin';
$inctance->{properties}{server}      = $m_hrSettings->{cgi}{serverName}    ? $m_hrSettings->{cgi}{serverName}    : 'http://localhost';
$inctance->{properties}{alias}       = $m_hrSettings->{cgi}{alias}         ? $m_hrSettings->{cgi}{alias}         : 'cgi-bin';
$inctance->{properties}{mod_rewrite} = $m_hrSettings->{cgi}{mod_rewrite}   ? $m_hrSettings->{cgi}{mod_rewrite}   : 0;
$inctance->{properties}{dbname}      = $m_hrSettings->{database}{name}     ? $m_hrSettings->{database}{name}     : 'LZE';
$inctance->{properties}{dbuser}      = $m_hrSettings->{database}{user}     ? $m_hrSettings->{database}{user}     : 'root';
$inctance->{properties}{sqlhost}     = $m_hrSettings->{database}{host}     ? $m_hrSettings->{database}{host}     : 'localhost';
$inctance->{properties}{dbpass}      = $m_hrSettings->{database}{password} ? $m_hrSettings->{database}{password} : '';
$inctance->{properties}{group}       = $m_hrSettings->{files}{group}       ? $m_hrSettings->{files}{group}       : 'wwwrun';
$inctance->{properties}{owner}       = $m_hrSettings->{files}{owner}       ? $m_hrSettings->{files}{owner}       : $ENV{USER};
$inctance->{properties}{chmod}       = $m_hrSettings->{files}{chmod}       ? $m_hrSettings->{files}{chmod}       : '0.58';
$inctance->{properties}{password}    = $m_hrSettings->{admin}{pass}        ? $m_hrSettings->{admin}{pass}        : 'testpass';
$inctance->{properties}{email}       = $m_hrSettings->{admin}{email}       ? $m_hrSettings->{admin}{email}       : '';
$inctance->{properties}{dbname}      = $inctance->args('dbname')      if $inctance->args('dbname');
$inctance->{properties}{dbuser}      = $inctance->args('dbuser')      if $inctance->args('dbuser');
$inctance->{properties}{sqlhost}     = $inctance->args('sqlhost')     if $inctance->args('sqlhost');
$inctance->{properties}{dbpass}      = $inctance->args('dbpass')      if $inctance->args('dbpass');
$inctance->{properties}{cgi}         = $inctance->args('cgi')         if $inctance->args('cgi');
$inctance->{properties}{htd}         = $inctance->args('htd')         if $inctance->args('htd');
$inctance->{properties}{alias}       = $inctance->args('alias')       if $inctance->args('alias');
$inctance->{properties}{group}       = $inctance->args('group')       if $inctance->args('group');
$inctance->{properties}{chmod}       = $inctance->args('chmod')       if $inctance->args('chmod');
$inctance->{properties}{owner}       = $inctance->args('owner')       if $inctance->args('owner');
$inctance->{properties}{server}      = $inctance->args('server')      if $inctance->args('server');
$inctance->{properties}{mod_rewrite} = $inctance->args('mod_rewrite') if $inctance->args('mod_rewrite');
$inctance->{properties}{password}    = $inctance->args('password')    if $inctance->args('password');
$inctance->{properties}{email}       = $inctance->args('email')       if $inctance->args('email');
$inctance->{properties}{install_path}{perl}  = $prefix . $inctance->{properties}{cgi};
$inctance->{properties}{install_path}{rhtml} = $prefix . $inctance->{properties}{htd};

#uncomment this to install the lib files inside the cgi-bin directory
$inctance->{properties}{install_path}{lib} = $prefix . $inctance->{properties}{cgi}."/lib/";

unless ($skip) {
    my $an = Module::Build->prompt(
        "Should i use settings from previous previous version $/ Document root: $inctance->{properties}{htd} $/ cgi-bin directory:  $inctance->{properties}{cgi} $/ Server Name: $inctance->{properties}{server} $/ Script Alias  $inctance->{properties}{alias} $/ mod_rewrite:  $inctance->{properties}{mod_rewrite} $/ Mysql Server host:  $inctance->{properties}{sqlhost} $/ Mysql user name: $inctance->{properties}{dbuser} $/ Mysql password:  $inctance->{properties}{dbpass} $/ Mysql Database Name:  $inctance->{properties}{dbname}$/Files group:  $inctance->{properties}{group}$/ Files owner:  $inctance->{properties}{owner} $/ Files chmod:  $inctance->{properties}{chmod} $/ Password: $inctance->{properties}{password} $/ Email:$inctance->{properties}{email}$/",
        'yes'
    );
    $skip = $an eq 'yes' ? 1 : 0;
}
unless ($skip) {
    $inctance->{properties}{cgi} = $inctance->{properties}{cgi} ? $inctance->{properties}{cgi} : "/srv/www/cgi-bin";
    $inctance->{properties}{htd} = $inctance->{properties}{htd} ? $inctance->{properties}{htd} : "/srv/www/htdocs";
    $inctance->{properties}{htd} = Module::Build->prompt("Where is your Document root ?",     $inctance->{properties}{htd});
    $inctance->{properties}{cgi} = Module::Build->prompt("Where is your cgi-bin directory ?", $inctance->{properties}{cgi});
    $inctance->{properties}{server} = $inctance->{properties}{server} ? $inctance->{properties}{server} : "http://localhost";
    $inctance->{properties}{server} = Module::Build->prompt("Enter your Server Name", $inctance->{properties}{server});
    $inctance->{properties}{mod_rewrite} = $inctance->{properties}{mod_rewrite} ? $inctance->{properties}{mod_rewrite} : 0;
    $inctance->{properties}{mod_rewrite} = Module::Build->prompt("Should i use mod_rewrite (0 or 1)? default is 0 type 1 to enable make sure  that mod_rewrite is installed and enabled if you set this to 1!", $inctance->{properties}{mod_rewrite});
    $inctance->{properties}{alias} = $inctance->{properties}{alias} ? $inctance->{properties}{alias} : "cgi-bin";
    $inctance->{properties}{alias} = Module::Build->prompt("Enter your Script Alias", $inctance->{properties}{alias});
    $inctance->{properties}{sqlhost} = $inctance->{properties}{sqlhost} ? $inctance->{properties}{sqlhost} : "localhost";
    $inctance->{properties}{sqlhost} = Module::Build->prompt("Enter your Mysql Server host", $inctance->{properties}{sqlhost});
    $inctance->{properties}{dbuser} = $inctance->{properties}{dbuser} ? $inctance->{properties}{dbuser} : "root";
    $inctance->{properties}{dbuser} = Module::Build->prompt("Enter your Mysql user name", $inctance->{properties}{dbuser});
    $inctance->{properties}{dbpass} = $inctance->{properties}{dbpass} ? $inctance->{properties}{dbpass} : "";
    $inctance->{properties}{dbpass} = Module::Build->prompt("Enter your Mysql password", $inctance->{properties}{dbpass});
    $inctance->{properties}{dbname} = $inctance->{properties}{dbname} ? $inctance->{properties}{dbname} : "LZE";
    $inctance->{properties}{dbname}   = Module::Build->prompt("Enter your Mysql Database Name", $inctance->{properties}{dbname});
    $inctance->{properties}{owner}    = $inctance->{properties}{owner} ? $inctance->{properties}{owner} : $ENV{USER};
    $inctance->{properties}{owner}    = Module::Build->prompt("Enter your File Owner", $inctance->{properties}{owner});
    $inctance->{properties}{group}    = $inctance->{properties}{group} ? $inctance->{properties}{group} : 'wwwrun';
    $inctance->{properties}{group}    = Module::Build->prompt("Enter your File Owner Group", $inctance->{properties}{group});
    $inctance->{properties}{chmod}    = $inctance->{properties}{chmod} ? $inctance->{properties}{chmod} : '0.58';
    $inctance->{properties}{chmod}    = Module::Build->prompt("Enter your Chmod!", $inctance->{properties}{chmod});
    $inctance->{properties}{password} = Module::Build->prompt("Enter Password for login!", $inctance->{properties}{password});
    $inctance->{properties}{email}    = Module::Build->prompt("Enter your email adress!", $inctance->{properties}{email});
}

$m_hrSettings = {
    config => "$inctance->{properties}{cgi}/config/settings.pl",
    admin  => {
        email      => 'lze(a)cpan.org',
        password   =>  $inctance->{properties}{password},
        firstname  => 'Dirk',
        name       => 'Lindner',
        street     => 'example',
        town       => 'Berlin',
        number     => '33',
        postocde   => '10965',
        jahoo      => '',
        msn        => '',
        icq        => '350108541',
        tel        => '',
        country    => 'Deutschland',
        aim        => '',
        signature  => "perl -e'&{sub{s~~shift~e;s-(&*{*{*#*L*.Z*.E*.)-chr$&-eg;print}}(100105114107)'",
        skype      => 'pro_soccer',
        jabber     => ''
    },
    cgi => {
        expires      => '+1y',
        cookiePath   => '/',
        serverName   => $inctance->{properties}{server},
        DocumentRoot => $inctance->{properties}{htd},
        bin          => $inctance->{properties}{cgi},
        title        => 'MySQL::Admin',
        style        => 'lze',
        mod_rewrite  => $inctance->{properties}{mod_rewrite},
        alias        => $inctance->{properties}{alias},
    },
    language      => 'en',
    defaultAction => 'news',
    scriptAlias   => $inctance->{properties}{alias},
    uploads       => {
        maxlength => 2003153,
        path      => "$inctance->{properties}{htd}/downloads/",
        chmod     => 0644,
        enabled   => 1,
        right     => 5
    },
    tree => {
        navigation => "$inctance->{properties}{cgi}/config/tree.pl",
        links      => "$inctance->{properties}{cgi}/config/links.pl"
    },
    version   => '0.58',
    session   => "$inctance->{properties}{cgi}/config/session.pl",
    actions   => "$inctance->{properties}{cgi}/config/actions.pl",
    translate => "$inctance->{properties}{cgi}/config/translate.pl",
    database  => {
        name     => $inctance->{properties}{dbname},
        host     => $inctance->{properties}{sqlhost},
        user     => $inctance->{properties}{dbuser},
        password => $inctance->{properties}{dbpass},
        CurrentDb=> $inctance->{properties}{dbname},
        CurrentHost => $inctance->{properties}{sqlhost},
        CurrentUser => $inctance->{properties}{dbuser},
        CurrentPass =>$inctance->{properties}{dbpass},
    },
    sidebar => {
        left  => 0,
        right => 1
    },
    news => {
        maxlength => 5000,
        messages  => 10,
        right     => 5,
        captcha     => 5
    },
    size      => 16,
    htmlright => 2,
    files     => {
        group => $inctance->{properties}{group},
        owner => $inctance->{properties}{owner},
        chmod => $inctance->{properties}{chmod}
    },
    floodtime => 10,
};
saveSettings("$cwd/cgi-bin/config/settings.pl");
$inctance->create_build_script;

sub saveSettings {
    my $saveAs = shift;
    use Data::Dumper;
    my $content = Dumper($m_hrSettings);
    $content .= "\$m_hrSettings =\$VAR1;";
    use Fcntl qw(:flock);
    use Symbol;
    my $fh = gensym();
    my $rsas = $saveAs =~ /^(\S+)$/ ? $1 : 0;

    if($rsas) {
        open $fh, ">$rsas.bak" or die "$/saveSettings$/ $! $/ File: $rsas $/";
        flock $fh, 2;
        seek $fh, 0, 0;
        truncate $fh, 0;
        print $fh $content;
        close $fh;
    }
    if(-e "$rsas.bak") {
        rename "$rsas.bak", $rsas or die "$/saveSettings$/ $! $/ File: $rsas $/";
        do $rsas;
    }
}

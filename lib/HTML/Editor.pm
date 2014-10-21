package HTML::Editor;
use HTML::Window;
use MySQL::Admin qw(translate);
use utf8;
use strict;
use warnings;
use vars qw(
    $defaultconfig
    $catlist
    $class
    $DefaultClass @EXPORT  @ISA
    $path
    $m_nRight
    $server
    $m_sStyle
    $m_sTitle
    $body
    $maxlength
    $m_hrAction
    $reply
    $thread
    $headline
    $html
    $template
    $atemp
    $attach
);
require Exporter;
use Template::Quick;
@HTML::Editor::ISA         = qw( Exporter Template::Quick);
@HTML::Editor::EXPORT_OK   = qw(initEditor show );
%HTML::Editor::EXPORT_TAGS = ( 'all' => [qw(initEditor show )] );

$HTML::Editor::VERSION = '0.54';

$DefaultClass = 'HTML::Editor' unless defined $HTML::Editor::DefaultClass;

$defaultconfig = '%CONFIG%';

=head1 NAME

HTML::TabWidget -  BBCODE and HTML Editor

=head3 export_ok

initEditor show

=head3 function sets

Here is a list of the function sets you can import:

:all initEditor show


=head2 new()

=cut

sub new {
    my ( $class, @initializer ) = @_;
    my $self = {};
    bless $self, ref $class || $class || $DefaultClass;
    $self->initEditor(@initializer) if(@initializer);
    return $self;
}

=head2 initEditor()

       my %parameter =(

                action   = > 'action',

                body     => 'body of the message',

                class    => "min",

                attach   => '1',

                maxlength => '100',

                path   => "/srv/www/cgi-bin/templates",#default : '/srv/www/cgi-bin/templates'

                reply    =>  '', #default : ''

                server   => "http://localhost", #default : 'http://localhost'

                style    =>  $m_sStyle, #default : 'lze'

                thread   =>  'news',#default : ''

                headline    => "&New Message", #default : 'headline'

                html     => 1 , # html enabled ? 0 for bbcode default : 0

                text     => 'the body', #default : 'headline'

       );

       my $editor = new HTML::Editor(\%parameter);

       print $editor->show();

=cut

sub initEditor {
    my ( $self, @p ) = getSelf(@_);
    my $hash = $p[0];
    $server = defined $hash->{server} ? $hash->{server} : 'http://localhost';
    $m_sStyle = defined $hash->{style} ? $hash->{style} : 'lze';
    $m_sTitle = defined $hash->{title} ? $hash->{title} : 'Editor';
    $path
        = defined $hash->{path}
        ? $hash->{path}
        : '/srv/www/cgi-bin/templates';
    $body      = defined $hash->{body}      ? $hash->{body}      : 'Text';
    $maxlength = defined $hash->{maxlength} ? $hash->{maxlength} : '300';
    $m_hrAction = defined $hash->{action} ? $hash->{action} : 'addMessage';
    $reply      = defined $hash->{reply}  ? $hash->{reply}  : '';
    $thread     = defined $hash->{thread} ? $hash->{thread} : 'news';
    $headline = defined $hash->{headline} ? $hash->{headline} : 'headline';
    $catlist  = defined $hash->{catlist}  ? $hash->{catlist}  : '';
    $m_nRight = defined $hash->{right}    ? $hash->{right}    : 0;
    $html     = $hash->{html}             ? $hash->{html}     : 0;
    $template = defined $hash->{template} ? $hash->{template} : "editor.htm";
    $atemp    = defined $hash->{atemp}    ? $hash->{atemp}    : '';
    $attach    = defined $hash->{attach}    ? $hash->{attach}    : '';
    my $config = defined $hash->{config} ? $hash->{config} : $defaultconfig;
    $class = 'min' unless ( defined $class );
    my %template = (
        path     => $hash->{path},
        style    => $m_sStyle,
        template => $template,
        config   => $config,
    );
    $self->SUPER::initTemplate( \%template );
}

=head2 show()

=cut

sub show {
    my ( $self, @p ) = getSelf(@_);
    $self->initEditor(@p) if(@p);
    my %parameter = (
        path   => $path,
        style  => $m_sStyle,
        title  => $m_sTitle,
        server => $server,
        id     => 'winedit',
        class  => $class,
    );
    my $output = '<br/>';
    my $window = new HTML::Window( \%parameter );
    $output .= $window->windowHeader();
    my $att
        = ( $m_nRight >= 2 )
        ? translate('choosefile')
        . ':<input name="file" type="file" accept="text/*" maxlength="2097152" size ="30" />'
        : $attach ;
    my %editor = (
        name      => 'editor',
        server    => $server,
        style     => $m_sStyle,
        title     => $m_sTitle,
        body      => $body,
        maxlength => $maxlength,
        action    => $m_hrAction,
        reply     => $reply,
        thread    => $thread,
        headline  => $headline,
        catlist   => $catlist,
        attach    => $att,
        html      => $html,
        atemp     => $atemp,
    );
    $output .= $self->SUPER::appendHash( \%editor );
    $output .= $window->windowFooter();
    return $output;

}

=head2 getSelf()

=cut

sub getSelf {
    return @_
        if defined( $_[0] )
            && ( !ref( $_[0] ) )
            && ( $_[0] eq 'HTML::Editor' );
    return (
        defined( $_[0] )
            && ( ref( $_[0] ) eq 'HTML::Editor'
            || UNIVERSAL::isa( $_[0], 'HTML::Editor' ) )
    ) ? @_ : ( $HTML::Editor::DefaultClass->new, @_ );
}

=head1 AUTHOR

Dirk Lindner <lze@cpan.org>

L<CGI> L<HTML::Editor::BBCODE> L<MySQL::Admin::GUI>

=head1 LICENSE

Copyright (C) 2005 - 2008 by Hr. Dirk Lindner

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU Lesser General Public License
as published by the Free Software Foundation;
This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Lesser General Public License for more details.

=cut

1;

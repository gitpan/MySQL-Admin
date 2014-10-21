package MySQL::Admin::Main;
use Template::Quick;
use strict;
use warnings;
require Exporter;
use vars
    qw($DefaultClass @EXPORT  @ISA  $login $m_nRight $htmlright $template $zoom);
our $m_sStyle = 'lze';
our $m_sTitle = '';
our $m_nSize  = 16;
our $server;
@MySQL::Admin::Main::EXPORT_OK   = qw(all initMain Header Footer);
%MySQL::Admin::Main::EXPORT_TAGS = ( 'all' => [qw(initMain Header Footer)] );
@MySQL::Admin::Main::ISA         = qw( Exporter Template::Quick);
$MySQL::Admin::Main::VERSION     = '0.43';
$DefaultClass                    = 'MySQL::Admin::Main'
    unless defined $MySQL::Admin::Main::DefaultClass;

=head1 NAME

MySQL::Admin::Main.pm  Main template for MySQL::Admin::GUI

=head1 SYNOPSIS

see l<MySQL::Admin::GUI>

=head1 DESCRIPTION

load The "Main Template" for MySQL::Admin::GUI

=head2 EXPORT

=head1 SEE ALSO

L<MySQL::Admin::GUI> L<Template::Quick>

=head1 Public

=head2 new()

=cut

sub new {
    my ( $class, @initializer ) = @_;
    my $self = {};
    bless $self, ref $class || $class || $DefaultClass;
    $self->initMain(@initializer) if (@initializer);
    return $self;
}

=head2 initMain()

     my %patmeter =(

     path => "path to cgi-bin",

     style  => "style to use",

     title  => "title";

     htmlright => '',

     login  => '',

     template =>'index.html',

     );

     init(\%patmeter);

=cut

sub initMain {
    my ( $self, @p ) = getSelf(@_);
    my $hash = $p[0];
    $server    = $hash->{server};
    $m_sStyle  = defined $hash->{style} ? $hash->{style} : 'lze';
    $m_nSize   = defined $hash->{size} ? $hash->{size} : 16;
    $m_sTitle  = defined $hash->{title} ? $hash->{title} : '';
    $zoom      = defined $hash->{zoom} ? $hash->{zoom} : '';
    $login     = defined $hash->{login} ? $hash->{login} : '';
    $m_nRight  = defined $hash->{right} ? $hash->{right} : 0;
    $htmlright = defined $hash->{htmlright} ? $hash->{htmlright} : 2;
    $template  = defined $hash->{template} ? $hash->{template} : "index.htm";
    my %template = ( path     => $hash->{path},
                     style    => $m_sStyle,
                     template => $template,
    );
    $self->SUPER::initTemplate( \%template );
}

=head2 Header()

=cut

sub Header {
    my ( $self, @p ) = getSelf(@_);
    my %header = ( name      => 'bodyHeader',
                   size      => $m_nSize,
                   server    => $server,
                   style     => $m_sStyle,
                   title     => $m_sTitle,
                   login     => $login,
                   right     => $m_nRight,
                   htmlright => $htmlright,
                   zoom      => $zoom
    );
    $self->SUPER::appendHash( \%header );
}

=head2 Footer()

=cut

sub Footer {
    my ( $self, @p ) = getSelf(@_);
    my %footer = ( name  => 'bodyFooter',
                   style => $m_sStyle,
                   zoom  => $zoom
    );
    $self->SUPER::appendHash( \%footer );
}

=head1 PRIVAT

=head2 getSelf()

see L<HTML::Menu::TreeView>

=cut

sub getSelf {
    return @_
        if defined( $_[0] )
            && ( !ref( $_[0] ) )
            && ( $_[0] eq 'MySQL::Admin::Main' );
    return ( defined( $_[0] )
                 && ( ref( $_[0] ) eq 'MySQL::Admin::Main'
                      || UNIVERSAL::isa( $_[0], 'MySQL::Admin::Main' ) )
    ) ? @_ : ( $MySQL::Admin::Main::DefaultClass->new, @_ );
}

=head1 AUTHOR

Dirk Lindner <lze@cpan.org>

=head1 LICENSE

Copyright (C) 2008 by Hr. Dirk Lindner

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU Lesser General Public License
as published by the Free Software Foundation;
This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Lesser General Public License for more details.

=cut

1;

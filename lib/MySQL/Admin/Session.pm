package MySQL::Admin::Session;
use strict;
use warnings;
require Exporter;
use vars qw( $session $DefaultClass @EXPORT  @ISA $defaultconfig);
@MySQL::Admin::Session::EXPORT = qw(loadSession saveSession $session);
use MySQL::Admin::Config;
@MySQL::Admin::Session::ISA     = qw(Exporter MySQL::Admin::Config);
$MySQL::Admin::Session::VERSION = '0.51';
$DefaultClass                   = 'MySQL::Admin::Session'
    unless defined $MySQL::Admin::Session::DefaultClass;
$defaultconfig = '%CONFIG%';

=head1 NAME

MySQL::Admin::Session - store the sessions for MySQL::Admin

=head1 SYNOPSIS

see l<MySQL::Admin>

=head1 DESCRIPTION

session for MySQL::Admin.

=head2 EXPORT

loadConfig() saveSession() $session

=head1 Public

=head2 new

=cut

sub new {
    my ( $class, @initializer ) = @_;
    my $self = {};
    bless $self, ref $class || $class || $DefaultClass;
    return $self;
}

=head2 loadConfig

=cut

sub loadSession {
    my ( $self, @p ) = getSelf(@_);
    my $do = ( defined $p[0] ) ? $p[0] : $defaultconfig;
    if ( -e $do ) { do $do; }
}

=head2 saveSession

=cut

sub saveSession {
    my ( $self, @p ) = getSelf(@_);
    my $l = defined $p[0] ? $p[0] : $defaultconfig;
    $self->SUPER::saveConfig( $l, $session, 'session' );
}

=head1 Private

=head2 getSelf

=cut

sub getSelf {
    return @_
        if defined( $_[0] )
            && ( !ref( $_[0] ) )
            && ( $_[0] eq 'MySQL::Admin::Session' );
    return ( defined( $_[0] )
                 && ( ref( $_[0] ) eq 'MySQL::Admin::Session'
                      || UNIVERSAL::isa( $_[0], 'MySQL::Admin::Session' ) )
        )
        ? @_
        : ( $MySQL::Admin::Session::DefaultClass->new, @_ );
}
1;

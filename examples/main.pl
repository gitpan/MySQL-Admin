#!/usr/bin/perl -w
use lib("../lib");
use strict;
use MySQL::Admin qw(:all);
print header();
use MySQL::Admin::Main;
my %set = (
path   => "../templates",
size   => 16,
style  => "lze",
title  => "MySQL::Admin::Main",
server => "http://localhost",
);
my $main = new MySQL::Admin::Main( );
$main->initMain( \%set );
print $main->Header();
use showsource;
&showSource("./main.pl");
print $main->Footer();

#!/usr/bin/perl -w
use lib qw(lib);
use strict;
use MySQL::Admin::GUI::Main;
my %set = (
    path   => "./templates",
    size   => 16,
    style  => "lze",
    title  => "MySQL::Admin::GUI::Main",
    server => "http://localhost",
    login  => "",
);
my $main = new MySQL::Admin::GUI::Main( \%set );
use MySQL::Admin qw(header);
print header;
print $main->Header();
use showsource;
&showSource("./main.pl");
print $main->Footer();

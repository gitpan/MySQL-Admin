package HTML::Editor::BBCODE;
use strict;
use warnings;
use vars qw(@EXPORT @ISA $currentstring @formatString);
require Exporter;
@HTML::Editor::BBCODE::EXPORT  = qw(BBCODE);
@ISA                           = qw(Exporter);
$HTML::Editor::BBCODE::VERSION = '0.44';
use Parse::BBCode;
use Syntax::Highlight::Engine::Kate;

# use Syntax::Highlight::Perl;

=head1 NAME

HTML::Editor::BBCODE - BBCODE for HTML::Editor

=head1 required Modules

Syntax::Highlight::Engine::kate

Parse::BBCode

=head1 SYNOPSIS

        use HTML::Editor::BBCODE;

        my $test = '

        [code=Perl]

        print "testIt";

        [/code]

        ';

        BBCODE(\$test);

        print $test;

=head1 DESCRIPTION

see <L Parse::BBCode> and <L Syntax::Highlight::Engine::kate>

Supported BBCODE

     [left]left[/left]

     [center]center[/center]

     [right]right[/right]

     [b]bold[/b]

     [i]italic[/i]

     [s]strike[/s]

     [u]underline[/u]

     [sub]sub[/sub]

     [sup]sup[/sup]

     [img]http://url[/img]

     [url=http://url.de]link[/url]

     [email=email@url.de]mail me[/email]

     [color=red]color[/color]

     [google]lindnerei.de[/google]

     [blog=http://referer]text[/blog]

     [h1]h1[/h1]

     [h2]h2[/h2]

     [h3]h3[/h3]

     [h4]h4[/h4]

     [h5]h5[/h5]

     [ul]

     [li]1[/li]

     [li]2[/li]

     [li]3[/li]

     [/ul]

     [ol]

     [li]1[/li]

     [li]2[/li]

     [li]3[/li]

     [/ol]

     [hr]

Syntax Highlight tags

[code=lang]...[/code]

lang tags:

        Bash

        C++

        CSS

        HTML

        Java

        JavaScript

        PHP

        Perl

        Python

        Ruby

        XML

 en de tags


=head2 EXPORT

BBCODE()

=head2 BBCODE

=cut

=head1 Public

=head2 BBCODE

=cut

sub BBCODE {
    my $string          = shift;
    my $ACCEPT_LANGUAGE = shift;
    $ACCEPT_LANGUAGE = defined $ACCEPT_LANGUAGE ? $ACCEPT_LANGUAGE : 'de';
    my $p = Parse::BBCode->new(
        {  tags => {
               '' => sub {
                   my $e = Parse::BBCode::escape_html( $_[2] );
                   $e =~ s/\r?\n|\r/<br\/>\n/g;
                   $e;
               },
               i     => '<i>%s</i>',
               b     => '<b>%{parse}s</b>',
               u     => '<u>%{parse}s</u>',
               h1    => '<h1>%{parse}s</h1>',
               h2    => '<h2>%{parse}s</h2>',
               h3    => '<h3>%{parse}s</h3>',
               h4    => '<h4>%{parse}s</h4>',
               h5    => '<h5>%{parse}s</h5>',
               ol    => '<ol>%{parse}s</ol>',
               ul    => '<ul>%{parse}s</ul>',
               li    => '<li>%{parse}s</li>',
               sup   => '<sup>%{parse}s</sup>',
               s     => '<s>%{parse}s</s>',
               sub   => '<sub>%{parse}s</sub>',
               size  => '<font size="%a">%{parse}s</font>',
               url   => '<a href="%{link}A">%{parse}s</a>',
               quote => 'block:<blockquote>%s</blockquote>',
               color => '<span style="color:%{uri}A">%{parse}s</span>',
               img   => '<img src="%{parse}s" border="0" alt=""/>',
               email =>
                   'Email:<a target="_blank" href="mailto:%{uri}A">%{parse}s</a>',
               google =>
                   'Google:<a href="http://www.google.de/search?q=%{uri}A">%{parse}s</a>',
               blog =>
                   '<table  cellpadding="0" cellspacing="0" border="0"><tr><td><table  cellpadding="5" cellspacing="0"  border="0" class="blog"><tr><td>%{parse}s</td></tr></table></td></tr><tr><td><b><a href="%{uri}A" class="link">Quelle</a></b></td></tr></table>',
               left   => '<div align="left">%{parse}s</div>',
               center => '<div align="center">%{parse}s</div>',
               right  => '<div align="right">%{parse}s</div>',
               code   => {
                   code => sub {
                       my ( $parser, $attr, $content, $attribute_fallback ) =
                           @_;
                       if ( $attr eq 'Perl' ) {
                           use Syntax::Highlight::Perl ':FULL';
                           my $color_Keys = {
                                 'Variable_Scalar' => 'Variable_ # or Scalar',
                                 'Variable_Array'  => 'Variable_Array',
                                 'Variable_Hash'   => 'Variable_Hash',
                                 'Variable_Typeglob' => 'Variable_Typeglob',
                                 'Subroutine'        => 'Subroutine',
                                 'Quote'             => 'Quote',
                                 'String'            => 'String',
                                 'Comment_Normal'    => 'Comment_Normal',
                                 'Comment_POD'       => 'Comment_POD',
                                 'Bareword'          => 'Bareword',
                                 'Package'           => 'Package',
                                 'Number'            => 'Number',
                                 'Operator'          => 'Operator',
                                 'Symbol'            => 'Symbol',
                                 'Character'         => 'Character',
                                 'Directive'         => 'Directive',
                                 'Label'             => 'Label',
                                 'Line'              => 'Line',
                           };
                           my $formatter = new Syntax::Highlight::Perl;
                           $formatter->define_substitution( '<' => '&lt;',
                                                            '>' => '&gt;',
                                                            '&' => '&amp;',
                           );    # HTML escapes.
                           while ( my ( $type, $style ) =
                                   each %{$color_Keys} )
                           {
                               $formatter->set_format( $type,
                                   [ qq|<span class="$style">|, '</span>' ] );
                           }
                           my $perldoc_Keys = {
                                     'Builtin_Operator' => 'Builtin_Operator',
                                     'Builtin_Function' => 'Builtin_Function',
                                     'Keyword'          => 'Keyword',
                           };
                           while ( my ( $type, $style ) =
                                   each %{$perldoc_Keys} )
                           {
                               $formatter->set_format(
                                   $type,
                                   [  qq|<a onclick="window.open('http://perldoc.perl.org/search.html?q='+this.innerHTML)" class="$style">|,
                                      "</a>"
                                   ]
                               );
                           }
                           $content = $formatter->format_string($$content);

                       } elsif ( $parser =~
                           /(Java|C\+\+|XML|Ruby|Python|PHP|JavaScript|HTML|CSS|Bash)/
                           )
                       {
                           $content = formatString( $$content, $1 );
                       } else {
                           $content = Parse::BBCode::escape_html($$content);
                       }
                       return
                           qq|<div style="100%;overflow:auto"><pre>$content</pre></div>|;
                   },
                   parse => 0,
                   class => 'block',
               },
               hr => { class  => 'block',
                       output => '<hr/>',
                       single => 1,
               },
               br => { class  => 'block',
                       output => '<br/>',
                       single => 1,
               },
           },
        }
    );

    if ( $ACCEPT_LANGUAGE eq 'de' ) {
        $$string =~ s/\[en\](.*?)\[\/en\]//gs;
        $$string =~ s/\[de\](.*?)\[\/de\]/$1/gs;
    } else {
        $$string =~ s/\[en\](.*?)\[\/en\]/$1/gs;
        $$string =~ s/\[de\](.*?)\[\/de\]//gs;
    }

    $$string = $p->render($$string);
}

sub formatString {
    my ( $string, $lang ) = @_;
    use Syntax::Highlight::Engine::Kate;
    my $hl = new Syntax::Highlight::Engine::Kate(
        language      => $lang,
        substitutions => {
            "<" => "&lt;",
            ">" => "&gt;",
            "&" => "&amp;",

        },
        format_table => {
            Alert   => [ "<span style=\"color:#0000ff\">",    "</span>" ],
            BaseN   => [ "<span style=\"color:#007f00\">",    "</span>" ],
            BString => [ "<span style=\"color:#c9a7ff\">",    "</span>" ],
            Char    => [ "<span style=\"color:#ff00ff\">",    "</span>" ],
            Comment => [ "<span style=\"color:#7f7f7f\"><i>", "</i></span>" ],
            DataType => [ "<span style=\"color:#0000ff\">", "</span>" ],
            DecVal   => [ "<span style=\"color:#00007f\">", "</span>" ],
            Error =>
                [ "<span style=\"color:#ff0000\"><b><i>", "</i></b></span>" ],
            Float    => [ "<span style=\"color:#00007f\">", "</span>" ],
            Function => [ "<span style=\"color:#007f00\">", "</span>" ],
            IString  => [ "<span style=\"color:#ff0000\">", "" ],
            Keyword  => [ "<b>",                            "</b>" ],
            Normal   => [ "",                               "" ],
            Operator => [ "<span style=\"color:#ffa500\">", "</span>" ],
            Others   => [ "<span style=\"color:#b03060\">", "</span>" ],
            RegionMarker =>
                [ "<span style=\"color:#96b9ff\"><i>", "</i></span>" ],
            Reserved =>
                [ "<span style=\"color:#9b30ff\"><b>", "</b></span>" ],
            String => [ "<span style=\"color:#ff0000\">", "</span>" ],
            Variable =>
                [ "<span style=\"color:#0000ff\"><b>", "</b></span>" ],
            Warning =>
                [ "<span style=\"color:#0000ff\"><b><i>", "</b></i></span>" ],
        },
    );
    my $rplc = $hl->highlightText($string);
    $rplc = qq(<div style="100%;overflow:auto"><pre>$rplc</pre></div>);
    return $rplc;
}

=head1 AUTHOR

Dirk Lindner <lze@cpan.org>

L<CGI> L<Parse::BBCode> L<HTML::Editor> L<MySQL::Admin::GUI>

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

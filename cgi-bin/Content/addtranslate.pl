my $title = translate('editTranslation');
my %parameter = (
                 path   => $m_hrSettings->{cgi}{bin} . '/templates',
                 style  => $m_sStyle,
                 title  => $title,
                 server => $m_hrSettings->{cgi}{serverName},
                 id     => "editTranslation",
                 class  => 'min',
);
my $window = new HTML::Window(\%parameter);
$window->set_closeable(0);
$window->set_moveable(0);
$window->set_resizeable(0);
$m_sContent .= $window->windowHeader();

loadTranslate($m_hrSettings->{translate});
*m_hrLng = \$MySQL::Admin::Translate::lang;
my @l;
foreach my $key (sort keys %{$m_hrLng}) {
    push @l, $key;
}
$m_sContent .= start_form(-method => "POST",
                          -action => "$ENV{SCRIPT_NAME}",)
  . hidden({-name => 'action'}, 'showaddTranslation')
  . hidden(
           {
            -name    => 'do',
            -default => '1'
           },
           'true'
  )
  . table(
          {
           -align  => 'center',
           -border => 0,
           width   => "70%"
          },
          caption('Add translation'),
          Tr(
              {
               -align  => 'left',
               -valign => 'top'
              },
              td("Key"),
              td(
                  textfield(
                            {
                             -style => "width:100%",
                             -name  => 'key'
                            },
                            'name'
                  )
              )
          ),
          Tr(
              {
               -align  => 'left',
               -valign => 'top'
              },
              td("Txt"),
              td(
                  textfield(
                            {
                             -style => "width:100%",
                             -name  => 'txt'
                            },
                            'txt'
                  )
              )
          ),
          Tr(
              {
               -align  => 'left',
               -valign => 'top'
              },
              td("Language "),
              td(
                  popup_menu(
                             -onchange => "setLang(this.options[this.options.selectedIndex].value)",
                             -name     => 'lang',
                             -values   => [@l],
                             -style    => "width:100%"
                  ),
              )
          ),
          Tr(
              {
               -align  => 'right',
               -valign => 'top'
              },
              td({colspan => 2}, submit(-value => 'Add Translation'))
          )
  ) . end_form;
if (param('do')) {
    my $key = param('key');
    my $txt = param('txt');
    my $lgn = param('lang');
    unless (defined $m_hrLng->{$lgn}{$key}) {
        $m_hrLng->{$lgn}{$key} = $txt;
        $m_sContent .= "Translation added $lgn<br/>$key:  $m_hrLng->{$lgn}{$key}<br/>";
        saveTranslate($m_hrSettings->{translate});
        loadTranslate($m_hrSettings->{translate});
    } else {
        $m_sContent .= "Key already defined<br/>$key:  $m_hrLng->{$lgn}{$key}<br/>";
    }

}
$m_sContent .= $window->windowFooter();
1;

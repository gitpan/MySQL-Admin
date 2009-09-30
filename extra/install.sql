CREATE TABLE actions (
  `action` varchar(100) NOT NULL default '',
  `file` varchar(100) NOT NULL default '',
  title varchar(100) NOT NULL default '',
  `right` int(1) NOT NULL default '0',
  box varchar(500) default NULL,
  sub varchar(25) NOT NULL default 'main',
  `id` int(11) NOT NULL auto_increment,
  PRIMARY KEY  (id)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('news','news.pl','Blog',0,'news;navigation;verify','show',1);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('settings','quick.pl','Settings',5,'','main',2);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('addNews','news.pl','newMessage',1,'news;navigation;verify','addNews',3);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('admin','admin.pl','adminCenter',5,'navigation;','main',4);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('delete','news.pl','blog',5,'news;navigation;verify','deleteNews',5);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('edit','news.pl','blog',5,'news;navigation;verify','editNews',6);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('saveedit','news.pl','blog',5,'news;navigation;verify','saveedit',7);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('reply','news.pl','blog',0,'news;navigation;verify','replyNews',8);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('profile','profile.pl','Profile',1,'navigation;','main',9);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('reg','reg.pl','register',0,'navigation;','reg',11);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('addReply','news.pl','blog',0,'news;navigation;verify','addReply',12);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('showthread','news.pl','blog',0,'news;navigation;verify','showMessage',13);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('makeUser','reg.pl','register',0,0,'make',14);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('verify','reg.pl','verify',0,0,'navigation;',15);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('fulltext','search.pl','search',0,'navigation;','fulltext',26);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('newTreeviewEntry','editTree.pl','newTreeViewEntry',5,'navigation;','newTreeviewEntry',27);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('saveTreeviewEntry','editTree.pl','saveTreeviewEntry',5,'navigation;','saveTreeviewEntry',28);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('editTreeview','editTree.pl','editTreeview',5,'navigation;','editTreeview',29);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('addTreeviewEntry','editTree.pl','addTreeviewEntry',5,'navigation;','addTreeviewEntry',30);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('editTreeviewEntry','editTree.pl','editTreeviewEntry',5,'navigation;','editTreeviewEntry',31);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('deleteTreeviewEntry','editTree.pl','deleteTreeviewEntry',5,'navigation;','deleteTreeviewEntry',32);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('upEntry','editTree.pl','upEntry',5,'navigation;','upEntry',33);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('downEntry','editTree.pl','downEntry',5,'navigation;','downEntry',34);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('links','links.pl','Bookmarks',0,'navigation;','ShowBookmarks',35);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('env','env.pl','env',5,'navigation;','main',36);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('lostpass','login.pl','lostpass',0,0,'lostpass',38);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('getpass','login.pl','getpass',0,0,'getpass',39);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('showDir','files.pl','Files',5,'navigation','showDir',42);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('FileOpen','files.pl','FileOpen',5,'navigation','FileOpen',43);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('newFile','files.pl','newFile',5,'navigation','newFile',44);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('saveFile','files.pl','saveFile',5,'navigation','saveFile',45);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('showMessage','news.pl','blog',0,'news;navigation;verify','main',18);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('chmodFile','files.pl','chmodFile',5,'navigation','chmodFile',49);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('deleteFile','files.pl','deleteFile',5,'navigation','deleteFile',50);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('makeDir','files.pl','Files',5,'navigation','makeDir',52);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('newGbookEntry','gbook.pl','gbook',0,'navigation','newGbookEntry',55);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('addnewGbookEntry','gbook.pl','gbook',0,'navigation','addnewGbookEntry',56);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('gbook','gbook.pl','gbook',0,'navigation','showGbook',57);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('deleteExploit','admin.pl','Admin',5,'navigation','deleteExploit',59);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('showEditor','news.pl','NewPost',0,'navigation;verify','showEditor',61);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('AddFulltext','tables.pl','AddFulltext',5,'tables;navigation','AddFulltext',62);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('AnalyzeTable','tables.pl','AnalyzeTable',5,'tables;navigation','AnalyzeTable',63);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('AddPrimaryKey','tables.pl','AddPrimaryKey',5,'tables;navigation','AddPrimaryKey',64);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('ChangeEngine','tables.pl','ChangeEngine',5,'tables;navigation','ChangeEngine',65);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('ChangeAutoInCrementValue','tables.pl','ChangeAutoInCrementValue',5,'tables;navigation','ChangeAutoInCrementValue',66);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('ChangeCol','tables.pl','ChangeCol',5,'tables;navigation','ChangeCol',67);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('ChangeEngine','tables.pl','ChangeEngine',5,'tables;navigation','ChangeEngine',68);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('ChangeCharset','tables.pl','ChangeCharset',5,'tables;navigation','ChangeCharset',69);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('ChangeAutoInCrementValue','tables.pl','ChangeAutoInCrementValue',5,'tables;navigation','ChangeAutoInCrementValue',70);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('ChooseDataBase','tables.pl','ChooseDataBase',5,'tables;navigation','ChooseDataBase',71);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('DropTable','tables.pl','DropTable',5,'tables;navigation;','DropTable',72);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('DeleteEntry','tables.pl','DeleteEntry',5,'tables;navigation;','DeleteEntry',73);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('DropCol','tables.pl','DropCol',5,'tables;navigation','DropCol',74);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('ShowDumpTable','tables.pl','DumpTable',5,'tables;navigation','ShowDumpTable',75);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('ExecSql', 'tables.pl','ExecSql',5,'tables;navigation','ExecSql',76);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('EditTable','tables.pl','SQL',5,'tables;navigation','EditTable',77);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('EditEntry','tables.pl','EditEntry',5,'tables;navigation;','EditEntry',78);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('NewEntry', 'tables.pl','NewEntry',5,'tables;navigation;','NewEntry',79);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('NewTable','tables.pl','NewTable',5,'tables;navigation','NewTable',80);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('CreateDatabase','tables.pl','CreateDatabase',5,'tables;navigation','CreateDatabase',81);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('OptimizeTable','tables.pl','OptimizeTable',5,'tables;navigation','OptimizeTable',82);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('RepairTable','tables.pl','RepairTable',5,'tables;navigation','RepairTable',84);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('SaveEditTable','tables.pl','SaveEditTable',5,'tables;navigation','SaveEditTable',85);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('SQL','tables.pl','SQL',5,'tables;navigation','SQL',86);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('ShowNewTable','tables.pl','ShowNewTable',5,'tables;navigation','ShowNewTable',87);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('SaveEntry','tables.pl','SaveEntry',5,'tables;navigation;','SaveEntry',88);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('DropFulltext','tables.pl','DropFulltext',5,'tables;navigation','DropFulltext',89);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('ShowTables','tables.pl','ShowTables',5,'tables;navigation','ShowTables',90);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('ShowTableDetails','tables.pl','ShowTableDetails',5,'tables;navigation;','ShowTableDetails',91);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('ShowTable','tables.pl','ShowTable',5,'tables;navigation;','ShowTable',92);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('TruncateTable','tables.pl','TruncateTable',5,'tables;navigation','TruncateTable',93);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('ShowProcesslist','tables.pl','ShowProcesslist',5,'tables;navigation','ShowProcesslist',94);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('DropFulltext','tables.pl','DropFulltext',5,'tables;navigation','DropFulltext',95);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('AddIndex','tables.pl','DropFulltext',5,'tables;navigation','AddIndex',96);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('DropIndex','tables.pl','DropFulltext',5,'tables;navigation','DropIndex',97);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('AddUnique','tables.pl','DropFulltext',5,'tables;navigation','AddUnique',98);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('ShowNewEntry','tables.pl','ShowNewEntry',5,'tables;navigation','ShowNewEntry',99);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('SaveEntry','tables.pl','SaveEntry',5,'tables;navigation','SaveEntry',100);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('NewEntry','tables.pl','NewEntry',5,'tables;navigation','NewEntry',101);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('DeleteEntry','tables.pl','DeleteEntry',5,'tables;navigation','DeleteEntry',102);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('MultipleAction','tables.pl','MultipleAction',5,'tables;navigation','MultipleAction',104);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('ShowDumpDatabase','tables.pl','DumpDatabase',5,'tables;navigation','ShowDumpDatabase',105);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('ShowNewTable','tables.pl','ShowNewTable',5,'tables;navigation','ShowNewTable',106);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('SaveNewTable','tables.pl','SaveNewTable',5,'tables;navigation','SaveNewTable',107);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('ImportOperaBookmarks','links.pl','ImportOperaBookmarks',5,'navigation','ImportOperaBookmarks',108);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('linkseditTreeview','editTree.pl','linkseditTreeview',5,'navigation','linkseditTreeview',109);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('EditFile','files.pl','EditAction',5,'navigation','EditFile',110);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('EditAction','tables.pl','EditAction',5,'tables;navigation','EditAction',111);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('EditTopMenu','tables.pl','EditAction',5,'tables;navigation','EditTopMenu',112);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('EditVertMenu','tables.pl','EditAction',5,'tables;navigation','EditVertMenu',113);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('ExportOperaBookmarks','links.pl','ExportOperaBookmarks',0,'navigation','ExportOperaBookmarks',114);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('MoveTreeViewEntry','editTree.pl','MoveTreeViewEntry',5,'navigation','MoveTreeViewEntry',115);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('MultipleDbAction','tables.pl','MultipleDbAction',5,'tables;navigation','MultipleDbAction',118);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('RenameTable','tables.pl','RenameTable',5,'tables;navigation','RenameTable',119);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('SaveNewColumn','tables.pl','SaveNewColumn',5,'tables;navigation','SaveNewColumn',120);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('NewDatabase','tables.pl','NewDatabase',5,'tables;navigation','NewDatabase',121);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('ShowEditIndex','tables.pl','ShowEditIndex',5,'tables;navigation','ShowEditIndex',122);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('SaveNewIndex','tables.pl','SaveNewIndex',5,'tables;navigation','SaveNewIndex',123);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('ChangeEngine','tables.pl','ChangeEngine',5,'tables;navigation','ChangeEngine',124);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('ChangeAutoInCrementValue','tables.pl','ChangeEngine',5,'tables;navigation','ChangeAutoInCrementValue',125);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('ShowRights','tables.pl','ShowRights',5,'tables;navigation','ShowRights',127);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('SaveRights','tables.pl','SaveRights',5,'tables;navigation','SaveRights',128);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('ShowUsers','tables.pl','ShowUsers',5,'tables;navigation','ShowUsers',129);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('CreateUser','tables.pl','CreateUser',5,'tables;navigation','CreateUser',130);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('DeleteUser','tables.pl','DeleteUser',5,'tables;navigation','DeleteUser',131);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('DropDatabase','tables.pl','DropDatabase',5,'tables;navigation','DropDatabase',132);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('ShowDatabases','tables.pl','ShowDatabases',5,'tables;navigation','ShowDatabases',133);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('ShowProcesslist','tables.pl','ShowProcesslist',5,'tables;navigation','ShowProcesslist',134);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('ShowVariables','tables.pl','ShowVariables',5,'tables;navigation','ShowVariables',135);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('chownFile','files.pl','chownFile',5,'tables;navigation','chownFile',136);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('ImportFireFoxBookmarks','links.pl','ImportFireFoxBookmarks',5,'navigation','ImportFireFoxBookmarks',137);
INSERT INTO actions (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) values('rebuildtrash','news.pl','weblog','5','news;navigation','rebuildtrash','138');
INSERT INTO actions (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) values('trash','news.pl','trash','5','navigation','trash','139');
INSERT INTO actions (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) values('showaddTranslation','addtranslate.pl','showaddTranslation','5','navigation','main','140');
INSERT INTO actions (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) values('translate','translate.pl','translate','5','navigation','main','141');
CREATE TABLE box (
  `file` varchar(100) NOT NULL default '',
  position varchar(8) NOT NULL default 'left',
  `right` int(1) NOT NULL default '0',
  `name` varchar(100) NOT NULL default '',
  `id` int(11) NOT NULL auto_increment,
  `dynamic` varchar(10) default NULL,
  PRIMARY KEY  (id)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
INSERT INTO box (`file`,position,`right`,name,id,dynamic) VALUES('navigation.pl','disabled',0,'navigation',1,'right');
INSERT INTO box (`file`,position,`right`,name,id,dynamic) VALUES('verify.pl','disabled',0,'verify',3,'right');
INSERT INTO box (`file`,position,`right`,name,id,dynamic) VALUES('login.pl','disabled',0,'login',4,'0');
INSERT INTO box (`file`,position,`right`,name,id,dynamic) VALUES('tables.pl','disabled',5,'database',10,'right');
INSERT INTO box (`file`,position,`right`,name,dynamic,id) VALUES('news.pl','disabled',0,'blog','right',7);
CREATE TABLE cats (
  `name` varchar(100) NOT NULL default '',
  `right` int(11) NOT NULL default '0',
  `id` int(11) NOT NULL auto_increment,
  PRIMARY KEY  (id)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
INSERT INTO cats (name,`right`, id) VALUES('news',0, 1);
INSERT INTO cats (name,`right`, id) VALUES('member',1,2);
INSERT INTO cats (name,`right`, id) VALUES('draft',2,5);
CREATE TABLE navigation (
       title varchar(100) NOT NULL default '',
       `action` varchar(100) NOT NULL default '',
       src varchar(100) NOT NULL default '',
       `right` int(11) NOT NULL default '0',
       position varchar(5) NOT NULL default 'left',
       submenu varchar(100) default NULL,
       `id` int(11) NOT NULL auto_increment,
       target int(11) default NULL,
       PRIMARY KEY  (id)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
INSERT INTO navigation (title,action,src,`right`,position,submenu,id,target) VALUES('blog','news','news.png',0,'top','',1,0);
INSERT INTO navigation (title,action,src,`right`,position,submenu,id,target) VALUES('Admin','admin','admin.png',5,'5','submenuadmin',2,0);
INSERT INTO navigation (title,action,src,`right`,position,submenu,id,target) VALUES('properties','profile','profile.png',1,'6','',3,0);
INSERT INTO navigation (title,action,src,`right`,position,submenu,id,target) VALUES('links','links','link.png',0,'top','',5,0);
INSERT INTO navigation (title,`action`,src,`right`,position,submenu,id,target) VALUES('gbook','gbook','link.png',0,'8','',7,0);
CREATE TABLE news (
  title varchar(100) NOT NULL default '',
  body text NOT NULL,
  `date` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  `user` text NOT NULL,
  `right` int(11) NOT NULL default '0',
  attach varchar(100) NOT NULL default '0',
  cat varchar(25) NOT NULL default 'news',
  `action` varchar(50) NOT NULL default 'main',
  sticky int(1) NOT NULL default '0',
  `id` int(11) NOT NULL auto_increment,
  format varchar(10) NOT NULL default 'bbcode',
  PRIMARY KEY  (id),
  FULLTEXT KEY title (title,body)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
INSERT INTO news (title,body,date,`user`,`right`,attach,cat,action,sticky,id) VALUES('Login as','Name: admin\r\npassword: If you dont have set it during make it is testpass','2007-04-23 19:06:42','admin',0,'0','news','news',0,1);
CREATE TABLE querys (
  title varchar(100) NOT NULL default '',
  description text NOT NULL,
  `sql` text NOT NULL,
  `return` varchar(100) NOT NULL default 'fetch_array',
  `id` int(11) NOT NULL auto_increment,
  PRIMARY KEY  (id)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
CREATE TABLE replies (
  title varchar(100) NOT NULL default '',
  body text NOT NULL,
  `date` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  `user` text NOT NULL,
  `right` int(10) NOT NULL default '0',
  attach varchar(100) NOT NULL default '0',
  refererId varchar(50) NOT NULL default '',
  sticky int(1) NOT NULL default '0',
  `id` int(11) NOT NULL auto_increment,
  format varchar(10) NOT NULL default 'bbcode',
  cat varchar(25) NOT NULL default 'replies',
  PRIMARY KEY  (id),
  FULLTEXT KEY title (title,body)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
CREATE TABLE submenuadmin (
  title varchar(100) NOT NULL default '',
  `action` varchar(100) NOT NULL default '',
  src varchar(100) NOT NULL default 'link.gif',
  `right` int(11) NOT NULL default '0',
  submenu varchar(100) default NULL,
  `id` int(11) NOT NULL auto_increment,
  PRIMARY KEY  (id)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
INSERT INTO submenuadmin (title,action,src,`right`,submenu,id) VALUES('settings','settings','link.gif',5,NULL,1);
INSERT INTO submenuadmin (title,action,src,`right`,submenu,id) VALUES('database','showDatabases','link.gif',5,'',8);
INSERT INTO submenuadmin (title,action,src,`right`,submenu,id) VALUES('navigation','editTreeview','',5,'',9);
INSERT INTO submenuadmin (title,`action`,src,`right`,submenu,id) VALUES('env','env','link.gif',5,NULL,10);
INSERT INTO submenuadmin (title,action,src,`right`,submenu,id) VALUES('Edit links','linkseditTreeview','link.gif',5,'',12);
INSERT INTO submenuadmin (title,action,src,`right`,submenu,id) VALUES('Explorer','showDir','link.gif',5,'',15);
INSERT INTO submenuadmin (`title`,`action`,`src`,`right`,`submenu`,`id`) values('trash','trash','','5','','16');
INSERT INTO submenuadmin (`title`,`action`,`src`,`right`,`submenu`,`id`) values('translate','translate','link.png','5','','17');
CREATE TABLE `trash` (
  `table` varchar(50) NOT NULL default '',
  `oldId` bigint(50) NOT NULL default '0',
  `title` varchar(100) NOT NULL default '',
  `body` text NOT NULL,
  `date` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  `user` text NOT NULL,
  `right` int(11) NOT NULL default '0',
  `attach` varchar(100) NOT NULL default '0',
  `cat` varchar(25) NOT NULL default 'main',
  `action` varchar(50) NOT NULL default 'news',
  `sticky` int(1) NOT NULL default '0',
  `id` int(11) NOT NULL auto_increment,
  `format` varchar(10) NOT NULL default 'bbcode',
  `refererId` int(11) NOT NULL,
  PRIMARY KEY  (`id`),
  FULLTEXT KEY `title` (`title`,`body`)
) ENGINE=MyISAM AUTO_INCREMENT=10 DEFAULT CHARSET=utf8;
CREATE TABLE users (
  pass text NOT NULL,
  `user` varchar(25) NOT NULL default '',
  `date` date NOT NULL default '0000-00-00',
  email varchar(100) NOT NULL default '',
  `right` int(11) NOT NULL default '0',
  `name` varchar(100) NOT NULL default '',
  firstname varchar(100) NOT NULL default '',
  street varchar(100) default NULL,
  city varchar(100) default NULL,
  postcode varchar(20) default NULL,
  phone varchar(50) default NULL,
  sid varchar(200) default NULL,
  ip varchar(50) default NULL,
  cats text NULL,
  `id` int(11) NOT NULL auto_increment,
  PRIMARY KEY  (id)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
INSERT INTO users (pass,`user`,date,email,`right`,name,firstname,street,city,postcode,phone,sid,ip,cats,id) VALUES('guest','guest','0000-00-00','guest@guestde',0,'guest','guest','guest','guest','57072','445566','hghsdf7','dd','news',1);
CREATE TABLE exploit (
  `date` timestamp NOT NULL default CURRENT_TIMESTAMP,
  referer text NOT NULL,
  remote_addr text NOT NULL,
  query_string text NOT NULL,
  `id` int(11) NOT NULL auto_increment,
  PRIMARY KEY  (id)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
CREATE TABLE flood (
  remote_addr text NOT NULL,
  ti text NOT NULL,
  `id` int(11) NOT NULL auto_increment,
  PRIMARY KEY  (id)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
CREATE TABLE topnavigation (
  title varchar(100) NOT NULL default '',
  `action` varchar(100) NOT NULL default '',
  src varchar(100) NOT NULL default '',
  `right` int(11) NOT NULL default '0',
  `id` int(11) NOT NULL auto_increment,
  target int(11) default NULL,
  PRIMARY KEY  (id)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
INSERT INTO topnavigation (title,action,src,`right`,  id,target) VALUES('news','news','news.png',0, 1,0);
INSERT INTO topnavigation (title,action,src,`right`, id,target) VALUES('Bookmarks','links','link.png',0, 2,0);
CREATE TABLE gbook (
  title varchar(50) NOT NULL default '',
  `body` text NOT NULL,
  `date` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  `user` text NOT NULL,
  `id` int(11) NOT NULL auto_increment,
  PRIMARY KEY  (id),
  FULLTEXT KEY title (title,body)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
CREATE TABLE `reserved_words` (
  `reserved_word` varchar(50) default NULL,
  `id` int(11) NOT NULL auto_increment,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=224 DEFAULT CHARSET=latin1;
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('ACCESSIBLE','1');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('ALTER','2');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('AS','3');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('BEFORE','4');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('BINARY','5');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('BY','6');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('CASE','7');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('CHARACTER','8');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('COLUMN','9');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('CONTINUE','10');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('CROSS','11');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('CURRENT_TIMESTAMP','12');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('DATABASE','13');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('DAY_MICROSECOND','14');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('DEC','15');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('DEFAULT','16');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('DESC','17');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('DISTINCT','18');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('DOUBLE','19');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('EACH','20');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('ENCLOSED','21');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('EXIT','22');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('FETCH','23');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('FLOAT8','24');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('FOREIGN','25');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('GRANT','26');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('HIGH_PRIORITY','27');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('HOUR_SECOND','28');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('IN','29');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('INNER','30');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('INSERT','31');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('INT2','32');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('INT8','33');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('INTO','34');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('JOIN','35');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('KILL','36');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('LEFT','37');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('LINEAR','38');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('LOCALTIME','39');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('LONG','40');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('LOOP','41');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('MATCH','42');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('MEDIUMTEXT','43');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('MINUTE_SECOND','44');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('NATURAL','45');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('NULL','46');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('OPTIMIZE','47');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('OR','48');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('OUTER','49');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('PRIMARY','50');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('RANGE','51');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('READ_WRITE','52');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('REGEXP','53');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('REPEAT','54');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('RESTRICT','55');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('RIGHT','56');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('SCHEMAS','57');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('SENSITIVE','58');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('SHOW','59');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('SPECIFIC','60');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('SQLSTATE','61');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('SQL_CALC_FOUND_ROWS','62');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('STARTING','63');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('TERMINATED','64');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('TINYINT','65');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('TRAILING','66');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('UNDO','67');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('UNLOCK','68');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('USAGE','69');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('UTC_DATE','70');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('VALUES','71');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('VARCHARACTER','72');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('WHERE','73');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('WRITE','74');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('ZEROFILL','75');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('ALL','76');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('AND','77');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('ASENSITIVE','78');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('BIGINT','79');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('BOTH','80');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('CASCADE','81');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('CHAR','82');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('COLLATE','83');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('CONSTRAINT','84');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('CREATE','85');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('CURRENT_TIME','86');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('CURSOR','87');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('DAY_HOUR','88');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('DAY_SECOND','89');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('DECLARE','90');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('DELETE','91');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('DETERMINISTIC','92');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('DIV','93');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('DUAL','94');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('ELSEIF','95');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('EXISTS','96');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('FALSE','97');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('FLOAT4','98');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('FORCE','99');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('FULLTEXT','100');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('HAVING','101');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('HOUR_MINUTE','102');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('IGNORE','103');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('INFILE','104');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('INSENSITIVE','105');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('INT1','106');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('INT4','107');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('INTERVAL','108');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('ITERATE','109');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('KEYS','110');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('LEAVE','111');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('LIMIT','112');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('LOAD','113');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('LOCK','114');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('LONGTEXT','115');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('MASTER_SSL_VERIFY_SERVER_CERT','116');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('MEDIUMINT','117');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('MINUTE_MICROSECOND','118');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('MODIFIES','119');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('NO_WRITE_TO_BINLOG','120');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('ON','121');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('OPTIONALLY','122');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('OUT','123');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('PRECISION','124');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('PURGE','125');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('READS','126');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('REFERENCES','127');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('RENAME','128');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('REQUIRE','129');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('REVOKE','130');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('SCHEMA','131');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('SELECT','132');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('SET','133');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('SPATIAL','134');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('SQLEXCEPTION','135');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('SQL_BIG_RESULT','136');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('SSL','137');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('TABLE','138');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('TINYBLOB','139');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('TO','140');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('TRUE','141');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('UNIQUE','142');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('UPDATE','143');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('USING','144');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('UTC_TIMESTAMP','145');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('VARCHAR','146');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('WHEN','147');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('WITH','148');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('YEAR_MONTH','149');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('ADD','150');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('ANALYZE','151');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('ASC','152');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('BETWEEN','153');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('BLOB','154');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('CALL','155');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('CHANGE','156');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('CHECK','157');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('CONDITION','158');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('CONVERT','159');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('CURRENT_DATE','160');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('CURRENT_USER','161');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('DATABASES','162');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('DAY_MINUTE','163');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('DECIMAL','164');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('DELAYED','165');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('DESCRIBE','166');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('DISTINCTROW','167');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('DROP','168');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('ELSE','169');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('ESCAPED','170');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('EXPLAIN','171');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('FLOAT','172');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('FOR','173');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('FROM','174');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('GROUP','175');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('HOUR_MICROSECOND','176');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('IF','177');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('INDEX','178');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('INOUT','179');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('INT','180');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('INT3','181');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('INTEGER','182');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('IS','183');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('KEY','184');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('LEADING','185');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('LIKE','186');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('LINES','187');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('LOCALTIMESTAMP','188');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('LONGBLOB','189');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('LOW_PRIORITY','190');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('MEDIUMBLOB','191');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('MIDDLEINT','192');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('MOD','193');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('NOT','194');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('NUMERIC','195');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('OPTION','196');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('ORDER','197');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('OUTFILE','198');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('PROCEDURE','199');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('READ','200');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('REAL','201');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('RELEASE','202');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('REPLACE','203');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('RETURN','204');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('RLIKE','205');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('SECOND_MICROSECOND','206');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('SEPARATOR','207');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('SMALLINT','208');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('SQL','209');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('SQLWARNING','210');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('SQL_SMALL_RESULT','211');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('STRAIGHT_JOIN','212');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('THEN','213');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('TINYTEXT','214');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('TRIGGER','215');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('UNION','216');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('UNSIGNED','217');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('USE','218');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('UTC_TIME','219');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('VARBINARY','220');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('VARYING','221');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('WHILE','222');
INSERT INTO `reserved_words` (`reserved_word`,`id`) values('XOR','223');
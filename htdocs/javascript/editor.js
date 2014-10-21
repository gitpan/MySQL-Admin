//<<editor.pm
// var right = 0;
// var htmlright =2;
// var bbcode = true;
// var style ='lze';
JString.prototype = new Array();
JString.prototype.constructor = JString;
JString.superclass = Array.prototype;

function JString(string){
     for(i = 0; i < string.length;i++){
          JString.prototype[i] = string[i];
     }
}
JString.prototype.splice = function(i,n,array){
     JString.superclass.splice.call(this,i,n,array);
     return this.join("");
}
JString.prototype.toString = function(){
     return this.join("");
}

var html = false;

function enableHtml(){
     if(html ==  false){
          html = true;
          document.getElementById('htmlButton').checked = true;
          if(document.getElementById('enlarged')){
              document.getElementById('enlarged').style.display ='none';
          }
     }else{
          html = false;
          document.getElementById('htmlButton').checked = false;
          if(document.getElementById('enlarged')){
              document.getElementById('enlarged').style.display ='';
          }
     }
}

function put(t){
     addText(t);
}

function preview(){
     var titel = document.getElementById('title').value;
     var txt = document.getElementById('txt').value;
     if(!html){
//#txt = escape(txt);
          txt = bb2html(txt);
     }
     var maxWidth = 200;
     if( txt.length > maxWidth ){
          var maxLength = maxWidth;
          var i = 0;
          while(i < txt.length){
               if("<" ==  txt.substr(i,1)){
                    maxLength = maxWidth;
                    do{
                         if(txt.substr(i,1))ret += txt.substr(i,1);
                         i++;
                    }while(">" !=  txt.substr(i,1)&& i < txt.length);
               }
               maxLength = (txt.substr(i,1)!= " ") ? maxLength--: maxWidth;

               if(txt.substr(i,1))ret += txt.substr(i,1);
               if(maxLength == 0){
                    ret += " ";
                    maxLength = maxWidth;
               }
               i++;
          }
     }
     visible('windowpreviewBox');
     setText('ptitel',"<b>"+titel+"</b>");
     setText('pbody',txt);
}
//<< bbcode buttons
function addText(text){
     var element = document.getElementById("txt")
     element.value += text;
     element.focus();
}
function align(a){
     if(html){
          insertT("div align=\""+a+"\"","div");
     }else{
          insertT(a,a);
     }
}
function left(){
     align("left");
}
function center(){
     align("center");
}
function aright(){
     align("right");
}
function justify(){
     align("justify");
}
function strike(){
     insertT("s");
}
function underline(){
     insertT("u");
}
function bold(){
     insertT("b");
}
function italicize(){
     insertT("i");
}
function subb(){
     insertT("sub");
}
function sup(){
     insertT("sup");
}

function img(){
     var textarea  = document.getElementById('txt');
     if(typeof document.selection != 'undefined'){
          var range = document.selection.createRange();
          var txt = range.text;
          range = document.selection.createRange();
          if(txt.length == 0){
               txt = prompt("Insert Image location");
               var o ="";
               if(html){
                    o = "<img src='"+txt+"'/>";
               }else{
                    o = "[img]"+txt+"[/img]";
               }
               textarea.value += o;
          }else{
               if(html){
                    range.text = "<img src='"+txt+"'/>";
               }else{
                    range.text = "[img]"+txt+"[/img]";
               }
               range.moveStart('character', txt.length + 11);
          }
          range.select();
     }else if(textarea.selectionEnd > textarea.selectionStart){
          var i = textarea.selectionStart;
          var n = textarea.selectionEnd;
          var img = textarea.value.substring(i,n);
          o = new JString(textarea.value);
          if(html){
               textarea.value = o.splice(i,(n-i),"<img src='"+img+"'/>");
          }else{
               textarea.value = o.splice(i,(n-i),"[img]"+img+"[/img]");
          }
     }else if(textarea.selectionStart &&(textarea.selectionEnd == textarea.selectionStart)){//insert at gecko
          var ia = textarea.selectionStart;
          var txta = prompt("Insert Image location:");
          var a = textarea.value.substring(0,ia);
          var b = textarea.value.substring(ia,textarea.value.length);
          if(html){
               textarea.value = a +"<img src='"+txta+"'/>"+b;
          }else{
               textarea.value = a +"[img]"+txta+"[/img]"+b;
          }
     }else{
         var imga = prompt("Insert Image location:");
          if(html){
               if(img){textarea.value += "<img src='"+imga+"'/>";}
          }else{
               if(img){textarea.value += "[img]"+imga+"[/img]";}
          }
     }
}
var color = "red";

function setCColor(c){
     color = c;
     document.getElementById("showColor").style.backgroundColor = color;
}
function showColor(){
     var e = document.getElementById("coloor");
     e.style.color = color;
     if(html){
          insertT("span style=\"color:"+color+"\"","span");
     }else{
          insertT("color="+color+"","color");
     }
}
function email(){
     var link = prompt("Insert a Email Address:");
     if(html){
          insertT("a href='mailto:"+link+"'","a");
     }else{
          insertT("email="+link,"email");
     }
}
function link(){
     var link = prompt("Insert a url:");
     if(html){
          insertT("a href=\""+link+"\"","a");
     }else{
          insertT("url="+link+"","url");
     }
}
function insertT(tag,tag2){
     if(!tag2)tag2 = tag;
     var textarea  = document.getElementById('txt');
     if(typeof document.selection != 'undefined'){ //IE6
          range = document.selection.createRange();
          var txt = range.text;
          if(txt.length == 0){
               txt = prompt("Insert text");
               if(txt.length > 0){
               var o ="";
               if(html){
                    o = "<"+tag+">"+txt+"</"+tag2+">";
               }else{
                    o = "["+tag+"]"+txt+"[/"+tag2+"]";
               }
               textarea.value += o;
               }
          }else{
               if(html){
                    range.text = "<"+tag+">"+txt+"</"+tag2+">";
               }else{
                    range.text = "["+tag+"]"+txt+"[/"+tag2+"]";
               }
               range.moveStart('character', tag.length + txt.length + tag2.length);
          }
          range.select();
     }else if(textarea.selectionEnd > textarea.selectionStart){//selektieren gecko
          var i = textarea.selectionStart;
          var n = textarea.selectionEnd;
          var txtb = textarea.value.substring(i,n);
          o = new JString(textarea.value);
          if(html){
               textarea.value = o.splice(i,(n-i),"<"+tag+">"+txtb+"</"+tag2+">");
          }else{
               textarea.value = o.splice(i,(n-i),"["+tag+"]"+txtb+"[/"+tag2+"]");
          }
     }else if(textarea.selectionStart &&(textarea.selectionEnd == textarea.selectionStart)){//insert at gecko
          var ia = textarea.selectionStart;
          var txta = prompt("Insert text");
          var a = textarea.value.substring(0,ia);
          var b = textarea.value.substring(ia,textarea.value.length);
          if(html){
               textarea.value = a +"<"+tag+">"+txta+"</"+tag+">"+b;
          }else{
               textarea.value =   a +"["+tag+"]"+txta+"[/"+tag2+"]"+b;
          }
     }else{//others
          var bol = prompt("insert text");
          if(html){
                    textarea.value += "<"+tag+">"+bol+"</"+tag2+">";
          }else{
                    textarea.value += "["+tag+"]"+bol+"[/"+tag2+"]";
          }
     }
}
function clearIt(){
     var element = document.getElementById("txt")
     element.value = "";
     element.focus();
}

function printButtons(){
       var txf ="<table border=\"0\" cellpadding=\"0\" cellspacing=\"0\"  ><tr><td><img src=\"/style/"+style+"/buttons/left.png\" alt=\"left\" style =\"cursor:pointer;\" onclick=\"left();\" class=\"editorButtons\" title=\"left\"  border=\"0\"/></td><td><img src=\"/style/"+style+"/buttons/center.png\" alt=\"center\" style =\"cursor:pointer;\" onclick=\"center();\" class=\"editorButtons\" title=\"center\"  border=\"0\"/></td><td><img src=\"/style/"+style+"/buttons/right.png\" alt=\"right\" style =\"cursor:pointer;\" onclick=\"aright()\" class=\"editorButtons\" title=\"right\"  border=\"0\"/></td><td><img src=\"/style/"+style+"/buttons/bold.png\" alt=\"bold\" style =\"cursor:pointer;\" onclick=\"bold();\" class=\"editorButtons\" title=\"bold\"  border=\"0\"/></td><td><img src=\"/style/"+style+"/buttons/italic.png\" alt=\"italic\" style =\"cursor:pointer;\" onclick=\"italicize();\" class=\"editorButtons\" title=\"italic\"  border=\"0\"/></td><td><img src=\"/style/"+style+"/buttons/strike.png\" alt=\"strike\" style =\"cursor:pointer;\" onclick=\"strike();\" class=\"editorButtons\" title=\"strike\"  border=\"0\"/></td><td><img src=\"/style/"+style+"/buttons/under.png\" style =\"cursor:pointer;\" onclick=\"underline();\" class=\"editorButtons\" title=\"underline\"  border=\"0\"/></td><td><img src=\"/style/"+style+"/buttons/sub.png\" style =\"cursor:pointer;\" onclick=\"subb();\" class=\"editorButtons\" title=\"sub\"  border=\"0\"/></td><td><img src=\"/style/"+style+"/buttons/sup.png\" alt=\"sup\" style =\"cursor:pointer;\" onclick=\"sup();\" class=\"editorButtons\" title=\"sup\"  border=\"0\"/></td><td><img src=\"/style/"+style+"/buttons/img.png\" alt=\"insert image\" style =\"cursor:pointer;\" onclick=\"img();\" class=\"editorButtons\" title=\"image \"  border=\"0\"/></td><td><img src=\"/style/"+style+"/buttons/link.png\" alt=\"link\" style =\"cursor:pointer;\" onclick=\"link();\" class=\"editorButtons\" title=\"link\"  border=\"0\"/></td><td><img src=\"/style/"+style+"/buttons/email.png\" alt=\"email\" style =\"cursor:pointer;\" onclick=\"email();\" class=\"editorButtons\" title=\"email\"  border=\"0\"/></td><td><img src=\"/style/"+style+"/buttons/clear.png\" style =\"cursor:pointer;\" onclick=\"clearIt();\" class=\"editorButtons\" title=\"clear\"  border=\"0\"/></td></td><td><select align=\"right\" id=\"coloor\" style=\"height:16px;font-size:12px;\"name=\"color\" onChange=\"setCColor(this.options[this.selectedIndex].value)\"><option value=\"black\">Black</option><option value=\"red\" style=\"background-color:Red;\" selected=\"selected\">Red</option><option value=\"Yellow\" style=\"background-color:Yellow;\">Yellow</option><option value=\"pink\" style=\"background-color:Pink;\">Pink</option><option value=\"Green\" style=\"background-color:Green;\">Green</option><option value=\"orange\" style=\"background-color:orange;\">Orange</option><option value=\"purple\" style=\"background-color:Purple;\">Purple</option><option value=\"Blue\" style=\"background-color:Blue;\">Blue</option><option value=\"brown\" style=\"background-color:Brown;\">Brown</option><option value=\"Teal\" style=\"background-color:Teal;\">Teal</option><option value=\"navy\" style=\"background-color:Navy;\">Navy</option><option value=\"Maroon\" style=\"background-color:Maroon;\">Maroon</option><option value=\"LimeGreen\" style=\"background-color:LimeGreen;\">Lime Green</option></select></td><td style=\"padding-left:2px;\"><img style=\"background-color:red;\" id =\"showColor\" src=\"/style/"+style+"/buttons/button.gif\" alt=\"\" border=\"1\" style =\"cursor:pointer;\" onclick=\"ShowColor();\" class=\"editorButtons\" border=\"0\"/></td>";
     document.write(txf);
     if(right >= htmlright && bbcode == true){
            document.write('<td>HTML:<input type="checkbox" onclick="enableHtml()" id="htmlButton" class="markBoxEditor" name="format"/></td>');
     }
     document.write("</tr></table>");
}

function printenlarged(){
       if(bbcode == true){
              document.write("<input type=\"button\" name=\"en\" value=\"En\" onclick=\"insertT('en')\"/><input type=\"button\" name=\"de\" value=\"De\" onclick=\"insertT('de')\"/><input type=\"button\" name=\"google\" value=\"google\" onclick=\"insertT('google')\"/><input type=\"button\" name=\"perl\" value=\"Perl\" onclick=\"insertT('code')\"/><input type=\"button\" name=\"Cpp\" value=\"C++\" onclick=\"insertT('coden=Cpp','code')\"/><input type=\"button\" name=\"Bash\" value=\"Bash\" onclick=\"insertT('coden=Bash','code')\"/><input type=\"button\" name=\"HTML\" value=\"HTML\" onclick=\"insertT('coden=HTML','code')\"/><input type=\"button\" name=\"Java\" value=\"Java\" onclick=\"insertT('coden=Java','code')\"/><input type=\"button\" name=\"Java\" value=\"Python\" onclick=\"insertT('coden=Python','code')\"/><input type=\"button\" name=\"CSS\" value=\"CSS\" onclick=\"insertT('coden=CSS','code')\"/><input type=\"button\" name=\"JavaScript\" value=\"JS\" onclick=\"insertT('coden=JavaScript','code')\"/><input type=\"button\" name=\"PHP\" value=\"PHP\" onclick=\"insertT('coden=PHP','code')\"/><input type=\"button\" name=\"Ruby\" value=\"Ruby\" onclick=\"insertT('coden=Ruby','code')\"/><input type=\"button\" name=\"XML\" value=\"XML\" onclick=\"insertT('coden=XML','code')\"/><input type=\"button\" type=\"h1\" name=\"h1\" value=\"h1\" onclick=\"insertT('h1')\"/><input type=\"button\" type=\"h2\" name=\"h2\" value=\"h2\" onclick=\"insertT('h2')\"/><input type=\"button\" type=\"h3\" name=\"h3\" value=\"h3\" onclick=\"insertT('h3')\"/><input type=\"button\" type=\"h4\" name=\"h4\" value=\"h4\" onclick=\"insertT('h4')\"/><input type=\"button\" type=\"ol\" name=\"ol\" value=\"ol\" onclick=\"insertT('ol')\"/><input type=\"button\" type=\"ul\" name=\"ul\" value=\"ul\" onclick=\"insertT('ul')\"/><input type=\"button\" type=\"li\" name=\"li\" value=\"li\" onclick=\"insertT('li')\"/>");
       }
}
function getValue(id){
     return document.getElementById(id).value;
}
function setValue(id,txt){
     document.getElementById(id).value = txt;
}

blogThis();
function blogThis(){
    var referer = param("referer");
    var headline = param("headline");
    var q = param("quote");
    if(referer && headline && q){
        var t = "[blog="+unescape(referer)+"]\n"+unescape(q)+"\n[/blog]";
        document.getElementById('title').value = unescape(headline);
        document.getElementById('txt').value = t;
    }
}
function param(name){
    var lo = location.href;
    var i = 0;
    var suche = name+"="
            while (i< lo.length){
        if (lo.substring(i, i+suche.length)==suche){
            var ende = lo.indexOf(";", i+suche.length);
            ende = (ende>-1) ? ende : lo.length;
            var cook = lo.substring(i+suche.length, ende);
            return unescape(cook);
        }
        i++;
            }
            return 0;
}
//editor.pm
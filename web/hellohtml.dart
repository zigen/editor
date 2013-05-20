import 'dart:html';
import 'dart:svg' as svg;

var modeList = ["Normal Mode","Insert Mode","CommandLine Mode","Visual Mode","Search Mode"];
int mode = 0;
var cmdWindow = query("#input");
var textInput;
var out;
var mainInput = query("#mainInput");
void main() {

  document.onKeyPress.listen(pressedKey);
  document.onClick.listen(clicked);
  out = query("#output");
  var textF = new svgText("svTs");


    out.children.add(textF.textArea);

   out.children.add(textF.cursor.rec);
    textInput = textF;
    print(cmdWindow.$dom_className);
 
     
    query("#display").text = modeList[0];
    query("#mainInput").focus();
    mainInput.text ="hello world";
    document.onKeyPress.listen(mainKeydown);

    document.onKeyDown.listen(keychk);
    textInput.updateCursor();
}
void clicked(MouseEvent event){
  print(event.pageX);
}


class textCursor{
  int x,y,dx,dy=0;
  svg.RectElement rec;
  textCursor(){
    rec= new svg.RectElement();
    rec.$dom_setAttribute("fill","black");
    rec.$dom_setAttribute("fill-opacity","0.1");
    rec.$dom_setAttribute("stroke","black");
    rec.$dom_setAttribute("x","${4}px");
    rec.$dom_setAttribute("y","${4}px");
    rec.$dom_setAttribute("width","${20}px");
    rec.$dom_setAttribute("height","${20}px");
  }
 void setCursor(int _x,int _y,int _dx,int _dy){
   x = _x;
   y = _y;
   dx = _dx;
   dy = _dy;
   update();
 }
 
 void update(){
   rec.$dom_setAttribute("x","${x}px");
   rec.$dom_setAttribute("y","${y}px");
   rec.$dom_setAttribute("width","${dx}px");
   rec.$dom_setAttribute("height","${dy}px");
 }

}

class svgText{
  textCursor cursor;
  int fontSize,x,y,lines,currentLine,currentChar;
  String fontFamily,id;
  svg.TextElement textArea; 
  
  svgText(String _id,[int _fontSize=25,int _x=30,int _y=10,String _fontFamily="Verdana"]){
    lines = 0;
    currentLine = 0;
    currentChar = 0;
    x = _x;
    y = _y;
    id = _id;
    fontSize = _fontSize;
    fontFamily = _fontFamily;
    textArea = new svg.TextElement();
    textArea.$dom_setAttribute("x","${x}px");
    textArea.$dom_setAttribute("y","${y}px");
    textArea.$dom_setAttribute("id",id); 
    textArea.$dom_setAttribute("font-family",fontFamily);
    textArea.$dom_setAttribute("font-size","${fontSize}");
    cursor = new textCursor();
    addNewLine(" ");
  }
  void updateCursor(){
    if(textArea.children[currentLine].text.length-1<=currentChar){
      changeCurrentChar(currentChar-1);
    }
    int a,b,c;

    if(textArea.children[currentLine].text.substring(currentChar,currentChar+1)!=" "){
      var tp = textArea.children[currentLine].getStartPositionOfChar(currentChar);
      var ep = textArea.children[currentLine].getEndPositionOfChar(currentChar);
      a = tp.x.round();
      b = tp.y.round()-fontSize;
      c = ep.x.round()-a;
    }else { 
      if(currentChar == 0){
        a = x;
      }else{
        var tp = textArea.children[currentLine].getEndPositionOfChar(currentChar-1);
        a = tp.x.round();
        //changeCurrentChar(currentChar-1);
      }
      b = (currentLine)*fontSize;
      c = 10;
    }

    print('${a} ${b} ${c}');


   textInput.cursor.setCursor(a,b,c,fontSize);
   
  }
  void deleteLine(int dline){
    textArea.children[currentLine].remove();
    --lines;
    changeCurrentLine(currentLine-1);
    updateLines();
  }
  void insertChars(String _text){
    String st = textArea.children[currentLine].text;
    if(st.length>=1&&currentChar>0){
      String bt = st.substring(currentChar,st.length);
       st = st.substring(0, currentChar);
       print('${st} + ${bt}');
       st+=_text;
       st+=bt;
    }else st=_text+st;
    textArea.children[currentLine].text = st;
    changeCurrentChar(currentChar+1);
    updateCursor();
  }
  void deleteChars(int dchars){
    if(currentChar-dchars >= 0){
      String t = textArea.children[currentLine].text;
      t = t.substring(0,currentChar)+t.substring(currentChar+dchars);
      textArea.children[currentLine].text = t;
      changeCurrentChar(currentChar);
    }else if(textArea.children[currentLine].text.length>1&&currentLine!=0){
      changeCurrentChar(textArea.children[currentLine-1].text.length-1);
      textArea.children[currentLine-1].text+= textArea.children[currentLine].text;
      deleteLine(1);
      changeCurrentChar(currentChar+1);
    }else if(textArea.children[currentLine].text.length==1)deleteLine(0);
    updateCursor();
  }
  void bsChars(int dchars){
    if(currentChar-dchars >= 0){
    String t = textArea.children[currentLine].text;
    t = t.substring(0,currentChar-1)+t.substring(currentChar+dchars-1);
    textArea.children[currentLine].text = t;
    changeCurrentChar(currentChar-1);
    }else if(textArea.children[currentLine].text.length>1&&currentLine!=0){
      changeCurrentChar(textArea.children[currentLine-1].text.length-1);
      textArea.children[currentLine-1].text+= textArea.children[currentLine].text;
      deleteLine(1);
      changeCurrentChar(currentChar+1);
    }else if(textArea.children[currentLine].text.length==1)deleteLine(0);
    updateCursor();
  }
  
  void changeCurrentLine(int _cline){
    if(lines >  _cline && 
        _cline > -1){
      if(textArea.children[_cline].text.length-1<currentChar)currentChar = textArea.children[_cline].text.length-1;
      currentLine = _cline;
      
    }
    updateCursor();
  }
  
  void changeCurrentChar(int _cChar){
    if(textArea.children[currentLine].text.length-1 <= _cChar){
      if(currentLine == lines-1)currentChar = textArea.children[currentLine].text.length-1;
      else currentChar = 0;      
      changeCurrentLine(currentLine+1);
    }else if( _cChar == -1){
      if(currentLine != 0){
      changeCurrentLine(currentLine-1);
      currentChar = textArea.children[currentLine].text.length-1;
      }
    }else currentChar = _cChar;
    updateCursor();
  print(textArea.children[currentLine].text.length);
  }
  void addNewLine(String _text){
    svg.TSpanElement s = new svg.TSpanElement();
    s.$dom_setAttribute("x","${x}px");
    s.$dom_setAttribute("y","${(lines+1)*fontSize}px");
    s.$dom_setAttribute("id",'${id}_line${lines}');
    s.text = _text+"_";
    textArea.children.add(s);
    ++lines;
  }
  void insertNewLine([String _text = " "]){
    svg.TSpanElement s = new svg.TSpanElement();
    s.$dom_setAttribute("x","${x}px");
    s.$dom_setAttribute("y","${(lines+1)*fontSize}px");
    s.$dom_setAttribute("id",'${id}_line${lines}');
    s.text = _text+"_";
    textArea.children.insert(currentLine+1,s);
    ++lines;
    changeCurrentLine(currentLine+1);
    changeCurrentChar(0);
    updateLines();
    updateCursor();
  }
  
  void updateLines(){
    for(int i=0;i<textArea.children.length;++i){
      textArea.children[i].$dom_setAttribute("x","${x}px");
      textArea.children[i].$dom_setAttribute("y","${(i+1)*fontSize}px");
      textArea.children[i].$dom_setAttribute("id",'${id}_line${i}');
    }
  }
  
}
void changeMode(int _mode){
  mode = _mode;
  query("#display").text = modeList[mode];
  switch(_mode){
    case 0:
      print("called");
      cmdWindow.value ="";
      cmdWindow.classes.remove('show');
      cmdWindow.classes.add('hide');
      break;
  case 2:
    cmdWindow.value ="";
    cmdWindow.focus();
    cmdWindow.classes.remove('hide');
    cmdWindow.classes.add('show');
    break;
  case 1://Insert Mode
    

  default:
    break;
  }
}

void repl(String s){ // here is CommandLine REPL
  //COMMING SOOOOOOOOOOOOOON!!!!!!!
}
void pressedKey(KeyboardEvent event){
  print(' ${event.$dom_charCode},${event.$dom_keyCode}');

  if(event.$dom_keyCode == 27){
    changeMode(0);
    mainInput.value="";
  }
}
void keychk(KeyboardEvent event){
  switch(event.$dom_keyCode){
    case 8:
     if(mode==1)textInput.bsChars(1);
      break;
    default:
      break;
  }
  if(mode!=0)query("#mainInput").focus();

}

 void mainKeydown(KeyboardEvent event){
   String t = new String.fromCharCode(event.$dom_keyCode);
   print('${t}, ${event.$dom_charCode},${event.$dom_keyCode}');
  
   switch(mode){
      case 0://normal mode
        if(event.$dom_keyCode==13)textInput.changeCurrentLine(textInput.currentLine+1);
        if(normalEval(t))mainInput.value="";
        
        
        break;
        
      case 1://Insert Mode
        print("enter");

        if(event.$dom_keyCode==13){
          String _t = textInput.textArea.children[textInput.currentLine].text;
          textInput.textArea.children[textInput.currentLine].text = _t.substring(0,textInput.currentChar)+"_";
          print(_t);
          textInput.insertNewLine(_t.substring(textInput.currentChar,_t.length-1));
     
        }else{
          textInput.insertChars(t);
          mainInput.value="";
        }
        break;
      case 2://commandLine mode
        break;
      case 3://Visual Mode
        break;
      default:
        break;
    }
  textInput.updateCursor();
  if(mode!=0)query("#mainInput").focus();

  
}

bool normalEval(String exp){
  bool breaked = true;
  switch(exp){
    case 'i':
      changeMode(1);
      break;
    case 'x':
      textInput.deleteChars(1);
      break;
    case 'l':
      textInput.changeCurrentChar(textInput.currentChar+1);
      break;
    case 'h':
      textInput.changeCurrentChar(textInput.currentChar-1);
      break;
    case 'j':
      textInput.changeCurrentLine(textInput.currentLine+1);
      break;
    case 'k':
      textInput.changeCurrentLine(textInput.currentLine-1);
      break;
    case 'o':
      textInput.insertNewLine();
      changeMode(1);
      break;
    case 'd':
      textInput.deleteLine(1);
      break;
    default:
      breaked=false;
      break;
  }
  if(mode!=0)query("#mainInput").focus();

  return breaked;
}
void insertEval(String exp){
  
}
void cmdEval(String exp){
  
}
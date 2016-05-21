import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1
import MuseScore 1.0

MuseScore {
    menuPath: "Plugins.BrassFingeringExc"
    pluginType: "dialog"

    id: window
    width:285  // menu window size
    height:180
    property var itemX1 : 10;
    property var itemX2 : 150;
    property var itemY1 : 10;
    
    RowLayout {
        id: row0
        x:itemX1
        y:itemY1
        Label {
          font.pointSize: 14
          text: "Select Fingering Type" 
        }
    }
    RowLayout {
        id: row1
        x: itemX1
        y: itemY1 + 30
        ComboBox {
            model: ListModel {
                id: startPitchSelect
                property var key
                ListElement { text: "Tp B"; pitchStart: 45 }
                ListElement { text: "Tp C"; pitchStart: 43 }
                ListElement { text: "Tp Es"; pitchStart: 50 }
                ListElement { text: "PTp B"; pitchStart: 57 }
                ListElement { text: "Hr F"; pitchStart: 28 }
                ListElement { text: "Euph"; pitchStart: 33 }
                ListElement { text: "Tb"; pitchStart: 33 }
                ListElement { text: "Tuba B"; pitchStart: 21 }
            }
            width: 120
            onCurrentIndexChanged: {
                startPitchSelect.key = startPitchSelect.get(currentIndex).pitchStart
            }
        } // end ComboBox
    }
    RowLayout {
        id: row2
        x: itemX1 + 140
        y: itemY1 + 30
        ComboBox {
            model: ListModel {
                id: textPattern
                property var key
                ListElement { text: "... !.! !!."; cName: 'Exc' }
                ListElement { text: "0,13,12"; cName: 'Num1' }
                ListElement { text: "000,103,120"; cName: 'Num2' }
                ListElement { text: "○○○ ●○● ●●○"; cName: 'Rep1' }
                ListElement { text: "□□□ ■□■ ■■□"; cName: 'Rep2' }
                ListElement { text: "Pos (for Tb)"; cName: 'Pos' }
            }
            width: 140
            onCurrentIndexChanged: {
                textPattern.key = textPattern.get(currentIndex).cName
            }
        } // end ComboBox
    }
    RowLayout {
        id: row3
        x: itemX1
        y: itemY1 + 60
        ComboBox {
            model: ListModel {
                id: isVertical
                property var key
                ListElement { text: "holizontal"; value: 0 }
                ListElement { text: "vertical"; value: 1 }
            }
            width: 120
            onCurrentIndexChanged: {
                isVertical.key = isVertical.get(currentIndex).value
            }
        } // end ComboBox
    }
    RowLayout {
        id: row4
        x: itemX1 +140
        y: itemY1 + 60
        ComboBox {
            model: ListModel {
                id: isReverse
                property var key
                ListElement { text: "normal"; value: 0 }
                ListElement { text: "reverse"; value: 1 }
            }
            width: 120
            onCurrentIndexChanged: {
                isReverse.key = isReverse.get(currentIndex).value
            }
        } // end ComboBox
    }
    RowLayout {
        id: row5
        x: itemX1
        y: itemY1 + 90
        ComboBox {
            model: ListModel {
                id: atPitchChanged
                property var key
                ListElement { text: "pitch changed"; value: 1 }
                ListElement { text: "all"; value: 0 }
            }
            width: 120
            onCurrentIndexChanged: {
                atPitchChanged.key = atPitchChanged.get(currentIndex).value
            }
        } // end ComboBox
    }

    RowLayout {  //======================  CANCEL  /  OK
        id: row9
        x: itemX1
        y: itemY1 + 130
        Button {
            id: closeButton
            text: "Cancel"
            onClicked: { Qt.quit() }
        }
        Button {
            id: okButton
            text: "Ok"
            onClicked: {
                apply(0)
                Qt.quit()
            }
        }
    }
    RowLayout {  //======================  CANCEL  /  OK
        id: row10
        x: itemX1
        y: itemY1 + 200
        Button {
            id: pitchButton
            text: "output pitch number (for debug)"
            onClicked: {
                apply(1)
                Qt.quit()
            }
        }
    }

    function changeToNum(txt, ptn) {
        var rtn = '';
        for (var i = 0; i <= 3; i ++) {
            var s = txt.substr(i, 1);
            if (s == '.') {
                if (ptn != 1) {
                    rtn = rtn + '0';
                }
            } else if (s == '!') {
                rtn = rtn + String(i + 1);
            }
        }
        if (rtn == '') {
            rtn = '0';
        }
        return rtn;
    }
    function replaceText(txt, f0, f1) {
        var rtn = txt.replace(/\./g, f0);
        rtn = rtn.replace(/!/g, f1);
        return rtn;
    }
    function formatReverce(txt) {
        return txt.split("").reverse().join("");
    }
    function formatVertical(txt) {
        var len = txt.length;
        var rtn = ''; 
        for (var i = 0; i < len ; i++) {
            if (i != 0) {
                rtn = rtn + '\n';
            }
            rtn = rtn + txt.substr(i, 1);
        }
        return rtn;
    }
    function changeToPos(txt) {
        var rtn = '';
        var pos = 1;
        var l = '';
        for (var i = 0; i <= 3; i ++) {
            var s = txt.substr(i, 1);

            if (s == '!') {
                switch(i) {
                    case 0:
                        pos = pos + 2;
                        break;
                    case 1:
                        pos = pos + 1;
                        break;
                    case 2:
                        pos = pos + 3;
                        break;
                    case 3:
                        pos = pos + 2;
                        l = 'L';
                        break;
                }
            }
        }
        if (pos > 7) {
            rtn = '';
        } else {
            rtn = l + String(pos);
        }
        return rtn;
    }

    function apply(mode) {
        curScore.startCmd()
        if (typeof curScore === 'undefined') {
            Qt.quit();
        }

        const patternExc = new Array();
        patternExc = {
             0:'!!!!', 1:'!.!!',  2:'.!!!',  3:'!!.!',  4:'!..!',  5:'!!.!',  6:'...!',
             7:'!!!',  8:'!.!',   9:'.!!',  10:'!!.',  11:'!..',  12:'.!.',
            13:'...', 14:'!!!',  15:'!.!',  16:'.!!',  17:'!!.',  18:'!..',  19:'.!.',  20:'...',  21:'.!!',  22:'!!.', 23:'!..', 24:'.!.',
            25:'...', 26:'!!.',  27:'!..',  28:'.!.',  29:'...',  30:'!..',  31:'.!.',  32:'...',  33:'.!!',  34:'!!.', 35:'!..', 36:'.!.',
            37:'...', 38:'!!.',  39:'!..',  40:'.!.',  41:'...',  42:'!..',  43:'.!.',  44:'...',  45:'.!!',  46:'!!.', 47:'!..', 48:'.!.',
            49:'...'
        };
//        const patternPos = new Array();
//        patternPos = {
//             0: '',   1:'',    2:'L7',  3:'L6',  4:'L5',  5:'L4',  6:'L3',
//             7:'7',   8:'6',   9:'5',  10:'4',  11:'3',  12:'2',
//            13:'1',  14:'7',  15:'6',  16:'5',  17:'4',  18:'3',  19:'2',  20:'1',  21:'5',  22:'4', 23:'3', 24:'2',
//            25:'1',  26:'4',  27:'3',  28:'2',  29:'1',  30:'3',  31:'2',  32:'1',  33:'5',  34:'4', 35:'3', 36:'2',
//            37:'1',  38:'4',  39:'3',  40:'2',  41:'1',  42:'3',  43:'2',  44:'1',  45:'5',  46:'4', 47:'3', 48:'2',
//            49:'1'
//        };

        var startPitch = startPitchSelect.key;

        var cursor = curScore.newCursor();
        var startStaff;
        var endStaff;
        var endTick;
        var fullScore = false;
        cursor.rewind(1);
        if (!cursor.segment) {
              fullScore = true;
              startStaff = 0;
              endStaff = curScore.nstaves -1;
        } else {
              startStaff = cursor.staffIdx;
              cursor.rewind(2);
              if (cursor.tick == 0) {
                    endTick = curScore.lastSegment.tick + 1;
              } else {
                    endTick = cursor.tick;
              }
              endStaff = cursor.staffIdx;
        }
        //console.log(startStaff + " - " + endStaff + " - " + cursor.tick + ' - ' + endTick);


        for (var staff = startStaff; staff <= endStaff; staff++) {
            //staff.keySig.showCourtesy = 1;
            //console.log(staff.keySig.key());
            var voice = 0;
            cursor.rewind(1);
            cursor.voice = voice;
            cursor.staffIdx = staff;

            if (fullScore) cursor.rewind(0);
            var prePitch = -1;
            while (cursor.segment && (fullScore || cursor.tick < endTick)) {
                if (cursor.element && cursor.element.type == Element.CHORD) {
                    var text = newElement(Element.STAFF_TEXT);
                    text.userOff.y = 11;
                    var notes = cursor.element.notes;
                    var pitch = notes[0].pitch;
                    //console.log(pitch);
                    if (atPitchChanged.key == 1 && pitch == prePitch) {
                        cursor.next();
                        continue;
                    }
                    prePitch = pitch;
                    
                    var fingNum = pitch - startPitch;

                    if (mode == 1) {
                        text.text = pitch;
                    } else if (textPattern.key == 'Pos') {
                        if (fingNum in patternExc) {
                            //text.text = patternPos[fingNum];
                            text.text = changeToPos(patternExc[fingNum]);
                        }
                    } else {
                        if (fingNum in patternExc) {
                            var fing = patternExc[fingNum];
                            if (textPattern.key == 'Num1') {
                                fing = changeToNum(fing, 1);
                            } else if (textPattern.key == 'Num2') {
                                fing = changeToNum(fing, 2);
                            } else if (textPattern.key == 'Rep1') {
                                fing = replaceText(fing, '○', '●');
                            } else if (textPattern.key == 'Rep2') {
                                fing = replaceText(fing, '□', '■');
                            }

                            if (isReverse.key == 1) {
                                fing = formatReverce(fing);
                            }
                            if (isVertical.key == 1 && textPattern.key != 'Exc') {
                                fing = formatVertical(fing);
                            }

                            text.text = fing;
                        }
                    }
                    if (text.text != '') {
                        cursor.add(text);
                    }
                } else {
                    prePitch = -1;
                }
            cursor.next();
            } // end while
        } // end for
            curScore.endCmd()
            Qt.quit();
    }
}

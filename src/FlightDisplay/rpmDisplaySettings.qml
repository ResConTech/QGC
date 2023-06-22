
import QtQuick          2.3
import QtQuick.Controls 1.2
import QtQuick.Dialogs  1.2
import QtQuick.Layouts  1.2
import QtQuick.Controls.Material 2.0

import QGroundControl               1.0
import QGroundControl.FactSystem    1.0
import QGroundControl.FactControls  1.0
import QGroundControl.Controls      1.0
import QGroundControl.ScreenTools   1.0
import QGroundControl.Controllers   1.0
import QGroundControl.PX4           1.0
import Qt.labs.qmlmodels 1.0
import QGroundControl.Palette       1.0
import QtQuick.Window 2.0

import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1


Rectangle {
    id: tableView
    property int    _textEditWidth:                 ScreenTools.defaultFontPixelWidth * 30
    z:      QGroundControl.zOrderTopMost
    readonly property real _defaultTextHeight:  ScreenTools.defaultFontPixelHeight
    readonly property real _defaultTextWidth:   ScreenTools.defaultFontPixelWidth
    readonly property real _horizontalMargin:   _defaultTextWidth / 2
    readonly property real _verticalMargin:     _defaultTextHeight / 2
    readonly property real _buttonHeight:       ScreenTools.isTinyScreen ? ScreenTools.defaultFontPixelHeight * 3 : ScreenTools.defaultFontPixelHeight * 2
    width:   Math.min(ScreenTools.defaultFontPixelWidth * 200)
    height:  Math.min(ScreenTools.defaultFontPixelWidth * 100)
    color:  qgcPal.window
    property color maxColor: paramController.getColor('color_rpm_max')
    property color midColor: paramController.getColor('color_rpm_med')
    property color minColor: paramController.getColor('color_rpm_min')


    property color maxColorChecked: paramController.getColor('color_rpm_max')
    property color midColorChecked: paramController.getColor('color_rpm_med')
    property color minColorChecked: paramController.getColor('color_rpm_min')

    property double mid: paramController.getValue('RPM_color_mid')
    property double high: paramController.getValue('RPM_color_high')

    property double midChecked: paramController.getValue('RPM_color_mid')
    property double highChecked: paramController.getValue('RPM_color_high')


    property bool updated: false
    property double diameter: rpm_circle_red.width

    property bool _minmax: getTruth(paramController.getValue('minmax'))
    Text {
        id: _title
        x: Screen.width * .025 //2.75
        text: "RPM Display Settings"
        color: 'white'
        font.pixelSize: 50
        font.bold: true
        verticalAlignment: Text.AlignVCenter
    }

    Timer {
        interval:   10
        running:    true
        repeat: true
        onTriggered: {
            _minmax                  =        getTruth(paramController.getValue('minmax'))
            if(updated){
                midChecked          =        paramController.getValue('RPM_color_mid')
                highChecked         =        paramController.getValue('RPM_color_high')
                maxColorChecked     =        paramController.getColor('color_rpm_max')
                midColorChecked     =        paramController.getColor('color_rpm_med')
                minColorChecked     =        paramController.getColor('color_rpm_min')
                updated = false
            }
        }
    }


    function getVisible(value)
    {
        if(value === 1) return 'Hide'
        else return 'Show'
    }
    function getValue(value)
    {
        if(value === 1) return 0
        else return 1
    }
    function getTruth(value)
    {
        if(value === 1) return true
        else return false
    }


    ParameterEditorController{
        id:
            paramController
    }


    /// Default color palette used throughout the UI
    QGCPalette { id: qgcPal; colorGroupEnabled: true }



    Text {
        id: _rpm
        x: Screen.width * .2
        anchors.left: _title.horizontalCenter
        anchors.top: _title.bottom
        anchors.topMargin: _title.height
        text: qsTr("Change Values(0-100): ")
        font.italic: true
        width: _textEditWidth * 1.4
        color: 'white'
        horizontalAlignment: Text.AlignHCenter
        font.pixelSize: 20
    }

    Text {
        id: _rpmCurr
        anchors.left: _rpm.right
        anchors.leftMargin: _rpm.width / 3
        anchors.verticalCenter: _rpm.verticalCenter
        text: qsTr("Current Display")
        font.italic: true
        width: _textEditWidth * 1.4
        color: 'white'
        horizontalAlignment: Text.AlignHCenter
        font.pixelSize: 20
    }


    Text {
        id: rpm_color_maximum_text
        text: qsTr("Max (Saturation)")
        color: 'white'
        font.pixelSize: 18
        anchors.bottom: rpm_color_maximum.top
        anchors.horizontalCenter: rpm_color_maximum.horizontalCenter
    }
    TextField {
        id: rpm_color_maximum
        anchors.top: _rpm.bottom
        anchors.topMargin: _rpm.height * 2
        anchors.horizontalCenter: _rpm.horizontalCenter
        placeholderText: qsTr("")
        text: ""
        //validator: IntValidator {bottom: 0; top: 100;}
        width: _textEditWidth / 4
        height: width * .8
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        style: TextFieldStyle{
            textColor: 'black'
            background: Rectangle{
                    color: 'lightgray'
                    border.color: 'gray'
                    border.width: 3
                    implicitWidth: rpm_color_maximum.width
                    implicitHeight: rpm_color_maximum.height
                }
            }
    }

    ColorDialog {
        id: rpm_colorDialog_max
        visible: false
        title: "Please choose a color for the maximum"
        color: maxColor
        onAccepted: {
            maxColor = rpm_colorDialog_max.color
        }
    }
    Button{
        id: rpm_color_maximumButton
        width: rpm_color_maximum.width / 1.875
        height: width
        Rectangle{
            color: maxColor
            border.color: 'white'
            border.width: 1
            implicitWidth: rpm_color_maximumButton.width
            implicitHeight: rpm_color_maximumButton.height
        }


        anchors.left: rpm_color_maximum.right
        anchors.leftMargin: rpm_color_maximum.width / 8
        anchors.verticalCenter: rpm_color_maximum.verticalCenter
        onClicked: {
            rpm_colorDialog_max.visible = true
        }
    }
    Text {
        id: rpm_color_medium_text
        text: qsTr("Caution")
        color: 'white'
        font.pixelSize: 18
        anchors.bottom: rpm_color_medium.top
        anchors.horizontalCenter: rpm_color_medium.horizontalCenter
    }
    TextField {
        id: rpm_color_medium
        anchors.top: rpm_color_maximumButton.bottom
        anchors.topMargin: rpm_color_medium_text.height * 1.5
        anchors.horizontalCenter: _rpm.horizontalCenter
        placeholderText: qsTr("")
        text: ""
        //validator: IntValidator {bottom: 0; top: 100;}
        width: _textEditWidth / 4
        height: width * .8
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        style: TextFieldStyle{
            textColor: 'black'
            background: Rectangle{
                    color: 'lightgray'
                    border.color: 'gray'
                    border.width: 3
                    implicitWidth: rpm_color_medium.width
                    implicitHeight: rpm_color_medium.height
                }
            }
    }

    ColorDialog {
        id: rpm_colorDialog_med
        visible: false
        title: "Please choose a color for the medium"
        color: midColor
        onAccepted: {
            midColor = rpm_colorDialog_med.color
        }
    }
    Button{
        id: rpm_color_mediumButton
        width: rpm_color_medium.width / 1.875
        height: width
        Rectangle{
            color: midColor
            border.color: 'white'
            border.width: 1
            implicitWidth: rpm_color_mediumButton.width
            implicitHeight: rpm_color_mediumButton.height
        }


        anchors.left: rpm_color_medium.right
        anchors.leftMargin: rpm_color_medium.width / 8
        anchors.verticalCenter: rpm_color_medium.verticalCenter
        onClicked: {
            rpm_colorDialog_med.visible = true
        }
    }

    Text {
        id: rpm_color_minimum_text
        text: qsTr("Target")
        color: 'white'
        font.pixelSize: 18
        anchors.top: rpm_color_medium.top
        anchors.topMargin: rpm_color_medium.height * 2
        anchors.horizontalCenter: _rpm.horizontalCenter
    }

    ColorDialog {
        id: rpm_colorDialog_min
        visible: false
        title: "Please choose a color for the minimum"
        color: minColor
        onAccepted: {
            minColor = rpm_colorDialog_min.color
        }
    }
    Button{
        id: rpm_color_minimumButton
        width: rpm_color_mediumButton.width
        height: width
        Rectangle{
            color: minColor
            border.color: 'white'
            border.width: 1
            implicitWidth: rpm_color_minimumButton.width
            implicitHeight: rpm_color_minimumButton.height
        }


        anchors.horizontalCenter: rpm_color_mediumButton.horizontalCenter
        anchors.verticalCenter: rpm_color_minimum_text.verticalCenter
        onClicked: {
            rpm_colorDialog_min.visible = true
        }
    }

    Button{
        id: update
        width: _textEditWidth / 2
        height: width / 3



        Rectangle{
            color: 'lightgray'
            border.color: 'gray'
            border.width: 3
            implicitWidth: update.width
            implicitHeight: update.height
            anchors.fill: parent
            Text {
                text: qsTr("Update")
                font.pixelSize: 22
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }


        anchors.horizontalCenter: _rpm.horizontalCenter
        anchors.top: rpm_color_minimumButton.bottom
        anchors.topMargin: rpm_color_minimumButton.height * 2
        onClicked: {
            updated = true
            paramController.changeColor('color_rpm_min', minColor)
            paramController.changeColor('color_rpm_med', midColor)
            paramController.changeColor('color_rpm_max', maxColor)
            if(rpm_color_maximum.text < 100 && rpm_color_maximum.text > 0){
                if(rpm_color_medium.text > 0 && rpm_color_medium.text < 100){
                    if(rpm_color_maximum.text > rpm_color_medium.text){
                        paramController.changeValue('RPM_color_high', rpm_color_maximum.text)
                        rpm_color_maximum.text = ''
                    }
                }
                else{
                    if(rpm_color_maximum.text > midChecked){
                        paramController.changeValue('RPM_color_high', rpm_color_maximum.text)
                        rpm_color_maximum.text = ''
                    }
                }
            }

            if(rpm_color_medium.text < 100 && rpm_color_medium.text > 0){
                if(rpm_color_maximum.text > 0 && rpm_color_maximum.text < 100){
                    if(rpm_color_medium.text < rpm_color_maximum.text){
                        paramController.changeValue('RPM_color_mid', rpm_color_medium.text)
                        rpm_color_medium.text = ''
                    }
                }
                else{
                    if(rpm_color_medium.text < highChecked){
                        paramController.changeValue('RPM_color_mid', rpm_color_medium.text)
                        rpm_color_medium.text = ''
                    }
                }
            }
        }
    }

    function findWidth(width, value){
        if(value < highChecked){
            //mid
            if(value < 30){
                return width * ((30) / 100)
            }
        }
        else{
            //high
            if(value < 40){
                return width * ((40) / 100)
            }
        }

        return width * ((value) / 100)
    }

    Rectangle{
        id: rpm_circle_green
        z: 1000
        anchors.horizontalCenter: rpm_circle_red.horizontalCenter
        anchors.verticalCenter: rpm_circle_red.verticalCenter
        width: findWidth(rpm_circle_red.width * .75, midChecked)
        height: width
        radius: width * .5
        color: minColorChecked
        border.width: 4
        border.color: 'black'
        Text {
            z: 10000
            text: midChecked
            color: "white"
            style: Text.Outline
            styleColor: 'black'
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: -parent.width / 5
            anchors.horizontalCenterOffset: -parent.height / 5
        }
    }
    Rectangle{
        id: rpm_circle_yellow
        z:100
        anchors.horizontalCenter: rpm_circle_red.horizontalCenter
        anchors.verticalCenter: rpm_circle_red.verticalCenter
        width: findWidth(rpm_circle_red.width * .925, highChecked)
        height: width
        radius: width * .5
        color: midColorChecked
        border.width: 4
        border.color: 'black'
        Text {
            z: 10000
            text: highChecked
            color: "white"
            style: Text.Outline
            styleColor: 'black'
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: -parent.width / 3.25
            anchors.horizontalCenterOffset: -parent.height / 3.25
        }
    }
    Rectangle{
        id: rpm_circle_red
        z:1
        anchors.horizontalCenter: _rpmCurr.horizontalCenter
        anchors.verticalCenter: rpm_color_mediumButton.verticalCenter
        anchors.verticalCenterOffset: height / 4
        width: _textEditWidth
        height: width
        radius: width * .5
        color: maxColorChecked
        border.width: 4
        border.color: 'white'
    }
    Text {
        id: _rpmMinMax
        anchors.horizontalCenter: rpm_circle_red.horizontalCenter
        anchors.top: rpm_circle_red.bottom
        anchors.topMargin: _rpm.width / 4
        text: qsTr("Display Min/Max")
        color: 'white'
        horizontalAlignment: Text.AlignHCenter
        font.pixelSize: 20
    }
    CheckBox{
        id: minmax
        checked: _minmax
        width: 20
        anchors.right: _rpmMinMax.left
        anchors.verticalCenter: _rpmMinMax.verticalCenter
        //anchors.verticalCenterOffset: -10
        onClicked: {
            paramController.changeValue('minmax', getValue(paramController.getValue('minmax')))
        }
        style: CheckBoxStyle {
                indicator: Rectangle {
                        implicitWidth: 16
                        implicitHeight: 16
                        border.color: 'gray'
                        border.width: 2
                        Text {
                            text: '✓'
                            visible: control.checked
                            //color: control.activeFocus ? "black" : "lightgray"
                            //color: "lightgray"
                            //anchors.margins: 4
                            anchors.fill: parent
                            anchors.leftMargin: 2
                        }
                }
            }
    }
//    Rectangle{
//        id: rpm_circle_border
//        z:1000
//        anchors.horizontalCenter: _rpmCurr.horizontalCenter
//        anchors.verticalCenter: rpm_color_mediumButton.verticalCenter
//        anchors.verticalCenterOffset: height / 4
//        width: _textEditWidth + border.width
//        height: width
//        radius: width * .5
//        color: 'transparent'
//        border.color: 'white'
//        border.width: 4
//    }
//    Rectangle{
//        id: circ_top
//        z:1
//        width: Math.sqrt(2 * (diameter - diameter * (high / 100)) * (diameter / 2) - Math.pow((diameter - diameter * (high / 100)), 2)) * 2 + rpm_circle_border.border.width
//        anchors.horizontalCenter: rpm_circle.horizontalCenter
//        anchors.top: rpm_circle.bottom
//        anchors.topMargin: -(diameter * (high / 100))
//        height: 2
//        color: 'black'
//    }
//    Text{
//        id: circ_top_text
//        text: (high).toFixed(0)
//        anchors.right: circ_top.left
//        anchors.rightMargin: circ_top.border.width * 2
//        anchors.verticalCenter: circ_top.verticalCenter
//        anchors.verticalCenterOffset: -circ_top_text.height / 2
//        color: 'white'
//        font.pointSize: 16
//    }
//    Rectangle{
//        id: circ_mid
//        z:1
//        width: Math.sqrt(2 * (diameter - diameter * (mid / 100)) * (diameter / 2) - Math.pow((diameter - diameter * (mid / 100)), 2)) * 2 + rpm_circle_border.border.width
//        anchors.horizontalCenter: rpm_circle.horizontalCenter
//        anchors.top: rpm_circle.bottom
//        anchors.topMargin: -(diameter * (mid / 100))
//        height: 2
//        color: 'black'
//    }

//    Text{
//        id: circ_mid_text
//        text: (mid).toFixed(0)
//        anchors.right: circ_mid.left
//        anchors.rightMargin: circ_top.border.width * 2
//        anchors.verticalCenter: circ_mid.verticalCenter
//        anchors.verticalCenterOffset: -circ_mid_text.height / 2
//        color: 'white'
//        font.pointSize: 16
//    }

    Button{
        id: restore
        width: _textEditWidth / 2
        height: width / 3



        Rectangle{
            id: restore_button
            color: 'lightgray'
            border.color: 'gray'
            border.width: 3
            implicitWidth: restore.width
            implicitHeight: restore.height
            anchors.fill: parent
            Text {
                text: qsTr("Restore")
                font.pixelSize: 22
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }

        Text {
            text: qsTr("Apply default\nsettings")
            color: 'white'
            font.pixelSize: 18
            anchors.top:restore_button.bottom
            anchors.topMargin: parent.height / 4
            anchors.horizontalCenter: parent.horizontalCenter
            horizontalAlignment: Text.AlignHCenter
        }
        anchors.verticalCenter: rpm_circle_red.verticalCenter
        anchors.left: rpm_circle_red.right
        anchors.leftMargin: rpm_circle_red.width / 4
        onClicked: {
            updated = true
            paramController.changeColor('color_rpm_min', 'green')
            paramController.changeColor('color_rpm_med', 'yellow')
            paramController.changeColor('color_rpm_max', 'red')
            paramController.changeValue('RPM_color_mid', 95)
            paramController.changeValue('RPM_color_high', 99)
            minColor = 'green'
            midColor = 'yellow'
            maxColor = 'red'
        }
    }
}



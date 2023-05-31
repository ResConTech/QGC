
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
    property color maxColor: paramController.getColor('color_batt_max')
    property color midColor: paramController.getColor('color_batt_med')
    property color minColor: paramController.getColor('color_batt_min')

    property color maxColorChecked: paramController.getColor('color_batt_max')
    property color midColorChecked: paramController.getColor('color_batt_med')
    property color minColorChecked: paramController.getColor('color_batt_min')

    property double low: paramController.getValue('batt_low')
    property double mid: paramController.getValue('batt_mid')

    property double lowChecked: paramController.getValue('batt_low')
    property double midChecked: paramController.getValue('batt_mid')

    property bool updated: false
    Text {
        id: _title
        x: Screen.width * .025 //2.75
        text: "Battery Display Settings"
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
            if(updated){
                maxColorChecked    =    paramController.getColor('color_batt_max')
                midColorChecked    =    paramController.getColor('color_batt_med')
                minColorChecked    =    paramController.getColor('color_batt_min')

                lowChecked         =    paramController.getValue('batt_low')
                midChecked         =    paramController.getValue('batt_mid')
                updated     =    false
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
        id: _batt
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
        id: _battCurr
        anchors.left: _batt.right
        anchors.leftMargin: _batt.width
        anchors.verticalCenter: _batt.verticalCenter
        text: qsTr("Current Display")
        font.italic: true
        width: _textEditWidth * 1.4
        color: 'white'
        horizontalAlignment: Text.AlignHCenter
        font.pixelSize: 20
    }

    Text {
        id: batt_color_caution_text
        text: qsTr("Caution")
        color: 'white'
        font.pixelSize: 18
        anchors.bottom: batt_color_caution.top
        anchors.horizontalCenter: batt_color_caution.horizontalCenter
    }
    TextField {
        id: batt_color_caution
        anchors.top: _batt.bottom
        anchors.topMargin: _batt.height * 2
        anchors.horizontalCenter: _batt.horizontalCenter
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
                    implicitWidth: batt_color_caution.width
                    implicitHeight: batt_color_caution.height
                }
            }
    }

    ColorDialog {
        id: batt_colorDialog_caution
        visible: false
        title: "Please choose a color for the caution color"
        color: midColor
        onAccepted: {
            midColor = batt_colorDialog_caution.color
        }
    }
    Button{
        id: batt_color_cautionButton
        width: batt_color_caution.width / 1.875
        height: width
        Rectangle{
            color: midColor
            border.color: 'white'
            border.width: 1
            implicitWidth: batt_color_cautionButton.width
            implicitHeight: batt_color_cautionButton.height
        }


        anchors.top: batt_color_caution.bottom
        anchors.topMargin: batt_color_caution.width / 4
        anchors.horizontalCenter: batt_color_caution.horizontalCenter
        onClicked: {
            batt_colorDialog_caution.visible = true
        }
    }

    Text {
        id: batt_color_warning_text
        text: qsTr("Warning")
        color: 'white'
        font.pixelSize: 18
        anchors.bottom: batt_color_warning.top
        anchors.horizontalCenter: batt_color_warning.horizontalCenter
    }
    TextField {
        id: batt_color_warning
        anchors.left: batt_color_caution.right
        anchors.leftMargin: _batt.height * 2
        anchors.verticalCenter: batt_color_caution.verticalCenter
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
                    implicitWidth: batt_color_warning.width
                    implicitHeight: batt_color_warning.height
                }
            }
    }

    ColorDialog {
        id: batt_colorDialog_warning
        visible: false
        title: "Please choose a color for the warning color"
        color: minColor
        onAccepted: {
            minColor = batt_colorDialog_warning.color
        }
    }
    Button{
        id: batt_color_warningButton
        width: batt_color_warning.width / 1.875
        height: width
        Rectangle{
            color: minColor
            border.color: 'white'
            border.width: 1
            implicitWidth: batt_color_warningButton.width
            implicitHeight: batt_color_warningButton.height
        }


        anchors.top: batt_color_warning.bottom
        anchors.topMargin: batt_color_warning.width / 4
        anchors.horizontalCenter: batt_color_warning.horizontalCenter
        onClicked: {
            batt_colorDialog_warning.visible = true
        }
    }

    Text {
        id: batt_color_normal_text
        text: qsTr("Normal")
        color: 'white'
        font.pixelSize: 18
        anchors.right: batt_color_caution.left
        anchors.rightMargin: _batt.height * 2
        anchors.verticalCenter: batt_color_caution.verticalCenter
    }

    ColorDialog {
        id: batt_colorDialog_normal
        visible: false
        title: "Please choose a color for the normal color"
        color: maxColor
        onAccepted: {
            maxColor = batt_colorDialog_normal.color
        }
    }
    Button{
        id: batt_color_normalButton
        width: batt_color_caution.width / 1.875
        height: width
        Rectangle{
            color: maxColor
            border.color: 'white'
            border.width: 1
            implicitWidth: batt_color_normalButton.width
            implicitHeight: batt_color_normalButton.height
        }


        anchors.verticalCenter: batt_color_warningButton.verticalCenter
        anchors.horizontalCenter: batt_color_normal_text.horizontalCenter
        onClicked: {
            batt_colorDialog_normal.visible = true
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


        anchors.horizontalCenter: _batt.horizontalCenter
        anchors.top: batt_color_cautionButton.bottom
        anchors.topMargin: batt_color_cautionButton.height
        onClicked: {
            updated = true
            paramController.changeColor('color_batt_min', minColor)
            paramController.changeColor('color_batt_med', midColor)
            paramController.changeColor('color_batt_max', maxColor)
            if((batt_color_caution.text > lowChecked || ((batt_color_caution.text > batt_color_warning.text) && (batt_color_warning.text > 0 && batt_color_warning.text < 100))) && batt_color_caution.text < 100){
                paramController.changeValue('batt_mid', batt_color_caution.text)
                batt_color_caution.text = ''
            }
            if(batt_color_warning.text > 0 && (batt_color_warning.text < midChecked || ((batt_color_warning.text < batt_color_caution.text) && (batt_color_caution.text > 0 && batt_color_caution.text < 99)))){
                paramController.changeValue('batt_low', batt_color_warning.text)
                batt_color_warning.text = ''
            }
        }
    }
    Rectangle{
        id: battery_border
        width: battery.width
        height: battery.height
        border.width: 4
        border.color: 'white'
        z: 10000
        anchors.horizontalCenter: _battCurr.horizontalCenter
        anchors.top: _battCurr.bottom
        anchors.topMargin: batt_color_normalButton.height * 2
        radius: 8
        color: 'transparent'
    }
    Rectangle{
        id: battery
        width: batt_color_normalButton.width * 6
        height: width / 3
        border.width: 4
        border.color: 'white'
        z: 10
        anchors.horizontalCenter: _battCurr.horizontalCenter
        anchors.top: _battCurr.bottom
        anchors.topMargin: batt_color_normalButton.height * 2
        radius: 8
        color: maxColorChecked
    }
    Rectangle{
        z: 1

        id: battery_ornate
        height: battery.height / 3.25
        width: height / 1.25
        anchors.right: battery.left
        anchors.rightMargin: -width / 2
        anchors.verticalCenter: battery.verticalCenter
        color: "white"
        radius: 4
    }
    Rectangle{
        id: red
        anchors.verticalCenter: battery.verticalCenter
        anchors.right: battery.right
        anchors.rightMargin: battery.border.width
        z: 100
        color: minColorChecked
        width: battery.width * (lowChecked / 100.0)
        height: battery.height - (battery.border.width * 2)
    }
    Rectangle{
        id: red_divider
        z: 1000
        anchors.left: red.left
        anchors.verticalCenter: red.verticalCenter
        width: battery.border.width / 1.5
        height: red.height
        color: 'black'
    }
    Text {
        id: red_text
        text: lowChecked
        anchors.bottom: red_divider.top
        anchors.horizontalCenter: red_divider.horizontalCenter
        anchors.bottomMargin: battery.border.width * 3
        color: 'white'
        font.pixelSize: 22
    }
    Rectangle{
        id: yellow
        anchors.verticalCenter: battery.verticalCenter
        anchors.right: red_divider.left
        z: 100
        color: midColorChecked
        width: battery.width * (midChecked / 100.0)
        height: battery.height - (battery.border.width * 2)
    }
    Rectangle{
        id: yellow_divider
        z: 1000
        anchors.left: yellow.left
        anchors.verticalCenter: yellow.verticalCenter
        width: battery.border.width / 1.5
        height: yellow.height
        color: 'black'
    }
    Text {
        id: yellow_text
        text: midChecked
        anchors.bottom: yellow_divider.top
        anchors.horizontalCenter: yellow_divider.horizontalCenter
        anchors.bottomMargin: battery.border.width * 3
        color: 'white'
        font.pixelSize: 22
    }
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
        anchors.left: battery.right
        anchors.verticalCenter: battery.verticalCenter
        anchors.leftMargin: battery.width / 3
        onClicked: {
            updated = true
            paramController.changeColor('color_batt_min', 'red')
            paramController.changeColor('color_batt_med', 'yellow')
            paramController.changeColor('color_batt_max', 'green')
            paramController.changeValue('batt_low', 10)
            paramController.changeValue('batt_mid', 25)
            minColor = 'red'
            midColor = 'yellow'
            maxColor = 'green'
        }
    }
}

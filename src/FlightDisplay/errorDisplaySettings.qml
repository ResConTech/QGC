
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
    property double min: 0
    property bool minChanged: false
    property double med: 0
    property bool medChanged: false
    property double max: 0
    property bool maxChanged: false
    property color maxColor: paramController.getColor('color_error_max')
    property color midColor: paramController.getColor('color_error_med')
    property color minColor: paramController.getColor('color_error_min')

    property color maxColorChecked: paramController.getColor('color_error_max')
    property color midColorChecked: paramController.getColor('color_error_med')
    property color minColorChecked: paramController.getColor('color_error_min')

    property double maxValue: paramController.getValue('Rerror_color_maximum')
    property double midValue: paramController.getValue(('Rerror_color_medium'))
    property double minValue: paramController.getValue(('Rerror_color_minimum'))

    property double maxValueTemp: paramController.getValue('Rerror_color_maximum')
    property double midValueTemp: paramController.getValue(('Rerror_color_medium'))
    property double minValueTemp: paramController.getValue(('Rerror_color_minimum'))

    property bool maxBound: true
    property bool midBound: true
    property bool minBound: true

    property double maxValueChecked: paramController.getValue('Rerror_color_maximum').toFixed(1)
    property double midValueChecked: paramController.getValue(('Rerror_color_medium')).toFixed(1)
    property double minValueChecked: paramController.getValue(('Rerror_color_minimum')).toFixed(1)

    property bool updated: false
    Timer {
        interval:   10
        running:    true
        repeat: true
        onTriggered: {
            maxValue = error_color_maximum.getText(0,error_color_maximum.length)
            midValue = error_color_medium.getText(0,error_color_medium.length)
            minValue = error_color_minimum.getText(0,error_color_minimum.length)
            if(updated){
                maxValueChecked = paramController.getValue('Rerror_color_maximum').toFixed(1)
                midValueChecked = paramController.getValue(('Rerror_color_medium')).toFixed(1)
                minValueChecked = paramController.getValue(('Rerror_color_minimum')).toFixed(1)

                maxValueTemp    = paramController.getValue('Rerror_color_maximum').toFixed(1)
                midValueTemp    = paramController.getValue(('Rerror_color_medium')).toFixed(1)
                minValueTemp    = paramController.getValue(('Rerror_color_minimum')).toFixed(1)

                maxColorChecked = paramController.getColor('color_error_max')
                midColorChecked = paramController.getColor('color_error_med')
                minColorChecked = paramController.getColor('color_error_min')
                updated         = false
            }
        }
    }

    function getMin(value)
    {
        min = value
        minChanged = true
    }
    function getMed(value){
        med = value;
        medChanged = true;
    }
    function getMax(value){
        max = value;
        maxChanged = true;
    }
    function balanceErrorBar(){
        if(maxChanged && max.toFixed(1) <= 100){
            maxValueTemp = max.toFixed(1)
        }
        else{
            maxBound = false
        }
        if(medChanged && med.toFixed(1) <= 100){
            midValueTemp = med.toFixed(1)
        }
        else{
            midBound = false
        }
        if(minChanged && min.toFixed(1) <= 100){
            minValueTemp = min.toFixed(1)
        }
        else{
            minBound = false
        }
        if(maxChanged && maxBound){
            if(midValueTemp > maxValueTemp){
                if(minValueTemp > maxValueTemp){
                    paramController.changeValue("Rerror_color_minimum", maxValueTemp)
                }
                paramController.changeValue("Rerror_color_maximum", maxValueTemp)
                paramController.changeValue("Rerror_color_medium", maxValueTemp)
            }
            else{
                paramController.changeValue("Rerror_color_maximum", maxValueTemp)
            }
        }
        if(medChanged && midBound){
            if(midValueTemp > maxValueTemp){
                paramController.changeValue("Rerror_color_medium", maxValueTemp)
            }
            else if (midValueTemp < minValueTemp){
                paramController.changeValue("Rerror_color_minimum", midValueTemp)
                paramController.changeValue("Rerror_color_medium", midValueTemp)
            }
            else{
                paramController.changeValue("Rerror_color_medium", midValueTemp)
            }
        }
        if(minChanged && minBound){
            if(minValueTemp > midValueTemp){
                paramController.changeValue("Rerror_color_minimum", midValueTemp)
            }
            else{
                paramController.changeValue("Rerror_color_minimum", minValueTemp)
            }
        }
        minBound = true
        midBound = true
        maxBound = true
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
    Text {
        id: _title
        x: Screen.width * .025 //2.75
        text: "Error Bars"
        color: 'white'
        font.pixelSize: 50
        font.bold: true
        verticalAlignment: Text.AlignVCenter
    }

    /// Default color palette used throughout the UI
    QGCPalette { id: qgcPal; colorGroupEnabled: true }


    Rectangle {
        id: _errorBlank
        x: Screen.width * .2
        y: Screen.height * .2
        height: Screen.width * .15
        width: Screen.width * .015
        color: 'transparent'
        border.color: 'white'
        border.width: 2
    }
    Rectangle {
        id: _errorCurrent
        x: Screen.width * .5
        y: Screen.height * .2
        z: 1000
        height: Screen.width * .15
        width: Screen.width * .015
        color: 'transparent'
        border.color: 'white'
        border.width: 2
    }
    Rectangle {
        id: _errorCurrentTop
        anchors.horizontalCenter: _errorCurrent.horizontalCenter
        anchors.bottom: _errorCurrent.bottom
        anchors.bottomMargin: _errorCurrent.height * (1 - ((midValueChecked + maxValueChecked) / (2 * maxValueChecked)))
        //y: Screen.height * .2 + (_errorCurrent.height * .85)
        z: 1
        height: _errorScaleVert.width
        width: Screen.width * .015
        border.color: 'black'
        border.width: 2
    }
    Rectangle {
        id: _errorCurrentMidTop
        anchors.horizontalCenter: _errorCurrent.horizontalCenter
        anchors.bottom: _errorCurrent.bottom
        anchors.bottomMargin: _errorCurrent.height * ((maxValueChecked - minValueChecked) / (2 * maxValueChecked))
        //y: Screen.height * .2 + (_errorCurrent.height * .6)
        z: 1
        height: _errorScaleVert.width
        width: Screen.width * .015
        border.color: 'black'
        border.width: 2
    }
    Rectangle {
        id: _errorCurrentMidBot
        anchors.horizontalCenter: _errorCurrent.horizontalCenter
        anchors.bottom: _errorCurrent.bottom
        anchors.bottomMargin: _errorCurrent.height * ((maxValueChecked + minValueChecked) / (2 * maxValueChecked))
        //y: Screen.height * .2 + (_errorCurrent.height * .4)
        z: 1
        height: _errorScaleVert.width
        width: Screen.width * .015
        border.color: 'black'
        border.width: 2
    }
    Rectangle {
        id: _errorCurrentBot
        anchors.horizontalCenter: _errorCurrent.horizontalCenter
        anchors.bottom: _errorCurrent.bottom
        anchors.bottomMargin: _errorCurrent.height * ((midValueChecked + maxValueChecked) / (2 * maxValueChecked))
        //y: Screen.height * .2 + (_errorCurrent.height * .15)
        z: 1
        height: _errorScaleVert.width
        width: Screen.width * .015
        border.color: 'black'
        border.width: 2
    }
    Rectangle{
        anchors.top: _errorCurrent.top
        anchors.bottom: _errorCurrentBot.top
        anchors.left: _errorCurrentBot.left
        anchors.right: _errorCurrentBot.right
        anchors.topMargin: _errorCurrentBot.height
        anchors.leftMargin: _errorCurrentBot.height
        anchors.rightMargin: _errorCurrentBot.height
        color: maxColorChecked
    }
    Rectangle{
        anchors.top: _errorCurrentBot.top
        anchors.bottom: _errorCurrentMidBot.top
        anchors.left: _errorCurrentMidBot.left
        anchors.right: _errorCurrentMidBot.right
        anchors.topMargin: _errorCurrentMidBot.height
        anchors.leftMargin: _errorCurrentMidBot.height
        anchors.rightMargin: _errorCurrentMidBot.height
        color: midColorChecked
    }
    Rectangle{
        anchors.top: _errorCurrentMidBot.top
        anchors.bottom: _errorCurrentMidTop.top
        anchors.left: _errorCurrentMidTop.left
        anchors.right: _errorCurrentMidTop.right
        anchors.topMargin: _errorCurrentMidTop.height
        anchors.leftMargin: _errorCurrentMidTop.height
        anchors.rightMargin: _errorCurrentMidTop.height
        color: minColorChecked
    }
    Rectangle{
        anchors.top: _errorCurrentMidTop.top
        anchors.bottom: _errorCurrentTop.top
        anchors.left: _errorCurrentTop.left
        anchors.right: _errorCurrentTop.right
        anchors.topMargin: _errorCurrentTop.height
        anchors.leftMargin: _errorCurrentTop.height
        anchors.rightMargin: _errorCurrentTop.height
        color: midColorChecked
    }
    Rectangle{
        anchors.top: _errorCurrentTop.bottom
        anchors.bottom: _errorCurrent.bottom
        anchors.left: _errorCurrent.left
        anchors.right: _errorCurrent.right
        anchors.bottomMargin: _errorCurrentTop.height
        anchors.leftMargin: _errorCurrentTop.height
        anchors.rightMargin: _errorCurrentTop.height
        color: maxColorChecked
    }
    Rectangle {
        id: _currentScaleVert
        anchors.left: _errorCurrent.right
        anchors.leftMargin: _errorCurrent.width / 2
        anchors.top: _errorCurrent.top
        height:_errorCurrent.height
        width: _errorBlank.border.width
        color: 'white'
    }
    Rectangle {
        id: _currentScaleCenter
        anchors.left: _currentScaleVert.right
        anchors.verticalCenter: _errorScaleVert.verticalCenter
        height: _errorScaleVert.width
        width: height * 10
        color: 'white'
    }
    Text {
        id: current_cent
        anchors.left: _currentScaleTop.right
        anchors.verticalCenter: _errorScaleCenter.verticalCenter
        text: qsTr("0")
        anchors.leftMargin: _errorScaleCenter.width / 4
        color: 'white'
        font.pixelSize: 18
    }
    Text {
        id: current_top
        anchors.left: _currentScaleTop.right
        anchors.verticalCenter: _currentScaleTop.verticalCenter
        text: maxValueChecked
        anchors.leftMargin: _errorScaleCenter.width / 4
        color: 'white'
        font.pixelSize: 18
    }
    Text {
        id: current_bot
        anchors.left: _currentScaleTop.right
        anchors.verticalCenter: _currentScaleBottom.verticalCenter
        text: -maxValueChecked
        anchors.leftMargin: _errorScaleCenter.width / 4
        color: 'white'
        font.pixelSize: 18
    }
    Text {
        id: current_low
        anchors.horizontalCenter: current_mid.horizontalCenter
        anchors.verticalCenter: _errorCurrentMidBot.verticalCenter
        text: minValueChecked
        anchors.rightMargin: _errorScaleCenter.width / 4
        color: 'white'
        font.pixelSize: 18
    }
    Text {
        id: current_mid
        anchors.right: _errorCurrent.left
        anchors.verticalCenter: _errorCurrentBot.verticalCenter
        text: midValueChecked
        anchors.rightMargin: _errorScaleCenter.width / 2
        color: 'white'
        font.pixelSize: 18
    }
    Rectangle {
        id: _currentScaleTop
        anchors.left: _currentScaleVert.right
        anchors.top: _errorScaleVert.top
        height: _errorScaleVert.width
        width: height * 10
        color: 'white'
    }

    Rectangle {
        id: _currentScaleBottom
        anchors.left: _currentScaleVert.right
        anchors.bottom: _errorScaleVert.bottom
        height: _errorScaleVert.width
        width: height * 10
        color: 'white'
    }

    Rectangle {
        id: _errorScaleVert
        anchors.left: _errorBlank.right
        anchors.leftMargin: _errorBlank.width / 2
        anchors.top: _errorBlank.top
        height:_errorBlank.height
        width: _errorBlank.border.width
        color: 'white'
    }
    Rectangle {
        id: _errorScaleCenter
        anchors.left: _errorScaleVert.right
        anchors.verticalCenter: _errorScaleVert.verticalCenter
        height: _errorScaleVert.width
        width: height * 10
        color: 'white'
    }
    Text {
        id: error_cent
        anchors.left: _errorScaleCenter.right
        anchors.verticalCenter: _errorScaleCenter.verticalCenter
        text: qsTr("0")
        anchors.leftMargin: _errorScaleCenter.width / 4
        color: 'white'
        font.pixelSize: 18
    }
    Rectangle {
        id: _errorScaleTop
        anchors.left: _errorScaleVert.right
        anchors.top: _errorScaleVert.top
        height: _errorScaleVert.width
        width: height * 10
        color: 'white'
    }
    Rectangle {
        id: _errorScaleBottom
        anchors.left: _errorScaleVert.right
        anchors.bottom: _errorScaleVert.bottom
        height: _errorScaleVert.width
        width: height * 10
        color: 'white'
    }

    Text {
        id: _error
        anchors.horizontalCenter: _errorBlank.horizontalCenter
        anchors.bottom: _errorBlank.top
        anchors.bottomMargin: _errorBlank.height / 4
        text: qsTr("Change Values(0-100): ")
        font.italic: true
        width: _textEditWidth * 1.4
        color: 'white'
        horizontalAlignment: Text.AlignHCenter
        font.pixelSize: 20
    }

    Text {
        id: _errorCurr
        anchors.horizontalCenter: _errorCurrent.horizontalCenter
        anchors.verticalCenter: _error.verticalCenter
        text: qsTr("Current Display")
        font.italic: true
        width: _textEditWidth * 1.4
        color: 'white'
        horizontalAlignment: Text.AlignHCenter
        font.pixelSize: 20
    }

    Text {
        id: error_color_maximum_text
        text: qsTr("Max")
        color: 'white'
        font.pixelSize: 18
        anchors.bottom: error_color_maximum.top
        anchors.horizontalCenter: error_color_maximum.horizontalCenter
    }
    TextField {
        id: error_color_maximum
        anchors.left: _errorScaleTop.right
        anchors.leftMargin: _errorScaleTop.width / 4
        anchors.verticalCenter: _errorScaleTop.verticalCenter
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
                    implicitWidth: error_color_maximum.width
                    implicitHeight: error_color_maximum.height
                }
            }
    }

    ColorDialog {
        id: error_colorDialog_max
        visible: false
        title: "Please choose a color for the maximum"
        color: maxColor
        onAccepted: {
            maxColor = error_colorDialog_max.color
        }
    }
    Button{
        id: error_color_maximumButton
        width: error_color_maximum.width / 1.875
        height: width
        Rectangle{
            color: maxColor
            border.color: 'white'
            border.width: 1
            implicitWidth: error_color_maximumButton.width
            implicitHeight: error_color_maximumButton.height
        }


        anchors.left: error_color_maximum.right
        anchors.leftMargin: error_color_maximum.width / 8
        anchors.verticalCenter: error_color_maximum.verticalCenter
        onClicked: {
            error_colorDialog_max.visible = true
        }
    }

    Text {
        id: error_color_medium_text
        text: qsTr("Medium")
        color: 'white'
        font.pixelSize: 18
        anchors.bottom: error_color_medium.top
        anchors.horizontalCenter: error_color_medium.horizontalCenter
    }
    TextField {
        id: error_color_medium
        anchors.right: _errorBlank.left
        anchors.top: _errorScaleTop.top
        anchors.topMargin: _errorScaleTop.width / 2
        anchors.rightMargin: _errorScaleTop.width / 2
        placeholderText: qsTr("")
        text: ""
        //validator: IntValidator {bottom: 0; top: 99;}
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
                    implicitWidth: error_color_minimum.width
                    implicitHeight: error_color_minimum.height
                }
            }
    }
    ColorDialog {
        id: error_colorDialog_med
        visible: false
        title: "Please choose a color for the medium"
        color: midColor
        onAccepted: {
            midColor = error_colorDialog_med.color
        }
    }
    Button{
        id: error_color_mediumButton
        width: error_color_medium.width / 1.875
        height: width
        Rectangle{
            color: midColor
            border.color: 'white'
            border.width: 1
            implicitWidth: error_color_mediumButton.width
            implicitHeight: error_color_mediumButton.height
        }


        anchors.right: error_color_medium.left
        anchors.rightMargin: _errorScaleTop.width / 2
        anchors.verticalCenter: error_color_medium.verticalCenter
        onClicked: {
            error_colorDialog_med.visible = true
        }
    }
    Text {
        id: error_color_minimum_text
        text: qsTr("Low")
        color: 'white'
        font.pixelSize: 18
        anchors.bottom: error_color_minimum.top
        anchors.horizontalCenter: error_color_minimum.horizontalCenter
    }
    TextField {
        id: error_color_minimum
        anchors.right: _errorBlank.left
        anchors.verticalCenter: _errorScaleCenter.verticalCenter
        anchors.verticalCenterOffset: -_errorScaleTop.width / 2
        anchors.rightMargin: _errorScaleTop.width / 2
        placeholderText: qsTr("")
        text: ""
        //validator: IntValidator {bottom: 0; top: 99;}
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
                    implicitWidth: error_color_minimum.width
                    implicitHeight: error_color_minimum.height
            }
       }

    }
    ColorDialog {
        id: error_colorDialog_min
        visible: false
        title: "Please choose a color for the minimum"
        color: minColor
        onAccepted: {
            minColor = error_colorDialog_min.color
        }
    }
    Button{
        id: error_color_minimumButton
        width: error_color_minimum.width / 1.875
        height: width
        Rectangle{
            color: minColor
            border.color: 'white'
            border.width: 1
            implicitWidth: error_color_minimumButton.width
            implicitHeight: error_color_minimumButton.height
        }


        anchors.right: error_color_minimum.left
        anchors.rightMargin: _errorScaleTop.width / 2
        anchors.verticalCenter: error_color_minimum.verticalCenter
        onClicked: {
            error_colorDialog_min.visible = true
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


        anchors.horizontalCenter: _errorBlank.horizontalCenter
        anchors.top: _errorBlank.bottom
        anchors.topMargin: _errorScaleTop.width / 2
        onClicked: {
            updated = true
            error_color_maximum.text = ''
            error_color_medium.text = ''
            error_color_minimum.text = ''
            paramController.changeColor('color_error_min', minColor)
            paramController.changeColor('color_error_med', midColor)
            paramController.changeColor('color_error_max', maxColor)

            if(minValue > 0){
                getMin(minValue)
            }
            if(midValue > 0){
                getMed(midValue)
            }
            if(maxValue > 0){
                getMax(maxValue)
            }
            balanceErrorBar()
            minChanged = false;
            medChanged = false;
            maxChanged = false;
        }
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
        anchors.verticalCenter: error_color_minimum_text.verticalCenter
        anchors.left: _errorCurrent.right
        anchors.leftMargin: _errorCurrent.height
        onClicked: {
            updated = true
            paramController.changeColor('color_error_min', 'green')
            paramController.changeColor('color_error_med', 'yellow')
            paramController.changeColor('color_error_max', 'red')
            paramController.changeValue("Rerror_color_maximum", 5)
            paramController.changeValue("Rerror_color_medium", 3.5)
            paramController.changeValue("Rerror_color_minimum", 1)
            minColor = 'green'
            midColor = 'yellow'
            maxColor = 'red'
        }
    }
}

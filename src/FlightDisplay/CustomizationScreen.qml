/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

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



TableView {
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
        x: Screen.width / 2.75
        text: "Customization Settings"
        color: 'black'
        font.pixelSize: 30
        font.bold: true
        verticalAlignment: Text.AlignVCenter
    }

    /// Default color palette used throughout the UI
    QGCPalette { id: qgcPal; colorGroupEnabled: true }
    Column{
        id: columnSections
        spacing:                ScreenTools.defaultFontPixelHeight * 2
        x: Screen.width * .025
        y: Screen.height * .075
        z: 2
        Row {
            id: sectionsTitle
            Repeater {
                model: tableView.columns > 0 ? tableView.columns : 1
                Label {
                    height: 35
                    text: "<b>Error Display</b>"
                    color: 'black'
                    font.pixelSize: 20
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
        Row {
            id: errorSection
            Repeater {
                model: tableView.columns > 0 ? tableView.columns : 1
                Label {
                    height: 35
                    CheckBox{
                        id: errorB
                        checked: getTruth(paramController.getValue('error'))
                        text: "Error Display"
                        width: _textEditWidth / 1.5
                        onClicked: {
                            paramController.changeValue('error', getValue(paramController.getValue('error')))
                        }
                    }
                    color: 'black'
                    font.pixelSize: 8
                    padding: 10
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
        Row {
            Repeater {
                model: tableView.columns > 0 ? tableView.columns : 1
                Label {
                    height: 35
                    TextField {
                        id: _error
                        placeholderText: qsTr("Error bar range(0-100): ")
                        width: _textEditWidth
                    }
                    Button{
                        id: _errorButton
                        text: "confirm"
                        width: _textEditWidth / 3
                        anchors.left: _error.right
                        onClicked: {
                            paramController.changeValue("error_range", _error.getText(0,_error.length))
                        }
                    }
                    color: 'black'
                    font.pixelSize: 8
                    padding: 10
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
        Row {
            Repeater {
                model: tableView.columns > 0 ? tableView.columns : 1
                Label {
                    height: 35
                    TextField {
                        id: error_color_minimum
                        placeholderText: qsTr("Error color bar minimum(0-100)")
                        width: _textEditWidth
                    }
                    Button{
                        id: error_color_minimumButton
                        text: "confirm"
                        width: _textEditWidth / 3
                        anchors.left: error_color_minimum.right
                        onClicked: {
                            paramController.changeValue("error_color_minimum", error_color_minimum.getText(0,error_color_minimumButton.length))
                        }
                    }
                    color: 'black'
                    font.pixelSize: 8
                    padding: 10
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }


        Row {
            Repeater {
                model: tableView.columns > 0 ? tableView.columns : 1
                Label {
                    height: 35
                    TextField {
                        id: error_color_medium_min
                        placeholderText: qsTr("Error color bar medium(0-100)")
                        width: _textEditWidth
                    }
                    Button{
                        id: error_color_mediumButton_min
                        text: "confirm"
                        width: _textEditWidth / 3
                        anchors.left: error_color_medium_min.right
                        onClicked: {
                            paramController.changeValue("error_color_medium", error_color_medium_min.getText(0,error_color_mediumButton_min.length))
                        }
                    }
                    color: 'black'
                    font.pixelSize: 8
                    padding: 10
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }


        Row {
            Repeater {
                model: tableView.columns > 0 ? tableView.columns : 1
                Label {
                    height: 35
                    TextField {
                        id: error_color_medium_max
                        placeholderText: qsTr("Error color bar maximum(0-100)")
                        width: _textEditWidth
                    }
                    Button{
                        id: error_color_mediumButton_max
                        text: "confirm"
                        width: _textEditWidth / 3
                        anchors.left: error_color_medium_max.right
                        onClicked: {
                            paramController.changeValue("error_color_maximum", error_color_medium_max.getText(0,error_color_mediumButton_max.length))
                        }
                    }
                    color: 'black'
                    font.pixelSize: 8
                    padding: 10
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
        Row {
            id: error_color_min
            Repeater {
                model: tableView.columns > 0 ? tableView.columns : 1
                Label {
                    height: 35
                    ColorDialog {
                        id: error_colorDialog_min
                        visible: false
                        title: "Please choose a color for the minimum"
                        onAccepted: {
                            paramController.changeColor('color_error_min', (error_colorDialog_min.color))
                        }
                    }
                    Button{
                        id: error_min_color_button
                        text: "Change minimum color"
                        width: 4/3 * _textEditWidth
                        onClicked: {
                            error_colorDialog_min.visible = true
                        }
                    }
                    color: 'black'
                    font.pixelSize: 15
                    padding: 10
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
        Row {
            id: error_color_med
            Repeater {
                model: tableView.columns > 0 ? tableView.columns : 1
                Label {
                    height: 35
                    ColorDialog {
                        id: error_colorDialog_med
                        visible: false
                        title: "Please choose a color for the medium"
                        onAccepted: {
                            paramController.changeColor('color_error_med', (error_colorDialog_med.color))
                        }
                    }
                    Button{
                        id: error_med_color_button
                        text: "Change medium color"
                        width: 4/3 * _textEditWidth
                        onClicked: {
                            error_colorDialog_med.visible = true
                        }
                    }
                    color: 'black'
                    font.pixelSize: 8
                    padding: 10
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
        Row {
            id: error_color_max
            Repeater {
                model: tableView.columns > 0 ? tableView.columns : 1
                Label {
                    height: 35
                    ColorDialog {
                        id: error_colorDialog_max
                        visible: false
                        title: "Please choose a color for the maximum"
                        onAccepted: {
                            paramController.changeColor('color_error_max', (error_colorDialog_max.color))
                        }
                    }
                    Button{
                        id: error_max_color_button
                        text: "Change maximum color"
                        width: 4/3 * _textEditWidth
                        onClicked: {
                            error_colorDialog_max.visible = true
                        }
                    }
                    color: 'black'
                    font.pixelSize: 8
                    padding: 10
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
    }
    Column{
        id: columnValue
        spacing:                ScreenTools.defaultFontPixelHeight * 2
        x: Screen.width * .2
        y: Screen.height * .075
        z: 2
        Row {
            id: valuesTitle
            Repeater {
                model: tableView.columns > 0 ? tableView.columns : 1
                Label {
                    height: 35
                    text: "<b>Drone</b>"
                    color: 'black'
                    font.pixelSize: 20
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
        Row {
            id: droneSection
            Repeater {
                model: tableView.columns > 0 ? tableView.columns : 1
                Label {
                    height: 35
                    CheckBox{
                        id: droneB
                        checked: getTruth(paramController.getValue('drone'))
                        text: "Drone Display"
                        width: _textEditWidth / 1.5
                        onClicked: {
                            paramController.changeValue('drone', getValue(paramController.getValue('drone')))
                        }
                    }
                    color: 'black'
                    font.pixelSize: 8
                    padding: 10
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
        Row {
            Repeater {
                model: tableView.columns > 0 ? tableView.columns : 1
                Label {
                    height: 35
                    TextField {
                        id: _color_minimum
                        placeholderText: qsTr("RPM Color bar minimum(0-100)")
                        width: _textEditWidth
                    }
                    Button{
                        id: _color_minimumButton
                        text: "confirm"
                        width: _textEditWidth / 3
                        anchors.left: _color_minimum.right
                        onClicked: {
                            paramController.changeValue("RPM_color_low_min", _color_minimum.getText(0, _color_minimumButton.length))
                        }
                    }
                    color: 'black'
                    font.pixelSize: 8
                    padding: 10
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }

        Row {
            Repeater {
                model: tableView.columns > 0 ? tableView.columns : 1
                Label {
                    height: 35
                    TextField {
                        id: _color_medium_min
                        placeholderText: qsTr("RPM Color bar medium minimum(0-100)")
                        width: _textEditWidth
                    }
                    Button{
                        id: _color_mediumButton_min
                        text: "confirm"
                        width: _textEditWidth / 3
                        anchors.left: _color_medium_min.right
                        onClicked: {
                            paramController.changeValue("RPM_color_low_max", _color_medium_min.getText(0, _color_mediumButton_min.length))
                        }
                    }
                    color: 'black'
                    font.pixelSize: 8
                    padding: 10
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
        Row {
            Repeater {
                model: tableView.columns > 0 ? tableView.columns : 1
                Label {
                    height: 35
                    TextField {
                        id: _color_medium_max
                        placeholderText: qsTr("RPM Color bar medium minimum(0-100)")
                        width: _textEditWidth
                    }
                    Button{
                        id: _color_mediumButton_max
                        text: "confirm"
                        width: _textEditWidth / 3
                        anchors.left: _color_medium_max.right
                        onClicked: {
                            paramController.changeValue("RPM_color_mid_max", _color_medium_max.getText(0, _color_mediumButton_max.length))
                        }
                    }
                    color: 'black'
                    font.pixelSize: 8
                    padding: 10
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }

        Row {
            Repeater {
                model: tableView.columns > 0 ? tableView.columns : 1
                Label {
                    height: 35
                    TextField {
                        id: _color_maximum
                        placeholderText: qsTr("RPM Color bar maximum(0-100)")
                        width: _textEditWidth
                    }
                    Button{
                        id: _color_maximumButton
                        text: "confirm"
                        width: _textEditWidth / 3
                        anchors.left: _color_maximum.right
                        onClicked: {
                            paramController.changeValue("RPM_color_high_max", _color_maximum.getText(0, _color_maximumButton.length))
                        }
                    }
                    color: 'black'
                    font.pixelSize: 8
                    padding: 10
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
        Row {
            id: rpm_color_min
            Repeater {
                model: tableView.columns > 0 ? tableView.columns : 1
                Label {
                    height: 35
                    ColorDialog {
                        id: rpm_colorDialog_min
                        visible: false
                        title: "Please choose a color for the minimum"
                        onAccepted: {
                            paramController.changeColor('color_rpm_min', rpm_colorDialog_min.color)
                        }
                    }
                    Button{
                        id: rpm_min_color_button
                        text: "Change minimum color"
                        width: 4/3 * _textEditWidth
                        onClicked: {
                            rpm_colorDialog_min.visible = true
                        }
                    }
                    color: 'black'
                    font.pixelSize: 8
                    padding: 10
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
        Row {
            id: rpm_color_med
            Repeater {
                model: tableView.columns > 0 ? tableView.columns : 1
                Label {
                    height: 35
                    ColorDialog {
                        id: rpm_colorDialog_med
                        visible: false
                        title: "Please choose a color for the medium"
                        onAccepted: {
                            paramController.changeColor('color_rpm_med', (rpm_colorDialog_med.color))
                        }
                    }
                    Button{
                        id: rpm_med_color_button
                        text: "Change medium color"
                        width: 4/3 * _textEditWidth
                        height: parent.height - 8
                        onClicked: {
                            rpm_colorDialog_med.visible = true
                        }
                    }
                    color: 'black'
                    font.pixelSize: 8
                    padding: 10
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
        Row {
            id: rpm_color_max
            Repeater {
                model: tableView.columns > 0 ? tableView.columns : 1
                Label {
                    height: 35
                    ColorDialog {
                        id: rpm_colorDialog_max
                        visible: false
                        title: "Please choose a color for the maximum"
                        onAccepted: {
                            paramController.changeColor('color_rpm_max', (rpm_colorDialog_max.color))
                        }
                    }
                    Button{
                        id: rpm_max_color_button
                        text: "Change maximum color"
                        width: 4/3 * _textEditWidth
                        onClicked: {
                            rpm_colorDialog_max.visible = true
                        }
                    }
                    color: 'black'
                    font.pixelSize: 8
                    padding: 10
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
    }
    Column{
        id: columnColors
        spacing:                ScreenTools.defaultFontPixelHeight * 2
        x: Screen.width * .4
        y: Screen.height * .075
        z: 2
        Row {
            id: colorsTitle
            Repeater {
                model: tableView.columns > 0 ? tableView.columns : 1
                Label {
                    height: 35
                    text: "<b>Battery</b>"
                    color: 'black'
                    font.pixelSize: 20
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
        Row {
            id: batterySection
            Repeater {
                model: tableView.columns > 0 ? tableView.columns : 1
                Label {
                    height: 35
                    CheckBox{
                        id: batteryB
                        checked: getTruth(paramController.getValue('battery'))
                        text: "Battery Display"
                        width: _textEditWidth / 1.5
                        onClicked: {
                            paramController.changeValue('battery', getValue(paramController.getValue('battery')))
                        }
                    }
                    color: 'black'
                    font.pixelSize: 8
                    padding: 10
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
        Row {
            Repeater {
                model: tableView.columns > 0 ? tableView.columns : 1
                Label {
                    height: 35
                    ColorDialog {
                        id: batteryMin
                        visible: false
                        title: "Please choose a color for the minimum"
                        onAccepted: {
                            paramController.changeColor('color_batt_min', (batteryMin.color))
                        }
                    }
                    Button{
                        id: battMinButton
                        text: "Change minimum color"
                        width: 4/3 * _textEditWidth
                        onClicked: {
                            batteryMin.visible = true
                        }
                    }
                    color: 'black'
                    font.pixelSize: 8
                    padding: 10
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
        Row {
            Repeater {
                model: tableView.columns > 0 ? tableView.columns : 1
                Label {
                    height: 35
                    ColorDialog {
                        id: batteryMed
                        visible: false
                        title: "Please choose a color for the medium"
                        onAccepted: {
                            paramController.changeColor('color_batt_med', (batteryMed.color))
                        }
                    }
                    Button{
                        id: battMedButton
                        text: "Change medium color"
                        width: 4/3 * _textEditWidth
                        onClicked: {
                            batteryMed.visible = true
                        }
                    }
                    color: 'black'
                    font.pixelSize: 8
                    padding: 10
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
        Row {
            Repeater {
                model: tableView.columns > 0 ? tableView.columns : 1
                Label {
                    height: 35
                    ColorDialog {
                        id: batteryMax
                        visible: false
                        title: "Please choose a color for the maximum"
                        onAccepted: {
                            paramController.changeColor('color_batt_max', (batteryMax.color))
                        }
                    }
                    Button{
                        id: battMaxButton
                        text: "Change maximum color"
                        width: 4/3 * _textEditWidth
                        onClicked: {
                            batteryMax.visible = true
                        }
                    }
                    color: 'black'
                    font.pixelSize: 8
                    padding: 10
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
    }
    Column{
        id: buttons
        spacing:                ScreenTools.defaultFontPixelHeight * 2
        x: Screen.width * .6
        y: Screen.height * .075
        z: 2
        Row {
            id: buttonsTitle
            Repeater {
                model: tableView.columns > 0 ? tableView.columns : 1
                Label {
                    height: 35
                    text: "<b>Buttons</b>"
                    color: 'black'
                    font.pixelSize: 20
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
        Row {
            id: buttonsSection
            Repeater {
                model: tableView.columns > 0 ? tableView.columns : 1
                Label {
                    height: 35
                    CheckBox{
                        id: buttonsB
                        checked: getTruth(paramController.getValue('buttons'))
                        text: "Buttons Display"
                        width: _textEditWidth / 1.5
                        onClicked: {
                            paramController.changeValue('buttons', getValue(paramController.getValue('buttons')))
                        }
                    }
                    color: 'black'
                    font.pixelSize: 8
                    padding: 10
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
    }
    Column{
        id: windDisp
        spacing:                ScreenTools.defaultFontPixelHeight * 2
        x: Screen.width * .8
        y: Screen.height * .075
        z: 2
        Row {
            id: windTitle
            Repeater {
                model: tableView.columns > 0 ? tableView.columns : 1
                Label {
                    height: 35
                    text: "<b>Wind Display</b>"
                    color: 'black'
                    font.pixelSize: 20
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
        Row {
            id: windSection
            Repeater {
                model: tableView.columns > 0 ? tableView.columns : 1
                Label {
                    height: 35
                    CheckBox{
                        id: windB
                        checked: getTruth(paramController.getValue('windDisplay'))
                        text: "Wind Display"
                        width: _textEditWidth / 1.5
                        onClicked: {
                            paramController.changeValue('windDisplay', getValue(paramController.getValue('windDisplay')))
                        }
                    }
                    color: 'black'
                    font.pixelSize: 8
                    padding: 10
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
    }
}

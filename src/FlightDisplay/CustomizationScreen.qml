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


    ParameterEditorController{
        id:
            paramController
    }
    Text {
        id: _title
        x: width
        text: "Customization Settings"
        color: 'black'
        font.pixelSize: 40
        font.bold: true
        verticalAlignment: Text.AlignVCenter
    }
    /// Default color palette used throughout the UI
    QGCPalette { id: qgcPal; colorGroupEnabled: true }
    Column{
        id: columnHeader
        spacing:                ScreenTools.defaultFontPixelHeight * 2
        x: 200
        y: 100
        z: 2
        Row {
            id: rowOneHeader
            Repeater {
                model: tableView.columns > 0 ? tableView.columns : 1
                Label {
                    height: 35
                    text: "Enter value for error bar range(0-100): "
                    color: 'black'
                    font.pixelSize: 15
                    padding: 10
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
        Row {
            id: rowTwoHeader
            Repeater {
                model: tableView.columns > 0 ? tableView.columns : 1
                Label {
                    height: 35
                    text: "Enter value for RPM color bar minimum(0-100): "
                    color: 'black'
                    font.pixelSize: 15
                    padding: 10
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
        Row {
            id: rowThreeHeader
            Repeater {
                model: tableView.columns > 0 ? tableView.columns : 1
                Label {
                    height: 35
                    text: "Enter value for RPM color bar medium minimum(0-100): "
                    color: 'black'
                    font.pixelSize: 15
                    padding: 10
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
        Row {
            id: rowFourHeader
            Repeater {
                model: tableView.columns > 0 ? tableView.columns : 1
                Label {
                    height: 35
                    text: "Enter value for RPM color bar medium maximum(0-100): "
                    color: 'black'
                    font.pixelSize: 15
                    padding: 10
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
        Row {
            id: rowFiveHeader
            Repeater {
                model: tableView.columns > 0 ? tableView.columns : 1
                Label {
                    height: 35
                    text: "Enter value for RPM color bar maximum(0-100): "
                    color: 'black'
                    font.pixelSize: 15
                    padding: 10
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
        Row {
            id: rowSixHeader
            Repeater {
                model: tableView.columns > 0 ? tableView.columns : 1
                Label {
                    height: 35
                    text: "Enter value for error color bar minimum(0-100): "
                    color: 'black'
                    font.pixelSize: 15
                    padding: 10
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
        Row {
            id: rowSevenHeader
            Repeater {
                model: tableView.columns > 0 ? tableView.columns : 1
                Label {
                    height: 35
                    text: "Enter value for error color bar medium(0-100): "
                    color: 'black'
                    font.pixelSize: 15
                    padding: 10
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
        Row {
            id: rowEightHeader
            Repeater {
                model: tableView.columns > 0 ? tableView.columns : 1
                Label {
                    height: 35
                    text: "Enter value for error color bar maximum(0-100): "
                    color: 'black'
                    font.pixelSize: 15
                    padding: 10
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
    }
    Column{
        id: columnValue
        spacing:                ScreenTools.defaultFontPixelHeight * 2
        anchors.left: columnHeader.right
        y: 105
        z: 2
        Row {
            id: rowOne

            Repeater {
                model: tableView.columns > 0 ? tableView.columns : 1
                Label {
                    height: 35
                    TextField {
                        id: _error
                        placeholderText: qsTr("Error Bar Value")
                        width: _textEditWidth
                    }
                    Button{
                        id: _errorButton
                        text: "change value"
                        width: _textEditWidth / 2
                        anchors.left: _error.right
                        onClicked: {
                            paramController.changeValue("error_range", _error.getText(0,_error.length))
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
            id: rowTwo
            Repeater {
                model: tableView.columns > 0 ? tableView.columns : 1
                Label {
                    height: 35
                    TextField {
                        id: _color_minimum
                        placeholderText: qsTr("RPM Color change minimum")
                        width: _textEditWidth
                    }
                    Button{
                        id: _color_minimumButton
                        text: "change value"
                        width: _textEditWidth / 2
                        anchors.left: _color_minimum.right
                        onClicked: {
                            paramController.changeValue("RPM_color_low_min", _color_minimum.getText(0, _color_minimumButton.length))
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
            id: rowThree
            Repeater {
                model: tableView.columns > 0 ? tableView.columns : 1
                Label {
                    height: 35
                    TextField {
                        id: _color_medium_min
                        placeholderText: qsTr("RPM Color change medium minimum")
                        width: _textEditWidth
                    }
                    Button{
                        id: _color_mediumButton_min
                        text: "change value"
                        width: _textEditWidth / 2
                        anchors.left: _color_medium_min.right
                        onClicked: {
                            paramController.changeValue("RPM_color_low_max", _color_medium_min.getText(0, _color_mediumButton_min.length))
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
            id: rowFour
            Repeater {
                model: tableView.columns > 0 ? tableView.columns : 1
                Label {
                    height: 35
                    TextField {
                        id: _color_medium_max
                        placeholderText: qsTr("RPM Color change medium minimum")
                        width: _textEditWidth
                    }
                    Button{
                        id: _color_mediumButton_max
                        text: "change value"
                        width: _textEditWidth / 2
                        anchors.left: _color_medium_max.right
                        onClicked: {
                            paramController.changeValue("RPM_color_mid_max", _color_medium_max.getText(0, _color_mediumButton_max.length))
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
            id: rowFive
            Repeater {
                model: tableView.columns > 0 ? tableView.columns : 1
                Label {
                    height: 35
                    TextField {
                        id: _color_maximum
                        placeholderText: qsTr("RPM Color change maximum")
                        width: _textEditWidth
                    }
                    Button{
                        id: _color_maximumButton
                        text: "change value"
                        width: _textEditWidth / 2
                        anchors.left: _color_maximum.right
                        onClicked: {
                            paramController.changeValue("RPM_color_high_max", _color_maximum.getText(0, _color_maximumButton.length))
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
            id: rowSix
            Repeater {
                model: tableView.columns > 0 ? tableView.columns : 1
                Label {
                    height: 35
                    TextField {
                        id: error_color_minimum
                        placeholderText: qsTr("Error Color change minimum")
                        width: _textEditWidth
                    }
                    Button{
                        id: error_color_minimumButton
                        text: "change value"
                        width: _textEditWidth / 2
                        anchors.left: error_color_minimum.right
                        onClicked: {
                            paramController.changeValue("error_color_minimum", error_color_minimum.getText(0,error_color_minimumButton.length))
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
            id: rowSeven
            Repeater {
                model: tableView.columns > 0 ? tableView.columns : 1
                Label {
                    height: 35
                    TextField {
                        id: error_color_medium_min
                        placeholderText: qsTr("Error Color change medium")
                        width: _textEditWidth
                    }
                    Button{
                        id: error_color_mediumButton_min
                        text: "change value"
                        width: _textEditWidth / 2
                        anchors.left: error_color_medium_min.right
                        onClicked: {
                            paramController.changeValue("error_color_medium", error_color_medium_min.getText(0,error_color_mediumButton_min.length))
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
            id: rowEight
            Repeater {
                model: tableView.columns > 0 ? tableView.columns : 1
                Label {
                    height: 35
                    TextField {
                        id: error_color_medium_max
                        placeholderText: qsTr("Error Color change maximum")
                        width: _textEditWidth
                    }
                    Button{
                        id: error_color_mediumButton_max
                        text: "change value"
                        width: _textEditWidth / 2
                        anchors.left: error_color_medium_max.right
                        onClicked: {
                            paramController.changeValue("error_color_maximum", error_color_medium_max.getText(0,error_color_mediumButton_max.length))
                        }
                    }
                    color: 'black'
                    font.pixelSize: 15
                    padding: 10
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
    }
    Column{
        id: columnColors
        spacing:                ScreenTools.defaultFontPixelHeight * 2
        x: 1000
        y: 105
        z: 2
        Row {
            id: dead_1
            Repeater {
                model: tableView.columns > 0 ? tableView.columns : 1
                Label {
                    height: 35
                    color: 'black'
                    font.pixelSize: 15
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
                        width: _textEditWidth
                        onClicked: {
                            rpm_colorDialog_min.visible = true
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
            id: rpm_color_med
            Repeater {
                model: tableView.columns > 0 ? tableView.columns : 1
                Label {
                    height: 70 + ScreenTools.defaultFontPixelHeight * 2
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
                        width: _textEditWidth
                        height: parent.height - 8
                        onClicked: {
                            rpm_colorDialog_med.visible = true
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
                        width: _textEditWidth
                        onClicked: {
                            rpm_colorDialog_max.visible = true
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
                        width: _textEditWidth
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
                        width: _textEditWidth
                        onClicked: {
                            error_colorDialog_med.visible = true
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
                        width: _textEditWidth
                        onClicked: {
                            error_colorDialog_max.visible = true
                        }
                    }
                    color: 'black'
                    font.pixelSize: 15
                    padding: 10
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
    }
}

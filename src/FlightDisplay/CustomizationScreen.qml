
import QtQuick          2.3
import QtQuick.Controls 1.2
import QtQuick.Layouts  1.2

import QGroundControl                       1.0
import QGroundControl.AutoPilotPlugin       1.0
import QGroundControl.Palette               1.0
import QGroundControl.Controls              1.0
import QGroundControl.ScreenTools           1.0
import QGroundControl.MultiVehicleManager   1.0


import QtQuick.Dialogs  1.2
import QtQuick.Controls.Material 2.0

import QGroundControl.FactSystem    1.0
import QGroundControl.FactControls  1.0
import QGroundControl.Controllers   1.0
import QGroundControl.PX4           1.0
import Qt.labs.qmlmodels 1.0
import QtQuick.Window 2.0


Rectangle {
    id:     setupView
    color:  qgcPal.window
    z:      QGroundControl.zOrderTopMost

    QGCPalette { id: qgcPal; colorGroupEnabled: true }
    ParameterEditorController{
        id:
            paramController
    }
    ExclusiveGroup { id: setupButtonGroup }

    readonly property real      _defaultTextHeight: ScreenTools.defaultFontPixelHeight
    readonly property real      _defaultTextWidth:  ScreenTools.defaultFontPixelWidth
    readonly property real      _horizontalMargin:  _defaultTextWidth / 2
    readonly property real      _verticalMargin:    _defaultTextHeight / 2
    readonly property real      _buttonWidth:       _defaultTextWidth * 18
    readonly property string    _armedVehicleText:  qsTr("This operation cannot be performed while the vehicle is armed.")

    property bool   _vehicleArmed:                  QGroundControl.multiVehicleManager.activeVehicle ? QGroundControl.multiVehicleManager.activeVehicle.armed : false
    property string _messagePanelText:              qsTr("missing message panel text")
    property bool   _fullParameterVehicleAvailable: QGroundControl.multiVehicleManager.parameterReadyVehicleAvailable && !QGroundControl.multiVehicleManager.activeVehicle.parameterManager.missingParameters
    property var    _corePlugin:                    QGroundControl.corePlugin
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
    function showErrorPanel() {
        if (mainWindow.preventViewSwitch()) {
            return
        }
        _showErrorPanel()
    }

    function _showErrorPanel() {
        panelLoader.setSource("errorDisplaySettings.qml")
        errorButton.checked = true
    }
    function showRpmPanel() {
        if (mainWindow.preventViewSwitch()) {
            return
        }
        _showRpmPanel()
    }

    function _showRpmPanel() {
        panelLoader.setSource("rpmDisplaySettings.qml")
        rpmButton.checked = true
    }
    function showBattPanel() {
        if (mainWindow.preventViewSwitch()) {
            return
        }
        _showBattPanel()
    }

    function _showBattPanel() {
        panelLoader.setSource("battDisplaySettings.qml")
        battButton.checked = true
    }
    function showPanel(button, qmlSource) {
        if (mainWindow.preventViewSwitch()) {
            return
        }
        button.checked = true
        panelLoader.setSource(qmlSource)
    }

    Component.onCompleted: _showErrorPanel()

    Connections {
        target: QGroundControl.corePlugin
        onShowAdvancedUIChanged: {
            if(!QGroundControl.corePlugin.showAdvancedUI) {
                _showErrorPanel()
            }
        }
    }




    Component {
        id: messagePanelComponent

        Item {
            QGCLabel {
                anchors.margins:        _defaultTextWidth * 2
                anchors.fill:           parent
                verticalAlignment:      Text.AlignVCenter
                horizontalAlignment:    Text.AlignHCenter
                wrapMode:               Text.WordWrap
                font.pointSize:         ScreenTools.mediumFontPointSize
                text:                   _messagePanelText
            }
        }
    }

    QGCFlickable {
        id:                 buttonScroll
        width:              buttonColumn.width
        anchors.topMargin:  _defaultTextHeight / 2
        anchors.top:        parent.top
        anchors.bottom:     parent.bottom
        anchors.leftMargin: _horizontalMargin
        anchors.left:       parent.left
        contentHeight:      buttonColumn.height
        flickableDirection: Flickable.VerticalFlick
        clip:               true

        ColumnLayout {
            id:         buttonColumn
            spacing:    _defaultTextHeight / 2
            width: 175
            Repeater {
                model:                  _corePlugin ? _corePlugin.settingsPages : []
                visible:                _corePlugin && _corePlugin.options.combineSettingsAndSetup
                SubMenuButton {
                    imageResource:      modelData.icon
                    setupIndicator:     false
                    exclusiveGroup:     setupButtonGroup
                    text:               modelData.title
                    visible:            _corePlugin && _corePlugin.options.combineSettingsAndSetup
                    onClicked:          showPanel(this, modelData.url)
                    Layout.fillWidth:   true
                }
            }

            SubMenuButton {
                id:                 errorButton
                //imageResource: "/qmlimages/errorDisplay.png"
                setupIndicator:     false
                checked:            false
                exclusiveGroup:     setupButtonGroup

                text: qsTr("Error Bars")
                Layout.fillWidth:   true
                onClicked: showErrorPanel()
//                Image {
//                    z: 1000
//                    width: parent.img.width
//                    height: parent.img.height
//                    source: "/qmlimages/errorDisplay.png"
//                    anchors.verticalCenter: parent.verticalCenter
//                    anchors.horizontalCenter: parent.horizontalCenter
//                }
                CheckBox{
                    id: errorB
                    checked: getTruth(paramController.getValue('error'))
                    width: 20
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    onClicked: {
                        paramController.changeValue('error', getValue(paramController.getValue('error')))
                    }
                }
            }
            SubMenuButton {
                id:                 rpmButton
                //imageResource: "/qmlimages/errorDisplay.png"
                setupIndicator:     false
                checked:            false
                exclusiveGroup:     setupButtonGroup

                text: qsTr("Drone\nTop View")
                Layout.fillWidth:   true
                onClicked: showRpmPanel()
                CheckBox{
                    id: rpmB
                    checked: getTruth(paramController.getValue('drone'))
                    width: 20
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    onClicked: {
                        paramController.changeValue('drone', getValue(paramController.getValue('drone')))
                    }
                }
            }
            SubMenuButton {
                id:                 battButton
                //imageResource: "/qmlimages/errorDisplay.png"
                setupIndicator:     false
                checked:            false
                exclusiveGroup:     setupButtonGroup

                text: qsTr("Battery")
                Layout.fillWidth:   true
                onClicked: showBattPanel()
                CheckBox{
                    id: battB
                    checked: getTruth(paramController.getValue('battery'))
                    width: 20
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    onClicked: {
                        paramController.changeValue('battery', getValue(paramController.getValue('battery')))
                    }
                }
            }
            SubMenuButton {
                id:                 buttButton
                //imageResource: "/qmlimages/errorDisplay.png"
                setupIndicator:     false
                checked:            false
                exclusiveGroup:     setupButtonGroup

                text: qsTr("Mode\nButtons")
                Layout.fillWidth:   true
                //onClicked: showButtPanel()
                CheckBox{
                    id: buttB
                    checked: getTruth(paramController.getValue('buttons'))
                    width: 20
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    onClicked: {
                        paramController.changeValue('buttons', getValue(paramController.getValue('buttons')))
                    }
                }
            }
            SubMenuButton {
                id:                 woutButton
                //imageResource: "/qmlimages/errorDisplay.png"
                setupIndicator:     false
                checked:            false
                exclusiveGroup:     setupButtonGroup

                text: qsTr("Wout Display")
                Layout.fillWidth:   true
                //onClicked: showButtPanel()
                CheckBox{
                    id: woutB
                    checked: getTruth(paramController.getValue('wout'))
                    width: 20
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    onClicked: {
                        paramController.changeValue('wout', getValue(paramController.getValue('wout')))
                    }
                }
            }
            SubMenuButton {
                id:                 windButton
                //imageResource: "/qmlimages/errorDisplay.png"
                setupIndicator:     false
                checked:            false
                exclusiveGroup:     setupButtonGroup

                text: qsTr("Vector\nArrows")
                Layout.fillWidth:   true
                //onClicked: showButtPanel()
                CheckBox{
                    id: windB
                    checked: getTruth(paramController.getValue('windDisplay'))
                    width: 20
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    onClicked: {
                        paramController.changeValue('windDisplay', getValue(paramController.getValue('windDisplay')))
                    }
                }
            }
        }
    }

    Rectangle {
        id:                     divider
        anchors.topMargin:      _verticalMargin
        anchors.bottomMargin:   _verticalMargin
        anchors.leftMargin:     _horizontalMargin
        anchors.left:           buttonScroll.right
        anchors.top:            parent.top
        anchors.bottom:         parent.bottom
        width:                  1
        color:                  qgcPal.windowShade
    }

    Loader {
        id:                     panelLoader
        anchors.topMargin:      _verticalMargin
        anchors.bottomMargin:   _verticalMargin
        anchors.leftMargin:     _horizontalMargin
        anchors.rightMargin:    _horizontalMargin
        anchors.left:           divider.right
        anchors.right:          parent.right
        anchors.top:            parent.top
        anchors.bottom:         parent.bottom

        function setSource(source, vehicleComponent) {
            panelLoader.source = ""
            panelLoader.vehicleComponent = vehicleComponent
            panelLoader.source = source
        }

        function setSourceComponent(sourceComponent, vehicleComponent) {
            panelLoader.sourceComponent = undefined
            panelLoader.vehicleComponent = vehicleComponent
            panelLoader.sourceComponent = sourceComponent
        }

        property var vehicleComponent
    }
}

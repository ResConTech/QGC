/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

import QtQuick                      2.11
import QtQuick.Controls             2.4
import QtQuick.Layouts              1.11
import QtLocation                   5.3
import QtPositioning                5.3
import QtQuick.Dialogs              1.2
import QtQuick.Window               2.2
import QtCharts                     2.3

import QGroundControl               1.0
import QGroundControl.Airspace      1.0
import QGroundControl.Controllers   1.0
import QGroundControl.Controls      1.0
import QGroundControl.FactSystem    1.0
import QGroundControl.FlightDisplay 1.0
import QGroundControl.FlightMap     1.0
import QGroundControl.Palette       1.0
import QGroundControl.ScreenTools   1.0
import QGroundControl.Vehicle       1.0

import QtQuick.Controls.Styles 1.4
FlightMap {
    id:                         _root

    property var    curSystem:          controller ? controller.activeSystem : null
    property var    curMessage:         curSystem && curSystem.messages.count ? curSystem.messages.get(curSystem.selected) : null
    property int    curCompID:          0
    property real   maxButtonWidth:     0
    //variable to keep track of rc/pid state
    property int rc_or_pid:1
    property int train:0
    //use parameter editor controller
    ParameterEditorController{
        id: paramController
    }
    //
    MAVLinkInspectorController {
        id: controller
    }

    FactPanelController {
        id:             factController
    }

    allowGCSLocationCenter:     true
    allowVehicleLocationCenter: !_keepVehicleCentered
    planView:                   false
    zoomLevel:                  QGroundControl.flightMapZoom
    center:                     QGroundControl.flightMapPosition

    property Item pipState: _pipState
    QGCPipState {
        id:         _pipState
        pipOverlay: _pipOverlay
        isDark:     _isFullWindowItemDark
    }

    property var    rightPanelWidth
    property var    planMasterController
    property bool   pipMode:                    false   // true: map is shown in a small pip mode
    property var    toolInsets                          // Insets for the center viewport area

    property var    _activeVehicle:             QGroundControl.multiVehicleManager.activeVehicle
    property var    _planMasterController:      planMasterController
    property var    _geoFenceController:        planMasterController.geoFenceController
    property var    _rallyPointController:      planMasterController.rallyPointController
    property var    _activeVehicleCoordinate:   _activeVehicle ? _activeVehicle.coordinate : QtPositioning.coordinate()
    property real   _toolButtonTopMargin:       parent.height - mainWindow.height + (ScreenTools.defaultFontPixelHeight / 2)
    property real   _toolsMargin:               ScreenTools.defaultFontPixelWidth * 0.75
    property bool   _airspaceEnabled:           QGroundControl.airmapSupported ? (QGroundControl.settingsManager.airMapSettings.enableAirMap.rawValue && QGroundControl.airspaceManager.connected): false
    property var    _flyViewSettings:           QGroundControl.settingsManager.flyViewSettings
    property bool   _keepMapCenteredOnVehicle:  _flyViewSettings.keepMapCenteredOnVehicle.rawValue

    property bool   _disableVehicleTracking:    false
    property bool   _keepVehicleCentered:       pipMode ? true : false
    property bool   _saveZoomLevelSetting:      true

    function updateAirspace(reset) {
        if(_airspaceEnabled) {
            var coordinateNW = _root.toCoordinate(Qt.point(0,0), false /* clipToViewPort */)
            var coordinateSE = _root.toCoordinate(Qt.point(width,height), false /* clipToViewPort */)
            if(coordinateNW.isValid && coordinateSE.isValid) {
                QGroundControl.airspaceManager.setROI(coordinateNW, coordinateSE, false /*planView*/, reset)
            }
        }
    }

    function _adjustMapZoomForPipMode() {
        _saveZoomLevelSetting = false
        if (pipMode) {
            if (QGroundControl.flightMapZoom > 3) {
                zoomLevel = QGroundControl.flightMapZoom - 3
            }
        } else {
            zoomLevel = QGroundControl.flightMapZoom
        }
        _saveZoomLevelSetting = true
    }

    onPipModeChanged: _adjustMapZoomForPipMode()

    onVisibleChanged: {
        if (visible) {
            // Synchronize center position with Plan View
            center = QGroundControl.flightMapPosition
        }
    }

    onZoomLevelChanged: {
        if (_saveZoomLevelSetting) {
            QGroundControl.flightMapZoom = zoomLevel
            updateAirspace(false)
        }
    }
    onCenterChanged: {
        QGroundControl.flightMapPosition = center
        updateAirspace(false)
    }

    on_AirspaceEnabledChanged: {
        updateAirspace(true)
    }

    // We track whether the user has panned or not to correctly handle automatic map positioning
    Connections {
        target: gesture

        onPanStarted:       _disableVehicleTracking = true
        onFlickStarted:     _disableVehicleTracking = true
        onPanFinished:      panRecenterTimer.restart()
        onFlickFinished:    panRecenterTimer.restart()
    }

    function pointInRect(point, rect) {
        return point.x > rect.x &&
                point.x < rect.x + rect.width &&
                point.y > rect.y &&
                point.y < rect.y + rect.height;
    }

    property real _animatedLatitudeStart
    property real _animatedLatitudeStop
    property real _animatedLongitudeStart
    property real _animatedLongitudeStop
    property real animatedLatitude
    property real animatedLongitude

    onAnimatedLatitudeChanged: _root.center = QtPositioning.coordinate(animatedLatitude, animatedLongitude)
    onAnimatedLongitudeChanged: _root.center = QtPositioning.coordinate(animatedLatitude, animatedLongitude)

    NumberAnimation on animatedLatitude { id: animateLat; from: _animatedLatitudeStart; to: _animatedLatitudeStop; duration: 1000 }
    NumberAnimation on animatedLongitude { id: animateLong; from: _animatedLongitudeStart; to: _animatedLongitudeStop; duration: 1000 }

    function animatedMapRecenter(fromCoord, toCoord) {
        _animatedLatitudeStart = fromCoord.latitude
        _animatedLongitudeStart = fromCoord.longitude
        _animatedLatitudeStop = toCoord.latitude
        _animatedLongitudeStop = toCoord.longitude
        animateLat.start()
        animateLong.start()
    }

    function _insetRect() {
        return Qt.rect(toolInsets.leftEdgeCenterInset,
                       toolInsets.topEdgeCenterInset,
                       _root.width - toolInsets.leftEdgeCenterInset - toolInsets.rightEdgeCenterInset,
                       _root.height - toolInsets.topEdgeCenterInset - toolInsets.bottomEdgeCenterInset)
    }

    function recenterNeeded() {
        var vehiclePoint = _root.fromCoordinate(_activeVehicleCoordinate, false /* clipToViewport */)
        var insetRect = _insetRect()
        return !pointInRect(vehiclePoint, insetRect)
    }

    function updateMapToVehiclePosition() {
        if (animateLat.running || animateLong.running) {
            return
        }
        // We let FlightMap handle first vehicle position
        if (!_keepMapCenteredOnVehicle && firstVehiclePositionReceived && _activeVehicleCoordinate.isValid && !_disableVehicleTracking) {
            if (_keepVehicleCentered) {
                _root.center = _activeVehicleCoordinate
            } else {
                if (firstVehiclePositionReceived && recenterNeeded()) {
                    // Move the map such that the vehicle is centered within the inset area
                    var vehiclePoint = _root.fromCoordinate(_activeVehicleCoordinate, false /* clipToViewport */)
                    var insetRect = _insetRect()
                    var centerInsetPoint = Qt.point(insetRect.x + insetRect.width / 2, insetRect.y + insetRect.height / 2)
                    var centerOffset = Qt.point((_root.width / 2) - centerInsetPoint.x, (_root.height / 2) - centerInsetPoint.y)
                    var vehicleOffsetPoint = Qt.point(vehiclePoint.x + centerOffset.x, vehiclePoint.y + centerOffset.y)
                    var vehicleOffsetCoord = _root.toCoordinate(vehicleOffsetPoint, false /* clipToViewport */)
                    animatedMapRecenter(_root.center, vehicleOffsetCoord)
                }
            }
        }
    }

    on_ActiveVehicleCoordinateChanged: {
        if (_keepMapCenteredOnVehicle && _activeVehicleCoordinate.isValid && !_disableVehicleTracking) {
            _root.center = _activeVehicleCoordinate
        }
    }

    Timer {
        id:         panRecenterTimer
        interval:   10000
        running:    false
        onTriggered: {
            _disableVehicleTracking = false
            updateMapToVehiclePosition()
        }
    }

    Timer {
        interval:       500
        running:        true
        repeat:         true
        onTriggered:    updateMapToVehiclePosition()
    }

    QGCMapPalette { id: mapPal; lightColors: isSatelliteMap }

    Connections {
        target:                 _missionController
        ignoreUnknownSignals:   true
        onNewItemsFromVehicle: {
            var visualItems = _missionController.visualItems
            if (visualItems && visualItems.count !== 1) {
                mapFitFunctions.fitMapViewportToMissionItems()
                firstVehiclePositionReceived = true
            }
        }
    }

    MapFitFunctions {
        id:                         mapFitFunctions // The name for this id cannot be changed without breaking references outside of this code. Beware!
        map:                        _root
        usePlannedHomePosition:     false
        planMasterController:       _planMasterController
    }

    // Add trajectory lines to the map
    MapPolyline {
        id:         trajectoryPolyline
        line.width: 3
        line.color: "red"
        z:          QGroundControl.zOrderTrajectoryLines
        visible:    !pipMode

        Connections {
            target:                 QGroundControl.multiVehicleManager
            onActiveVehicleChanged: trajectoryPolyline.path = _activeVehicle ? _activeVehicle.trajectoryPoints.list() : []
        }

        Connections {
            target:                 _activeVehicle ? _activeVehicle.trajectoryPoints : null
            onPointAdded:           trajectoryPolyline.addCoordinate(coordinate)
            onUpdateLastPoint:      trajectoryPolyline.replaceCoordinate(trajectoryPolyline.pathLength() - 1, coordinate)
            onPointsCleared:        trajectoryPolyline.path = []
        }
    }

    // Add the vehicles to the map
    MapItemView {
        model: QGroundControl.multiVehicleManager.vehicles
        delegate: VehicleMapItem {
            vehicle:        object
            coordinate:     object.coordinate
            map:            _root
            size:           pipMode ? ScreenTools.defaultFontPixelHeight : ScreenTools.defaultFontPixelHeight * 3
            z:              QGroundControl.zOrderVehicles
        }
    }
    // Add distance sensor view
    MapItemView{
        model: QGroundControl.multiVehicleManager.vehicles
        delegate: ProximityRadarMapView {
            vehicle:        object
            coordinate:     object.coordinate
            map:            _root
            z:              QGroundControl.zOrderVehicles
        }
    }
    // Add ADSB vehicles to the map
    MapItemView {
        model: QGroundControl.adsbVehicleManager.adsbVehicles
        delegate: VehicleMapItem {
            coordinate:     object.coordinate
            altitude:       object.altitude
            callsign:       object.callsign
            heading:        object.heading
            alert:          object.alert
            map:            _root
            z:              QGroundControl.zOrderVehicles
        }
    }

    // Add the items associated with each vehicles flight plan to the map
    Repeater {
        model: QGroundControl.multiVehicleManager.vehicles

        PlanMapItems {
            map:                    _root
            largeMapView:           !pipMode
            planMasterController:   _planMasterController
            vehicle:                _vehicle

            property var _vehicle: object

            PlanMasterController {
                id: masterController
                Component.onCompleted: startStaticActiveVehicle(object)
            }
        }
    }

    MapItemView {
        model: pipMode ? undefined : _missionController.directionArrows

        delegate: MapLineArrow {
            fromCoord:      object ? object.coordinate1 : undefined
            toCoord:        object ? object.coordinate2 : undefined
            arrowPosition:  2
            z:              QGroundControl.zOrderWaypointLines
        }
    }

    // Allow custom builds to add map items
    CustomMapItems {
        map:            _root
        largeMapView:   !pipMode
    }

    GeoFenceMapVisuals {
        map:                    _root
        myGeoFenceController:   _geoFenceController
        interactive:            false
        planView:               false
        homePosition:           _activeVehicle && _activeVehicle.homePosition.isValid ? _activeVehicle.homePosition :  QtPositioning.coordinate()
    }

    // Rally points on map
    MapItemView {
        model: _rallyPointController.points

        delegate: MapQuickItem {
            id:             itemIndicator
            anchorPoint.x:  sourceItem.anchorPointX
            anchorPoint.y:  sourceItem.anchorPointY
            coordinate:     object.coordinate
            z:              QGroundControl.zOrderMapItems

            sourceItem: MissionItemIndexLabel {
                id:         itemIndexLabel
                label:      qsTr("R", "rally point map item label")
            }
        }
    }

    // Camera trigger points
    MapItemView {
        model: _activeVehicle ? _activeVehicle.cameraTriggerPoints : 0

        delegate: CameraTriggerIndicator {
            coordinate:     object.coordinate
            z:              QGroundControl.zOrderTopMost
        }
    }

    // GoTo Location visuals
    MapQuickItem {
        id:             gotoLocationItem
        visible:        false
        z:              QGroundControl.zOrderMapItems
        anchorPoint.x:  sourceItem.anchorPointX
        anchorPoint.y:  sourceItem.anchorPointY
        sourceItem: MissionItemIndexLabel {
            checked:    true
            index:      -1
            label:      qsTr("Go here", "Go to location waypoint")
        }

        property bool inGotoFlightMode: _activeVehicle ? _activeVehicle.flightMode === _activeVehicle.gotoFlightMode : false

        onInGotoFlightModeChanged: {
            if (!inGotoFlightMode && gotoLocationItem.visible) {
                // Hide goto indicator when vehicle falls out of guided mode
                gotoLocationItem.visible = false
            }
        }

        Connections {
            target: QGroundControl.multiVehicleManager
            onActiveVehicleChanged: {
                if (!activeVehicle) {
                    gotoLocationItem.visible = false
                }
            }
        }

        function show(coord) {
            gotoLocationItem.coordinate = coord
            gotoLocationItem.visible = true
        }

        function hide() {
            gotoLocationItem.visible = false
        }

        function actionConfirmed() {
            // We leave the indicator visible. The handling for onInGuidedModeChanged will hide it.
        }

        function actionCancelled() {
            hide()
        }
    }

    // Orbit editing visuals
    QGCMapCircleVisuals {
        id:             orbitMapCircle
        mapControl:     parent
        mapCircle:      _mapCircle
        visible:        false

        property alias center:              _mapCircle.center
        property alias clockwiseRotation:   _mapCircle.clockwiseRotation
        readonly property real defaultRadius: 30

        Connections {
            target: QGroundControl.multiVehicleManager
            onActiveVehicleChanged: {
                if (!activeVehicle) {
                    orbitMapCircle.visible = false
                }
            }
        }

        function show(coord) {
            _mapCircle.radius.rawValue = defaultRadius
            orbitMapCircle.center = coord
            orbitMapCircle.visible = true
        }

        function hide() {
            orbitMapCircle.visible = false
        }

        function actionConfirmed() {
            // Live orbit status is handled by telemetry so we hide here and telemetry will show again.
            hide()
        }

        function actionCancelled() {
            hide()
        }

        function radius() {
            return _mapCircle.radius.rawValue
        }

        Component.onCompleted: globals.guidedControllerFlyView.orbitMapCircle = orbitMapCircle

        QGCMapCircle {
            id:                 _mapCircle
            interactive:        true
            radius.rawValue:    30
            showRotation:       true
            clockwiseRotation:  true
        }
    }

    // ROI Location visuals
    MapQuickItem {
        id:             roiLocationItem
        visible:        _activeVehicle && _activeVehicle.isROIEnabled
        z:              QGroundControl.zOrderMapItems
        anchorPoint.x:  sourceItem.anchorPointX
        anchorPoint.y:  sourceItem.anchorPointY
        sourceItem: MissionItemIndexLabel {
            checked:    true
            index:      -1
            label:      qsTr("ROI here", "Make this a Region Of Interest")
        }

        //-- Visibilty controlled by actual state
        function show(coord) {
            roiLocationItem.coordinate = coord
        }

        function hide() {
        }

        function actionConfirmed() {
        }

        function actionCancelled() {
        }
    }

    // Orbit telemetry visuals
    QGCMapCircleVisuals {
        id:             orbitTelemetryCircle
        mapControl:     parent
        mapCircle:      _activeVehicle ? _activeVehicle.orbitMapCircle : null
        visible:        _activeVehicle ? _activeVehicle.orbitActive : false
    }

    MapQuickItem {
        id:             orbitCenterIndicator
        anchorPoint.x:  sourceItem.anchorPointX
        anchorPoint.y:  sourceItem.anchorPointY
        coordinate:     _activeVehicle ? _activeVehicle.orbitMapCircle.center : QtPositioning.coordinate()
        visible:        orbitTelemetryCircle.visible

        sourceItem: MissionItemIndexLabel {
            checked:    true
            index:      -1
            label:      qsTr("Orbit", "Orbit waypoint")
        }
    }

    // Handle guided mode clicks
    MouseArea {
        anchors.fill: parent

        QGCMenu {
            id: clickMenu
            property var coord
            QGCMenuItem {
                text:           qsTr("Go to location")
                visible:        globals.guidedControllerFlyView.showGotoLocation

                onTriggered: {
                    gotoLocationItem.show(clickMenu.coord)
                    globals.guidedControllerFlyView.confirmAction(globals.guidedControllerFlyView.actionGoto, clickMenu.coord, gotoLocationItem)
                }
            }
            QGCMenuItem {
                text:           qsTr("Orbit at location")
                visible:        globals.guidedControllerFlyView.showOrbit

                onTriggered: {
                    orbitMapCircle.show(clickMenu.coord)
                    globals.guidedControllerFlyView.confirmAction(globals.guidedControllerFlyView.actionOrbit, clickMenu.coord, orbitMapCircle)
                }
            }
            QGCMenuItem {
                text:           qsTr("ROI at location")
                visible:        globals.guidedControllerFlyView.showROI

                onTriggered: {
                    roiLocationItem.show(clickMenu.coord)
                    globals.guidedControllerFlyView.confirmAction(globals.guidedControllerFlyView.actionROI, clickMenu.coord, roiLocationItem)
                }
            }
        }

        onClicked: {
            if (!globals.guidedControllerFlyView.guidedUIVisible && (globals.guidedControllerFlyView.showGotoLocation || globals.guidedControllerFlyView.showOrbit || globals.guidedControllerFlyView.showROI)) {
                orbitMapCircle.hide()
                gotoLocationItem.hide()
                var clickCoord = _root.toCoordinate(Qt.point(mouse.x, mouse.y), false /* clipToViewPort */)
                clickMenu.coord = clickCoord
                clickMenu.popup()
            }
        }
    }

    // Airspace overlap support
    MapItemView {
        model:              _airspaceEnabled && QGroundControl.settingsManager.airMapSettings.enableAirspace && QGroundControl.airspaceManager.airspaceVisible ? QGroundControl.airspaceManager.airspaces.circles : []
        delegate: MapCircle {
            center:         object.center
            radius:         object.radius
            color:          object.color
            border.color:   object.lineColor
            border.width:   object.lineWidth
        }
    }

    ///////////////////////////////////////////////////////////////////////////

    Item{
            id: drone
            //width: parent.width<parent.height?parent.width:parent.height/4
            width: parent.width/15
            x: parent.width<parent.height?parent.width:parent.height
            height: width
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.rightMargin: 2.5*(top_left_prop.width)
            anchors.bottomMargin: top_left_prop.width

            Image {
                id: drone_center
                width: drone.width
                height: width
                //source: "/qml/droneBody.png"
                anchors.verticalCenter: drone.verticalCenter
                anchors.horizontalCenter: drone.horizontalCenter
            }

            Rectangle {
                id: top_left_prop
                width: drone.width / 1.5
                height: width
                color: "white"
                states:[
                    State {
                        name: "green"; when: _activeVehicle.servoRaw.value < 75
                        PropertyChanges {target: top_left_prop; color: "green"}
                    },
                    State {
                        name: "yellow"; when: _activeVehicle.servoRaw.value >= 75 && _activeVehicle.servoRaw.value <90
                        PropertyChanges {target: top_left_prop; color: "yellow"}
                    },
                    State {
                        name: "orange"; when: _activeVehicle.servoRaw.value >= 90 && _activeVehicle.servoRaw.value <95
                        PropertyChanges {target: top_left_prop; color: "orange"}
                    },
                    State {
                        name: "red"; when: _activeVehicle.servoRaw.value >= 95
                        PropertyChanges {target: top_left_prop; color: "red"}
                    }
                ]
                transitions:[
                    Transition{
                        from: "yellow"; to: "green"; reversible: true
                        ParallelAnimation{
                            ColorAnimation { duration: 500 }
                        }
                    },
                    Transition{
                        from: "green"; to: "yellow"; reversible: true
                        ParallelAnimation{
                            ColorAnimation { duration: 500 }
                        }
                    },
                    Transition{
                        from: "yellow"; to: "orange"; reversible: true
                        ParallelAnimation{
                            ColorAnimation { duration: 500 }
                        }
                    },
                    Transition{
                        from: "orange"; to: "red"; reversible: true
                        ParallelAnimation{
                            ColorAnimation { duration: 500 }
                        }
                    }
                ]
                border.color: "black"
                border.width: 1
                radius: width*0.5
                anchors.top: drone_center.top
                anchors.left: drone_center.left
                anchors.topMargin: -top_left_prop.height / 1.65
                anchors.leftMargin: -top_left_prop.width / 1.65
                Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        visible:                true
                        text:                   _activeVehicle ? _activeVehicle.servoRaw.value +"%" : null
                }
            }

            Rectangle {
                id: bottom_left_prop
                width: top_left_prop.width
                height: width
                color: "white"
                states:[
                    State {
                        name: "green"; when: _activeVehicle.servoRaw3.value < 75
                        PropertyChanges {target: bottom_left_prop; color: "green"}
                    },
                    State {
                        name: "yellow"; when: _activeVehicle.servoRaw3.value >= 75 && _activeVehicle.servoRaw3.value <90
                        PropertyChanges {target: bottom_left_prop; color: "yellow"}
                    },
                    State {
                        name: "orange"; when: _activeVehicle.servoRaw3.value >= 90 && _activeVehicle.servoRaw3.value <95
                        PropertyChanges {target: bottom_left_prop; color: "orange"}
                    },
                    State {
                        name: "red"; when: _activeVehicle.servoRaw3.value >= 95
                        PropertyChanges {target: bottom_left_prop; color: "red"}
                    }
                ]
                transitions:[
                    Transition{
                        from: "yellow"; to: "green"; reversible: true
                        ParallelAnimation{
                            ColorAnimation { duration: 500 }
                        }
                    },
                    Transition{
                        from: "green"; to: "yellow"; reversible: true
                        ParallelAnimation{
                            ColorAnimation { duration: 500 }
                        }
                    },
                    Transition{
                        from: "yellow"; to: "orange"; reversible: true
                        ParallelAnimation{
                            ColorAnimation { duration: 500 }
                        }
                    },
                    Transition{
                        from: "orange"; to: "red"; reversible: true
                        ParallelAnimation{
                            ColorAnimation { duration: 500 }
                        }
                    }
                ]
                border.color: "black"
                border.width: 1
                radius: width*0.5
                anchors.bottom: drone_center.bottom
                anchors.left: drone_center.left
                anchors.bottomMargin: -bottom_left_prop.height / 1.65
                anchors.leftMargin: -bottom_left_prop.width / 1.65
                Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        //color: "black"
                        visible:                true
                        text:                   _activeVehicle ? _activeVehicle.servoRaw3.value +"%" : null
                }
            }

            Rectangle {
                id: bottom_right_prop
                width: top_left_prop.width
                height: width
                color: "white"
                states:[
                    State {
                        name: "green"; when: _activeVehicle.servoRaw4.value < 75
                        PropertyChanges {target: bottom_right_prop; color: "green"}
                    },
                    State {
                        name: "yellow"; when: _activeVehicle.servoRaw4.value >= 75 && _activeVehicle.servoRaw4.value <90
                        PropertyChanges {target: bottom_right_prop; color: "yellow"}
                    },
                    State {
                        name: "orange"; when: _activeVehicle.servoRaw4.value >= 90 && _activeVehicle.servoRaw4.value <95
                        PropertyChanges {target: bottom_right_prop; color: "orange"}
                    },
                    State {
                        name: "red"; when: _activeVehicle.servoRaw4.value >= 95
                        PropertyChanges {target: bottom_right_prop; color: "red"}
                    }
                ]
                transitions:[
                    Transition{
                        from: "yellow"; to: "green"; reversible: true
                        ParallelAnimation{
                            ColorAnimation { duration: 500 }
                        }
                    },
                    Transition{
                        from: "green"; to: "yellow"; reversible: true
                        ParallelAnimation{
                            ColorAnimation { duration: 500 }
                        }
                    },
                    Transition{
                        from: "yellow"; to: "orange"; reversible: true
                        ParallelAnimation{
                            ColorAnimation { duration: 500 }
                        }
                    },
                    Transition{
                        from: "orange"; to: "red"; reversible: true
                        ParallelAnimation{
                            ColorAnimation { duration: 500 }
                        }
                    }
                ]
                border.color: "black"
                border.width: 1
                radius: width*0.5
                anchors.bottom: drone_center.bottom
                anchors.right: drone_center.right
                anchors.bottomMargin: -bottom_right_prop.height / 1.65
                anchors.rightMargin: -bottom_right_prop.width / 1.65
                Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        visible:                true
                        text:                   _activeVehicle ? _activeVehicle.servoRaw4.value +"%" : null
                }
            }

            Rectangle {
                id: top_right_prop
                width: top_left_prop.width
                height: width
                color: "white"
                states:[
                    State {
                        name: "green"; when: _activeVehicle.servoRaw2.value < 75
                        PropertyChanges {target: top_right_prop; color: "green"}
                    },
                    State {
                        name: "yellow"; when: _activeVehicle.servoRaw2.value >= 75 && _activeVehicle.servoRaw2.value <90
                        PropertyChanges {target: top_right_prop; color: "yellow"}
                    },
                    State {
                        name: "orange"; when: _activeVehicle.servoRaw2.value >= 90 && _activeVehicle.servoRaw2.value <95
                        PropertyChanges {target: top_right_prop; color: "orange"}
                    },
                    State {
                        name: "red"; when: _activeVehicle.servoRaw2.value >= 95
                        PropertyChanges {target: top_right_prop; color: "red"}
                    }
                ]
                transitions:[
                    Transition{
                        from: "yellow"; to: "green"; reversible: true
                        ParallelAnimation{
                            ColorAnimation { duration: 500 }
                        }
                    },
                    Transition{
                        from: "green"; to: "yellow"; reversible: true
                        ParallelAnimation{
                            ColorAnimation { duration: 500 }
                        }
                    },
                    Transition{
                        from: "yellow"; to: "orange"; reversible: true
                        ParallelAnimation{
                            ColorAnimation { duration: 500 }
                        }
                    },
                    Transition{
                        from: "orange"; to: "red"; reversible: true
                        ParallelAnimation{
                            ColorAnimation { duration: 500 }
                        }
                    }
                ]
                border.color: "black"
                border.width: 1
                radius: width*0.5
                anchors.top: drone_center.top
                anchors.right: drone_center.right
                anchors.topMargin: -top_right_prop.height / 1.65
                anchors.rightMargin: -top_right_prop.width / 1.65
                Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        visible:                true
                        text:                   _activeVehicle ? _activeVehicle.servoRaw2.value +"%" : null
                }
            }
        }

            Rectangle{
                id: button
                width: drone.width/3
                height: width/3
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.leftMargin: parent.width/24.25
                anchors.topMargin: parent.height/15
                color: "transparent"
                states: [
                    State {
                        name: "on"
                        PropertyChanges {target: drone_center; visible : true}
                        PropertyChanges {target: top_left_prop; visible : true}
                        PropertyChanges {target: top_right_prop; visible : true}
                        PropertyChanges {target: bottom_right_prop; visible : true}
                        PropertyChanges {target: bottom_left_prop; visible : true}
                    },
                    State {
                        name: "off"
                        PropertyChanges {target: drone_center; visible : false}
                        PropertyChanges {target: top_left_prop; visible : false}
                        PropertyChanges {target: top_right_prop; visible : false}
                        PropertyChanges {target: bottom_right_prop; visible : false}
                        PropertyChanges {target: bottom_left_prop; visible : false}
                    }
                ]
                    transitions: [
                        Transition {
                            from: "on"; to: "off"; reversible: true
                        }
                    ]
                Button{
                    text: "On/Off"
                    onClicked: button.state = (button.state === 'off' ? 'on' : "off");
                }
        }
            Item{
                id: buttons
                width: 2.75*(drone.width)
                height: 2.5*(drone.height)
                anchors.verticalCenter: drone.verticalCenter
                anchors.horizontalCenter: drone.horizontalCenter

                Rectangle{
                    id: white_background
                    color: "white"
                    opacity: 0.5
                    width: p_dis.width * 6
                    height: p_dis.height * 1.2
                    anchors.left: buttons.right
                    anchors.top: p_dis.top
                    anchors.topMargin: -p_dis.width / 2
                    anchors.leftMargin: -p_dis.width / 4
                }

                Rectangle{
                    id: p_dis
                    anchors.left: buttons.right
                    anchors.top: buttons.top
                    anchors.topMargin: buttons.width / 3.5
                    height: buttons.height / 2
                    width: buttons.width / 10
                    color: "transparent"
                    border.color: "black"
                    border.width: 2

                    Text{
                        text: "P"
                        anchors.top: p_dis.bottom
                        anchors.horizontalCenter: p_dis.horizontalCenter
                    }
                    Rectangle{
                        property int rollError: _activeVehicle ? (((Math.abs(_activeVehicle.attitudeRoll.value - _activeVehicle.rollRate.value)) / Math.abs(_activeVehicle.rollRate.value)) * 100) : 0
                        width: p_dis.width / 1.25
                        anchors.bottom: p_dis.bottom
                        anchors.horizontalCenter: p_dis.horizontalCenter
                        anchors.bottomMargin: 2
                        color: "green"
                        height: (rollError >= p_dis.height) ? p_dis.height : rollError
                    }
                }

                Rectangle{
                    id: r_dis
                    anchors.left: p_dis.right
                    anchors.top: p_dis.top
                    anchors.leftMargin: r_dis.width / 3
                    height: p_dis.height
                    width: p_dis.width
                    color: "transparent"
                    border.color: "black"
                    border.width: 2

                    Text{
                        text: "R"
                        anchors.top: r_dis.bottom
                        anchors.horizontalCenter: r_dis.horizontalCenter
                    }
                    Rectangle{
                        property int pitchError: _activeVehicle ? (((Math.abs(_activeVehicle.attitudePitch.value - _activeVehicle.pitchRate.value)) / Math.abs(_activeVehicle.pitchRate.value)) * 100) : 0
                        width: r_dis.width / 1.25
                        anchors.bottom: r_dis.bottom
                        anchors.horizontalCenter: r_dis.horizontalCenter
                        anchors.bottomMargin: 2
                        color: "green"
                        height: (pitchError >= r_dis.height) ? r_dis.height : pitchError
                    }
                }

                Rectangle{
                    id: y_dis
                    anchors.left: r_dis.right
                    anchors.top: r_dis.top
                    anchors.leftMargin: y_dis.width / 3
                    height: p_dis.height
                    width: p_dis.width
                    color: "transparent"
                    border.color: "black"
                    border.width: 2

                    Text{
                        text: "Y"
                        anchors.top: y_dis.bottom
                        anchors.horizontalCenter: y_dis.horizontalCenter
                    }
                    Rectangle{
                        property int yawError: _activeVehicle ? (((Math.abs(_activeVehicle.attitudeYaw.value - _activeVehicle.yawRate.value)) / Math.abs(_activeVehicle.yawRate.value)) * 100) : 0
                        width: y_dis.width / 1.25
                        anchors.bottom: y_dis.bottom
                        anchors.horizontalCenter: y_dis.horizontalCenter
                        anchors.bottomMargin: 2
                        color: "green"
                        height: (yawError >= y_dis.height) ? y_dis.height : yawError
                    }
                }

                Rectangle{
                    id: topRef
                    width: p_dis.width
                    height: 2
                    color: "black"
                    anchors.left: y_dis.right
                    anchors.top: p_dis.top
                    anchors.leftMargin: topRef.width / 3
                    Text{
                        text: "10"
                        anchors.left: topRef.right
                        anchors.horizontalCenter: topRef.horizontalCenter
                    }
                }

                Rectangle{
                    id: sideRef
                    width: 2
                    height: p_dis.height
                    color: "black"
                    anchors.left: y_dis.right
                    anchors.top: p_dis.top
                    anchors.leftMargin: topRef.width / 3
                }

                Rectangle{
                    id: bottomRef
                    width: p_dis.width
                    height: 2
                    color: "black"
                    anchors.left: y_dis.right
                    anchors.bottom: p_dis.bottom
                    anchors.leftMargin: topRef.width / 3
                    Text{
                        text: "0"
                        anchors.left: bottomRef.right
                        anchors.horizontalCenter: bottomRef.horizontalCenter
                    }
                }

                Rectangle{
                    id: midRef
                    width: p_dis.width
                    height: 2
                    color: "black"
                    anchors.left: y_dis.right
                    anchors.top: sideRef.top
                    anchors.topMargin: sideRef.height / 2
                    anchors.leftMargin: topRef.width / 3
                    Text{
                        text: "5"
                        anchors.left: midRef.right
                        anchors.horizontalCenter: midRef.horizontalCenter
                    }
                }

                Rectangle{
                    width: buttons.width
                    height: buttons.height
                    color: "transparent"
                }

                Rectangle{
                    id: rc_button
                    height: 15
                    width: 60
                    anchors.left: buttons.left
                    anchors.top: buttons.top
                    anchors.leftMargin: p_dis.width
                    property string rc_border_color: "lime"
                    states: [
                        State {
                            name: "on_rc"
                            PropertyChanges {target: train_button; opacity : 1}
                            PropertyChanges {target: rc_button_control; text : "RC"}
                            PropertyChanges {target: rc_button_control; palette.buttonText: "white"}
                            PropertyChanges {target: rc_button; rc_border_color: "lime"}
                            PropertyChanges {target: rc_button_control; palette.button : "steelblue"}
                            PropertyChanges {target: rc_button_control; text : "RC"}
                            //switch to rc
                            onCompleted: _root.rc_or_pid=1
                        },
                        State {
                            name: "off_rc"
                            PropertyChanges {target: train_button; opacity : 0.5}
                            PropertyChanges {target: rc_button_control; text : "PID"}
                            PropertyChanges {target: rc_button_control; palette.buttonText: "black"}
                            PropertyChanges {target: rc_button; rc_border_color: "black"}
                            PropertyChanges {target: rc_button_control; palette.button : "white"}
                            //switch to pid
                            onCompleted: _root.rc_or_pid=0
                        }
                    ]
                    transitions: [
                        Transition {
                            from: "on_rc"; to: "off_rc"; reversible: true
                        }
                    ]
                    Button{
                        id: rc_button_control
                        height: 15
                        width: 60
                        text: "RC"
                        palette.buttonText: "white"
                        palette.button: "steelblue"
                        Rectangle{
                            height: 15
                            width: 60
                            border.color: rc_button.rc_border_color
                            border.width: 1.25
                            color: "transparent"
                        }

                        onClicked: {
                            rc_button.state = (rc_button.state === 'off_rc' ? 'on_rc' : "off_rc");
                            if(_root.rc_or_pid===0){
                                train_button.state = "train_off"
                            }
                            else{
                                train_button.state = "train_on"
                            }
                            //switch rc pid
                            paramController.changeValue("RC_OR_PID", _root.rc_or_pid);
                        }
                    }
                }


                Rectangle{
                    id: train_button
                    height: 15
                    width: 60
                    anchors.right: buttons.right
                    anchors.top: buttons.top
                    anchors.rightMargin: p_dis.width
                    property string train_border_color: "black"
                    states: [
                        State {
                            name: "train_on"
                            PropertyChanges {target: train_button_control; palette.button : "white"}
                            PropertyChanges {target: train_button_control; palette.buttonText: "black"}
                            PropertyChanges {target: train_button; train_border_color: "black"}
                            PropertyChanges {target: train_button; opacity : 1}
                            onCompleted: _root.train =  0
                        },
                        State {
                            name: "train_off"
                            PropertyChanges {target: train_button_control; palette.button : "grey"}
                            PropertyChanges {target: train_button_control; palette.buttonText: "white"}
                            PropertyChanges {target: train_button; train_border_color: "grey"}
                            PropertyChanges {target: train_button; opacity : .5}
                        },
                        State {
                            name: "training"
                            PropertyChanges {target: train_button; opacity : 1}
                            PropertyChanges {target: train_button_control; palette.buttonText: "white"}
                            PropertyChanges {target: train_button_control; palette.button : "steelblue"}
                            PropertyChanges {target: train_button; train_border_color: "lime"}
                            onCompleted: _root.train = 1
                        }
                    ]
                    transitions: [
                        Transition {
                            from: "train_on"; to: "training"; reversible: true
                        },
                        Transition {
                            from: "training"; to: "train_off"; reversible: true
                        },
                        Transition {
                            from: "train_off"; to: "train_on"; reversible: true
                        }
                    ]
                    Button{
                        id: train_button_control
                        height: 15
                        width: 60
                        text: "TRAIN"
                        anchors.horizontalCenter: train_button.horizontalCenter
                        anchors.verticalCenter: train_button.verticalCenter
                        Rectangle{
                            height: 15
                            width: 60
                            border.color: train_button.train_border_color
                            border.width: 1.25
                            color: "transparent"
                        }
                        onClicked: {
                            paramController.changeValue("TRAIN", _root.train);
                            if(_root.rc_or_pid===1){
                                if(_root.train===0){
                                    train_button.state = "training"
                                }
                            }
                        }

                    }
                }

                QGCButton {
                    anchors.bottom: buttons.top
                    anchors.horizontalCenter: buttons.horizontalCenter
                    anchors.bottomMargin: train_button.height / 3
                    property bool   _armed:         _activeVehicle ? _activeVehicle.armed : false
                    Layout.alignment:   Qt.AlignHCenter
                    text:               _armed ?  qsTr("Disarm") : (forceArm ? qsTr("Force Arm") : qsTr("Arm"))

                    property bool forceArm: false

                    onPressAndHold: forceArm = true

                    onClicked: {
                        if (_armed) {
                            mainWindow.disarmVehicleRequest()
                        } else {
                            if (forceArm) {
                                mainWindow.forceArmVehicleRequest()
                            } else {
                                mainWindow.armVehicleRequest()
                            }
                        }
                        forceArm = false
                        mainWindow.hideIndicatorPopup()
                    }
                }
        }

            Rectangle{
                id: valueDisplay
                width: drone.width * 2
                height: drone.height * 1.75
                anchors.right: drone.left
                anchors.bottom: drone.bottom
                anchors.rightMargin: drone.width
                anchors.bottomMargin: drone.width / -4
                color: "white"
                //opacity: .5
                Text{
                    id: actRoll
                    text: _activeVehicle ? "Roll: " + _activeVehicle.rollRate.value.toFixed(5) : null
                }
                Text{
                    id: actPitch
                    anchors.top: actRoll.bottom
                    text: _activeVehicle ? "Pitch: " + _activeVehicle.pitchRate.value.toFixed(5) : null
                }
                Text{
                    id: actYaw
                    anchors.top: actPitch.bottom
                    text: _activeVehicle ? "Yaw: " + _activeVehicle.yawRate.value.toFixed(5) : null
                }
                Text{
                    id: estRoll
                    anchors.top: actYaw.bottom
                    text: _activeVehicle ? "Setpoint Roll: " + _activeVehicle.attitudeRoll.value.toFixed(5) : null
                    color: "orange"
                }
                Text{
                    id: estPitch
                    anchors.top: estRoll.bottom
                    text: _activeVehicle ? "Setpoint Pitch: " + _activeVehicle.attitudePitch.value.toFixed(5) : null
                    color: "orange"
                }
                Text{
                    id: estYaw
                    anchors.top: estPitch.bottom
                    text: _activeVehicle ? "Setpoint Yaw: " + _activeVehicle.attitudeYaw.value.toFixed(5) : null
                    color: "orange"
                }
                Text{
                    id: nRollPercent
                    anchors.top: estYaw.bottom
                    text: _root ? _root.rc_or_pid : null
                    color: "green"
                }
                Text{
                    id: nPitchPercent
                    anchors.top: nRollPercent.bottom
                    text: _activeVehicle ? _activeVehicle.armed : false
                    color: "green"
                }
                Text{
                    id: nYawPercent
                    anchors.top: nPitchPercent.bottom
                    //text: _activeVehicle ? "Accurate Yaw %: " + _activeVehicle.yawRate.value.toFixed(2) : null
                    color: "green"
                }
                Text{
                    id: oRollPercent
                    anchors.top: nYawPercent.bottom
                    text: _activeVehicle ? "Inaccurate Roll %: " + (((Math.abs(_activeVehicle.attitudeRoll.value - _activeVehicle.rollRate.value)) / Math.abs(_activeVehicle.rollRate.value)) * 100).toFixed(2) : 0
                    color: "red"
                }
                Text{
                    id: oPitchPercent
                    anchors.top: oRollPercent.bottom
                    text: _activeVehicle ? "inaccurate Pitch %: " + (((Math.abs(_activeVehicle.attitudePitch.value - _activeVehicle.pitchRate.value)) / Math.abs(_activeVehicle.pitchRate.value)) * 100).toFixed(2) : 0
                    color: "red"
                }
                Text{
                    id: oYawPercent
                    anchors.top: oPitchPercent.bottom
                    text: _activeVehicle ? "Inaccurate Yaw %: " +  (((Math.abs(_activeVehicle.attitudeYaw.value - _activeVehicle.yawRate.value)) / Math.abs(_activeVehicle.yawRate.value)) * 100).toFixed(2) : 0
                    color: "red"
                }
                Text{
                    id: rateController
                    anchors.top: oYawPercent.bottom
                    //text: instrumentValueData.fact.enumOrValueString
                    color: "blue"
                }
            }



    /////////////////////////////////////////////////////////////

    MapItemView {
        model:              _airspaceEnabled && QGroundControl.settingsManager.airMapSettings.enableAirspace && QGroundControl.airspaceManager.airspaceVisible ? QGroundControl.airspaceManager.airspaces.polygons : []
        delegate: MapPolygon {
            path:           object.polygon
            color:          object.color
            border.color:   object.lineColor
            border.width:   object.lineWidth
        }
    }

    MapScale {
        id:                 mapScale
        anchors.margins:    _toolsMargin
        anchors.left:       parent.left
        anchors.top:        parent.top
        mapControl:         _root
        buttonsOnLeft:      false
        visible:            !ScreenTools.isTinyScreen && QGroundControl.corePlugin.options.flyView.showMapScale && mapControl.pipState.state === mapControl.pipState.windowState

        property real centerInset: visible ? parent.height - y : 0
    }



}

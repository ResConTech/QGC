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
    property var setpoint_pitch: _activeVehicle ? _activeVehicle.getSetpointPitch() : 0
    property var setpoint_roll: _activeVehicle ? _activeVehicle.getSetpointRoll() : 0
    property var setpoint_yaw: _activeVehicle ? _activeVehicle.getSetpointYaw() : 0
    property bool maximum_error: [false, false, false]
    property int smoothingFactor: 10  //lower = smoother

    function errorHeight(error, height, index){
        if(error * height / 2 * 20 > height / 2){
            maximum_error[index] = true
            return height / 2
        }
        else{
            maximum_error[index] = false
            return error * height / 2 * 20
        }
    }

    function actualNormalize(actual){
        if(Math.abs(actual) > 180){
            return (180 - Math.abs(180 - actual))
        }
        return actual
    }
    function pos(actual, setpoint, negHeight){
        if(actual - setpoint >= 0){ //|| negHeight > 0){
            return 1
        }
        else{
            return 0
        }
    }
    function neg(actual, setpoint, posHeight){
        if(actual - setpoint >= 0){ //|| posHeight > 0){
            return 0
        }
        else{
            return 1
        }
    }
    function updateSetpoints(){
        setpoint_pitch = _activeVehicle ? _activeVehicle.getSetpointPitch() : 0
        setpoint_roll = _activeVehicle ? _activeVehicle.getSetpointRoll() : 0
        setpoint_yaw = _activeVehicle ? _activeVehicle.getSetpointYaw() : 0
    }
//    Timer {
//        interval:       100
//        running:        true
//        repeat:         true
//        onTriggered:    {
//            updateSetpoints()
//        }
//    }
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
                    source: "/qmlimages/newDroneBody.png"
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
                            name: "yellow_low"; when: _activeVehicle.servoRaw.value <= 40 && _activeVehicle.servoRaw.value > 35
                            PropertyChanges {target: top_left_prop; color: "yellow"}
                        },
                        State {
                            name: "red_low"; when: _activeVehicle.servoRaw.value <= 35
                            PropertyChanges {target: top_left_prop; color: "red"}
                        },
                        State {
                            name: "green"; when: _activeVehicle.servoRaw.value > 40 && _activeVehicle.servoRaw.value < 95
                            PropertyChanges {target: top_left_prop; color: "green"}
                        },
                        State {
                            name: "yellow"; when: _activeVehicle.servoRaw.value >= 95 && _activeVehicle.servoRaw.value < 98
                            PropertyChanges {target: top_left_prop; color: "yellow"}
                        },
                        State {
                            name: "red"; when: _activeVehicle.servoRaw.value >= 98
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
                            from: "yellow"; to: "red"; reversible: true
                            ParallelAnimation{
                                ColorAnimation { duration: 500 }
                            }
                        },
                        Transition{
                            from: "green"; to: "yellow_low"; reversible: true
                            ParallelAnimation{
                                ColorAnimation { duration: 500 }
                            }
                        },
                        Transition{
                            from: "yellow_low"; to: "red_low"; reversible: true
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
                            text:                   _activeVehicle ? _activeVehicle.servoRaw.value +"%" : 0
                    }
                }

                Rectangle {
                    id: bottom_left_prop
                    width: top_left_prop.width
                    height: width
                    color: "white"
                    states:[
                        State {
                            name: "yellow_low"; when: _activeVehicle.servoRaw3.value <= 40 && _activeVehicle.servoRaw3.value > 35
                            PropertyChanges {target: bottom_left_prop; color: "yellow"}
                        },
                        State {
                            name: "red_low"; when: _activeVehicle.servoRaw3.value <= 35
                            PropertyChanges {target: bottom_left_prop; color: "red"}
                        },
                        State {
                            name: "green"; when: _activeVehicle.servoRaw3.value > 40 && _activeVehicle.servoRaw3.value < 95
                            PropertyChanges {target: bottom_left_prop; color: "green"}
                        },
                        State {
                            name: "yellow"; when: _activeVehicle.servoRaw3.value >= 95 && _activeVehicle.servoRaw3.value < 98
                            PropertyChanges {target: bottom_left_prop; color: "yellow"}
                        },
                        State {
                            name: "red"; when: _activeVehicle.servoRaw3.value >= 98
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
                            from: "yellow"; to: "red"; reversible: true
                            ParallelAnimation{
                                ColorAnimation { duration: 500 }
                            }
                        },
                        Transition{
                            from: "green"; to: "yellow_low"; reversible: true
                            ParallelAnimation{
                                ColorAnimation { duration: 500 }
                            }
                        },
                        Transition{
                            from: "yellow_low"; to: "red_low"; reversible: true
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
                            text:                   _activeVehicle ? _activeVehicle.servoRaw3.value + "%" : 0
                    }
                }

                Rectangle {
                    id: bottom_right_prop
                    width: top_left_prop.width
                    height: width
                    color: "white"
                    states:[
                        State {
                            name: "yellow_low"; when: _activeVehicle.servoRaw4.value <= 40 && _activeVehicle.servoRaw4.value > 35
                            PropertyChanges {target: bottom_right_prop; color: "yellow"}
                        },
                        State {
                            name: "red_low"; when: _activeVehicle.servoRaw4.value <= 35
                            PropertyChanges {target: bottom_right_prop; color: "red"}
                        },
                        State {
                            name: "green"; when: _activeVehicle.servoRaw4.value > 40 && _activeVehicle.servoRaw4.value < 95
                            PropertyChanges {target: bottom_right_prop; color: "green"}
                        },
                        State {
                            name: "yellow"; when: _activeVehicle.servoRaw4.value >= 95 && _activeVehicle.servoRaw4.value < 98
                            PropertyChanges {target: bottom_right_prop; color: "yellow"}
                        },
                        State {
                            name: "red"; when: _activeVehicle.servoRaw4.value >= 98
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
                            from: "yellow"; to: "red"; reversible: true
                            ParallelAnimation{
                                ColorAnimation { duration: 500 }
                            }
                        },
                        Transition{
                            from: "green"; to: "yellow_low"; reversible: true
                            ParallelAnimation{
                                ColorAnimation { duration: 500 }
                            }
                        },
                        Transition{
                            from: "yellow_low"; to: "red_low"; reversible: true
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
                            text:                   _activeVehicle ? _activeVehicle.servoRaw4.value +"%" : 0
                    }
                }

                Rectangle {
                    id: top_right_prop
                    width: top_left_prop.width
                    height: width
                    color: "white"
                    states:[
                        State {
                            name: "yellow_low"; when: _activeVehicle.servoRaw2.value <= 40 && _activeVehicle.servoRaw2.value > 35
                            PropertyChanges {target: top_right_prop; color: "yellow"}
                        },
                        State {
                            name: "red_low"; when: _activeVehicle.servoRaw2.value <= 35
                            PropertyChanges {target: top_right_prop; color: "red"}
                        },
                        State {
                            name: "green"; when: _activeVehicle.servoRaw2.value > 40 && _activeVehicle.servoRaw2.value < 95
                            PropertyChanges {target: top_right_prop; color: "green"}
                        },
                        State {
                            name: "yellow"; when: _activeVehicle.servoRaw2.value >= 95 && _activeVehicle.servoRaw2.value < 98
                            PropertyChanges {target: top_right_prop; color: "yellow"}
                        },
                        State {
                            name: "red"; when: _activeVehicle.servoRaw2.value >= 98
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
                            from: "yellow"; to: "red"; reversible: true
                            ParallelAnimation{
                                ColorAnimation { duration: 500 }
                            }
                        },
                        Transition{
                            from: "green"; to: "yellow_low"; reversible: true
                            ParallelAnimation{
                                ColorAnimation { duration: 500 }
                            }
                        },
                        Transition{
                            from: "yellow_low"; to: "red_low"; reversible: true
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
                            text:                   _activeVehicle ? _activeVehicle.servoRaw2.value + "%" : 0
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
                    width: 1.75*(drone.width)
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
                        property real _pitch: _activeVehicle ? actualNormalize(_activeVehicle.pitch.value) : 0
                        property real pitchError: _activeVehicle ? ((Math.abs(_pitch - _activeVehicle.getSetpointPitch())) / 180) : 0
                        states: [
                            State {
                                name: "pos"
                                when: pitch_pos.height > 0
                                PropertyChanges {
                                    target: pitch_neg
                                    height: 0
                                }
                            },
                            State {
                                name: "neg"
                                when: pitch_neg.height > 0
                                PropertyChanges {
                                    target: pitch_pos
                                    height: 0
                                }
                            }
                        ]
                        transitions: [
                            Transition {
                                from: "pos"; to: "neg"; reversible: false
                                NumberAnimation {
                                    target: pitch_pos
                                    property: height
                                    duration: 20
                                    easing.type: Easing.OutExpo
                                    to: 0
                                }
                            },
                            Transition {
                                from: "neg"; to: "pos"; reversible: false
                                NumberAnimation {
                                    target: pitch_neg
                                    property: height
                                    duration: 20
                                    easing.type: Easing.OutExpo
                                    to: 0
                                }
                            }
                        ]
                        Text{
                            text: "P"
                            anchors.top: p_dis.bottom
                            anchors.horizontalCenter: p_dis.horizontalCenter
                        }
                        Rectangle{
                            id: pitch_pos
                            width: p_dis.width / 1.25
                            anchors.bottom: p_dis.verticalCenter
                            anchors.horizontalCenter: p_dis.horizontalCenter
                            anchors.bottomMargin: 2
                            color: "green"
                            height: _activeVehicle ? pos(Math.abs(p_dis._pitch), Math.abs(_activeVehicle.getSetpointPitch()), pitch_neg.height) * errorHeight(p_dis.pitchError, p_dis.height, 1) : 0
                            Behavior on height { SmoothedAnimation { velocity: smoothingFactor } }
                            states:[
                                State {
                                    name: "green"; when: pitch_pos.height / (p_dis.height / 2) < .333
                                    PropertyChanges {target: pitch_pos; color: "green"}
                                },
                                State {
                                    name: "yellow"; when: pitch_pos.height / (p_dis.height / 2) >= .333 && pitch_pos.height / (p_dis.height / 2) < .667
                                    PropertyChanges {target: pitch_pos; color: "yellow"}
                                },
                                State {
                                    name: "red"; when: pitch_pos.height / (p_dis.height / 2) <= 1 && pitch_pos.height / (p_dis.height / 2) >= .667
                                    PropertyChanges {target: pitch_pos; color: "red"}
                                },
                                State {
                                    name: "max"; when: maximum_error[1]
                                    PropertyChanges {target: pitch_pos; color: "darkred"}
                                }
                            ]
                            transitions:[
                                Transition{
                                    from: "green"; to: "yellow"; reversible: true
                                    ParallelAnimation{
                                        ColorAnimation { duration: 20 }
                                    }
                                },
                                Transition{
                                    from: "yellow"; to: "red"; reversible: true
                                    ParallelAnimation{
                                        ColorAnimation { duration: 20 }
                                    }
                                },
                                Transition{
                                    from: "red"; to: "max"; reversible: true
                                    ParallelAnimation{
                                        ColorAnimation { duration: 20 }
                                    }
                                }
                            ]
                        }
                        Rectangle{
                            id: pitch_neg
                            width: p_dis.width / 1.25
                            anchors.top: p_dis.verticalCenter
                            anchors.horizontalCenter: p_dis.horizontalCenter
                            anchors.bottomMargin: 2
                            color: "green"
                            height: _activeVehicle ? neg(Math.abs(p_dis._pitch), Math.abs(_activeVehicle.getSetpointPitch()), pitch_pos.height) * errorHeight(p_dis.pitchError, p_dis.height, 1) : 0
                            Behavior on height { SmoothedAnimation { velocity: smoothingFactor } }
                            states:[
                                State {
                                    name: "green"; when: pitch_neg.height / (p_dis.height / 2) < .333
                                    PropertyChanges {target: pitch_neg; color: "green"}
                                },
                                State {
                                    name: "yellow"; when: pitch_neg.height / (p_dis.height / 2) >= .333 && pitch_neg.height / (p_dis.height / 2) < .667
                                    PropertyChanges {target: pitch_neg; color: "yellow"}
                                },
                                State {
                                    name: "red"; when: pitch_neg.height / (p_dis.height / 2) <= 1 && pitch_neg.height / (p_dis.height / 2) >= .667
                                    PropertyChanges {target: pitch_neg; color: "red"}
                                },
                                State {
                                    name: "max"; when: maximum_error[1]
                                    PropertyChanges {target: pitch_neg; color: "darkred"}
                                }
                            ]
                            transitions:[
                                Transition{
                                    from: "green"; to: "yellow"; reversible: true
                                    ParallelAnimation{
                                        ColorAnimation { duration: 20 }
                                    }
                                },
                                Transition{
                                    from: "yellow"; to: "red"; reversible: true
                                    ParallelAnimation{
                                        ColorAnimation { duration: 20 }
                                    }
                                },
                                Transition{
                                    from: "red"; to: "max"; reversible: true
                                    ParallelAnimation{
                                        ColorAnimation { duration: 20 }
                                    }
                                }
                            ]
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
                        property real _roll: _activeVehicle ? actualNormalize(_activeVehicle.roll.value) : 0
                        property real rollError: _activeVehicle ? ((Math.abs(_roll - _activeVehicle.getSetpointRoll())) / 180) : 0
                        states: [
                            State {
                                name: "pos"
                                when: roll_pos.height > 0
                                PropertyChanges {
                                    target: roll_neg
                                    height: 0
                                }
                            },
                            State {
                                name: "neg"
                                when: roll_neg.height > 0
                                PropertyChanges {
                                    target: roll_pos
                                    height: 0
                                }
                            }
                        ]
                        transitions: [
                            Transition {
                                from: "pos"; to: "neg"; reversible: false
                                NumberAnimation {
                                    target: roll_pos
                                    property: height
                                    duration: 20
                                    easing.type: Easing.OutExpo
                                    to: 0
                                }
                            },
                            Transition {
                                from: "neg"; to: "pos"; reversible: false
                                NumberAnimation {
                                    target: roll_neg
                                    property: height
                                    duration: 20
                                    easing.type: Easing.OutExpo
                                    to: 0
                                }
                            }
                        ]

                        Text{
                            text: "R"
                            anchors.top: r_dis.bottom
                            anchors.horizontalCenter: r_dis.horizontalCenter
                        }
                        Rectangle{
                            id: roll_pos
                            width: r_dis.width / 1.25
                            anchors.bottom: r_dis.verticalCenter
                            anchors.horizontalCenter: r_dis.horizontalCenter
                            anchors.bottomMargin: 2
                            color: "green"
                            height: _activeVehicle ? pos(Math.abs(r_dis._roll), Math.abs(_activeVehicle.getSetpointRoll()), roll_neg.height) * errorHeight(r_dis.rollError, r_dis.height, 0) : 0
                            Behavior on height { SmoothedAnimation { velocity: smoothingFactor } }
                            states:[
                                State {
                                    name: "green"; when: roll_pos.height / (r_dis.height / 2) < .333
                                    PropertyChanges {target: roll_pos; color: "green"}
                                },
                                State {
                                    name: "yellow"; when: roll_pos.height / (r_dis.height / 2) >= .333 && roll_pos.height / (r_dis.height / 2) < .667
                                    PropertyChanges {target: roll_pos; color: "yellow"}
                                },
                                State {
                                    name: "red"; when: roll_pos.height / (r_dis.height / 2) <= 1 && roll_pos.height / (r_dis.height / 2) >= .667
                                    PropertyChanges {target: roll_pos; color: "red"}
                                },
                                State {
                                    name: "max"; when: maximum_error[0]
                                    PropertyChanges {target: roll_pos; color: "darkred"}
                                }
                            ]
                            transitions:[
                                Transition{
                                    from: "green"; to: "yellow"; reversible: true
                                    ParallelAnimation{
                                        ColorAnimation { duration: 20 }
                                    }
                                },
                                Transition{
                                    from: "yellow"; to: "red"; reversible: true
                                    ParallelAnimation{
                                        ColorAnimation { duration: 20 }
                                    }
                                },
                                Transition{
                                    from: "red"; to: "max"; reversible: true
                                    ParallelAnimation{
                                        ColorAnimation { duration: 20 }
                                    }
                                }
                            ]
                        }
                        Rectangle{
                            id: roll_neg
                            width: r_dis.width / 1.25
                            anchors.top: r_dis.verticalCenter
                            anchors.horizontalCenter: r_dis.horizontalCenter
                            anchors.bottomMargin: 2
                            color: "green"
                            height: _activeVehicle ? neg(Math.abs(r_dis._roll), Math.abs(_activeVehicle.getSetpointRoll()), roll_pos.height) * errorHeight(r_dis.rollError, r_dis.height, 0) : 0
                            Behavior on height { SmoothedAnimation { velocity: smoothingFactor } }
                            states:[
                                State {
                                    name: "green"; when: roll_neg.height / (r_dis.height / 2) < .333
                                    PropertyChanges {target: roll_neg; color: "green"}
                                },
                                State {
                                    name: "yellow"; when: roll_neg.height / (r_dis.height / 2) >= .333 && roll_neg.height / (r_dis.height / 2) < .667
                                    PropertyChanges {target: roll_neg; color: "yellow"}
                                },
                                State {
                                    name: "red"; when: roll_neg.height / (r_dis.height / 2) <= 1 && roll_neg.height / (r_dis.height / 2) >= .667
                                    PropertyChanges {target: roll_neg; color: "red"}
                                },
                                State {
                                    name: "max"; when: maximum_error[0]
                                    PropertyChanges {target: roll_neg; color: "darkred"}
                                }
                            ]
                            transitions:[
                                Transition{
                                    from: "green"; to: "yellow"; reversible: true
                                    ParallelAnimation{
                                        ColorAnimation { duration: 20 }
                                    }
                                },
                                Transition{
                                    from: "yellow"; to: "red"; reversible: true
                                    ParallelAnimation{
                                        ColorAnimation { duration: 20 }
                                    }
                                },
                                Transition{
                                    from: "red"; to: "max"; reversible: true
                                    ParallelAnimation{
                                        ColorAnimation { duration: 20 }
                                    }
                                }
                            ]
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
                        property real heading: _activeVehicle ? Math.abs(actualNormalize(_activeVehicle.heading.value)) : 0
                        property real yawError: _activeVehicle ? (Math.abs(heading - Math.abs(_activeVehicle.getSetpointYaw()))) / 180 : 0
                        states: [
                            State {
                                name: "pos"
                                when: yaw_pos.height > 0
                                PropertyChanges {
                                    target: yaw_neg
                                    height: 0
                                }
                            },
                            State {
                                name: "neg"
                                when: yaw_neg.height > 0
                                PropertyChanges {
                                    target: yaw_pos
                                    height: 0
                                }
                            }
                        ]
                        transitions: [
                            Transition {
                                from: "pos"; to: "neg"; reversible: false
                                NumberAnimation {
                                    target: yaw_pos
                                    property: height
                                    duration: 20
                                    easing.type: Easing.OutExpo
                                    to: 0
                                }
                            },
                            Transition {
                                from: "neg"; to: "pos"; reversible: false
                                NumberAnimation {
                                    target: yaw_neg
                                    property: height
                                    duration: 20
                                    easing.type: Easing.OutExpo
                                    to: 0
                                }
                            }
                        ]

                        Text{
                            text: "Y"
                            anchors.top: y_dis.bottom
                            anchors.horizontalCenter: y_dis.horizontalCenter
                        }
                        Rectangle{
                            id: yaw_pos
                            width: y_dis.width / 1.25
                            anchors.bottom: y_dis.verticalCenter
                            anchors.horizontalCenter: y_dis.horizontalCenter
                            anchors.bottomMargin: 2
                            color: "green"
                            height: _activeVehicle ? pos(Math.abs(y_dis.heading), Math.abs(_activeVehicle.getSetpointYaw()), yaw_neg.height) * errorHeight(y_dis.yawError, y_dis.height, 2) : 0
                            Behavior on height { SmoothedAnimation { velocity: smoothingFactor } }
                            states:[
                                State {
                                    name: "green"; when: yaw_pos.height / (y_dis.height / 2) < .333
                                    PropertyChanges {target: yaw_pos; color: "green"}
                                },
                                State {
                                    name: "yellow"; when: yaw_pos.height / (y_dis.height / 2) >= .333 && yaw_pos.height / (y_dis.height / 2) < .667
                                    PropertyChanges {target: yaw_pos; color: "yellow"}
                                },
                                State {
                                    name: "red"; when: yaw_pos.height / (y_dis.height / 2) <= 1 && yaw_pos.height / (y_dis.height / 2) >= .667
                                    PropertyChanges {target: yaw_pos; color: "red"}
                                },
                                State {
                                    name: "max"; when: maximum_error[2]
                                    PropertyChanges {target: yaw_pos; color: "darkred"}
                                }
                            ]
                            transitions:[
                                Transition{
                                    from: "green"; to: "yellow"; reversible: true
                                    ParallelAnimation{
                                        ColorAnimation { duration: 20 }
                                    }
                                },
                                Transition{
                                    from: "yellow"; to: "red"; reversible: true
                                    ParallelAnimation{
                                        ColorAnimation { duration: 20 }
                                    }
                                },
                                Transition{
                                    from: "red"; to: "max"; reversible: true
                                    ParallelAnimation{
                                        ColorAnimation { duration: 20 }
                                    }
                                }
                            ]
                        }
                        Rectangle{
                            id: yaw_neg
                            width: y_dis.width / 1.25
                            anchors.top: y_dis.verticalCenter
                            anchors.horizontalCenter: y_dis.horizontalCenter
                            anchors.bottomMargin: 2
                            color: "green"
                            height: _activeVehicle ? neg(Math.abs(y_dis.heading), Math.abs(_activeVehicle.getSetpointYaw()), yaw_pos.height) * errorHeight(y_dis.yawError, y_dis.height, 2) : 0
                            Behavior on height { SmoothedAnimation { velocity: smoothingFactor } }
                            states:[
                                State {
                                    name: "green"; when: yaw_neg.height / (y_dis.height / 2) < .333
                                    PropertyChanges {target: yaw_neg; color: "green"}
                                },
                                State {
                                    name: "yellow"; when: yaw_neg.height / (y_dis.height / 2) >= .333 && yaw_neg.height / (y_dis.height / 2) < .667
                                    PropertyChanges {target: yaw_neg; color: "yellow"}
                                },
                                State {
                                    name: "red"; when: yaw_neg.height / (y_dis.height / 2) <= 1 && yaw_neg.height / (y_dis.height / 2) >= .667
                                    PropertyChanges {target: yaw_neg; color: "red"}
                                },
                                State {
                                    name: "max"; when: maximum_error[2]
                                    PropertyChanges {target: yaw_neg; color: "darkred"}
                                }
                            ]
                            transitions:[
                                Transition{
                                    from: "green"; to: "yellow"; reversible: true
                                    ParallelAnimation{
                                        ColorAnimation { duration: 20 }
                                    }
                                },
                                Transition{
                                    from: "yellow"; to: "red"; reversible: true
                                    ParallelAnimation{
                                        ColorAnimation { duration: 20 }
                                    }
                                },
                                Transition{
                                    from: "red"; to: "max"; reversible: true
                                    ParallelAnimation{
                                        ColorAnimation { duration: 20 }
                                    }
                                }
                            ]
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
                            text: "5"
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
                            text: "-5"
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
                            text: "0"
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
                        height: buttons.width / 8
                        width: buttons.width / 2.75
                        anchors.right: buttons.horizontalCenter
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
                                PropertyChanges {target: train_button; enabled: true }
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
                                PropertyChanges {target: train_button; enabled: false }
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
                            width: rc_button.width
                            height: rc_button.height
                            text: "RC"
                            palette.buttonText: "white"
                            palette.button: "steelblue"
                            Rectangle{
                                width: rc_button.width
                                height: rc_button.height
                                border.color: rc_button.rc_border_color
                                border.width: 1.25
                                color: "transparent"
                            }

                            onClicked: {
                                rc_button.state = (rc_button.state === 'off_rc' ? 'on_rc' : "off_rc");
                                //switch rc pid
                                paramController.changeValue("RC_OR_PID", _root.rc_or_pid);
                            }
                        }
                    }

                    Rectangle{
                        id: train_button
                        height: buttons.width / 8
                        width: buttons.width / 2.75
                        anchors.right: buttons.right
                        anchors.top: buttons.top
                        anchors.rightMargin: p_dis.width
                        color: "black"
                        states: [
                            State {
                                name: "train_on"
                                PropertyChanges {target: train_button_control; palette.button : "green"}
                                PropertyChanges {target: train_button; opacity : 1}
                                PropertyChanges {target: train_button; enabled: false }
                                PropertyChanges {target: rc_button; enabled: false }
                                PropertyChanges {target: slider; enabled: false }
                            },
                            State {
                                name: "train_off"
                                PropertyChanges {target: train_button_control; palette.button : "black"}
                                PropertyChanges {target: train_button; opacity : 1}
                                PropertyChanges {target: train_button; enabled: false }
                                PropertyChanges {target: slider; enabled: true }
                            }
                        ]
                        transitions: [
                            Transition {
                                from: "train_off"; to: "train_on"; reversible: true
                            }
                        ]
                        Button{
                            id: train_button_control
                            width: rc_button.width
                            height: rc_button.height
                            text: "Train"
                            palette.text: "white"
                            anchors.horizontalCenter: train_button.horizontalCenter
                            anchors.verticalCenter: train_button.verticalCenter
                            palette.buttonText: "white"
                            palette.button: "black"
                            onClicked: {
                                train_button.state = (train_button.state === 'train_on' ? 'train_off' : "train_on");

                                if (slider.value <= 15 ) {
                                    timer_value.interval = slider.value * 1000
                                    timer_value.start()
                                } else {
                                    timer_value.interval = 10000
                                    timer_value.start()
                                }
                            }
                        }

                        Timer{
                            id: timer_value
                            running: false; repeat: false
                            onTriggered: train_button.state = 'on_rc'
                        }
                    }
                    Slider {
                        id: slider
                        anchors.bottom: rc_button.top
                        anchors.right: rc_button.left
                        anchors.horizontalCenterOffset: rc_button.width
                        from: 0; to: 15; stepSize: 5
                        value: 0
                        ToolTip {
                                parent: slider.handle
                                visible: slider.pressed
                                text: slider.valueAt(slider.position).toFixed(1)
                            }
                    }

                    Button {
                        id: armed_button
                        background: Rectangle{
                            color: "green"
                            id: button_comp

                        states: [
                            State {
                                name: "armed"
                                PropertyChanges { target: button_comp; color: "red" }
                            },
                            State {
                                name: "disarmed"
                                PropertyChanges { target: button_comp; color: "green" }
                            }
                        ]

                        transitions: [
                            Transition {
                                from: "disarmed"; to: "armed"; reversible: true
                            }
                        ]
                        }

                        anchors.bottom: buttons.top
                        anchors.horizontalCenter: buttons.horizontalCenter
                        anchors.bottomMargin: train_button.height / 3
                        property bool   _armed:         _activeVehicle ? _activeVehicle.armed : false
                        Layout.alignment:   Qt.AlignHCenter
                        text:               _armed ?  qsTr("Armed") : (forceArm ? qsTr("Force Arm") : qsTr("Disarmed"))

                        property bool forceArm: false

                        onTextChanged: {
                            if (_armed == true) {
                            button_comp.state = 'armed'
                            } else {
                                button_comp.state = 'disarmed'
                            }
                        }

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
                        text: _activeVehicle ? "Roll: " + r_dis._roll.toFixed(5) : null
                    }
                    Text{
                        id: actPitch
                        anchors.top: actRoll.bottom
                        text: _activeVehicle ? "Pitch: " + p_dis._pitch.toFixed(5) : null
                    }
                    Text{
                        id: actYaw
                        anchors.top: actPitch.bottom
                        text: _activeVehicle ? "Yaw: " + y_dis.heading.toFixed(5) : null
                    }
                    Text{
                        id: estRoll
                        anchors.top: actYaw.bottom
                        text: _activeVehicle ? "Setpoint Roll: " + setpoint_roll.toFixed(5) : null
                        color: "orange"
                    }
                    Text{
                        id: estPitch
                        anchors.top: estRoll.bottom
                        text: _activeVehicle ? "Setpoint Pitch: " + setpoint_pitch.toFixed(5) : null
                        color: "orange"
                    }
                    Text{
                        id: estYaw
                        anchors.top: estPitch.bottom
                        text: _activeVehicle ? "Setpoint Yaw: " + Math.abs(setpoint_yaw).toFixed(5) : null
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
                        //text: _activeVehicle ? "Weighted Yaw Error %: " + errorHeight(yaw_graph.yawError, y_dis.height, 2) / 20 : null
                        color: "green"
                    }
                    Text{
                        id: oRollPercent
                        anchors.top: nYawPercent.bottom
                        text: _activeVehicle ? "Yaw Error %: " + y_dis.yawError * 100 : 0
                        color: "red"
                    }
                    Text{
                        id: oPitchPercent
                        anchors.top: oRollPercent.bottom
                        text: _activeVehicle ? "Roll Error %: " + r_dis.rollError * 100 : 0
                        color: "red"
                    }
                    Text{
                        id: oYawPercent
                        anchors.top: oPitchPercent.bottom
                        text: _activeVehicle ? "Pitch Error %: " + p_dis.pitchError * 100 : 0
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

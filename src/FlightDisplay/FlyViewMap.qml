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
import QtQuick.Shapes 1.3
import QtQuick.Controls.Styles 1.4

import QGroundControl.Airmap        1.0
import QGroundControl.FactControls  1.0


FlightMap {
    id:                         _root
    property double batt // PreFlightBatteryCheck ? _activeVehicle.batteries.get(0).percentRemaining.rawValue : 0
    property var    curSystem:          controller ? controller.activeSystem : null
    property var    curMessage:         curSystem && curSystem.messages.count ? curSystem.messages.get(curSystem.selected) : null
    property int    curCompID:          0
    property real   maxButtonWidth:     0
    //variable to keep track of rc/pid state
    property int rc_or_pid:1
    property int train:0
    property bool maximum_error: [false, false, false]
    property int smoothingFactor: 100  //lower = smoother
    property real error_bar_max:     paramController.getValue('Rerror_color_maximum')
    property real error_bar_med:     paramController.getValue('Rerror_color_medium')
    property real error_bar_min:     paramController.getValue('Rerror_color_minimum')


    property real error_bar_height:     paramController.getValue('error_range')
    property real rpm_color_low_min:    paramController.getValue('RPM_color_low_min')
    property real rpm_color_low_max:    paramController.getValue('RPM_color_low_max')
    property real rpm_color_mid_max:    paramController.getValue('RPM_color_mid_max')
    property real rpm_color_high_max:   paramController.getValue('RPM_color_high_max')
    property real rpm_color_mid:        paramController.getValue('RPM_color_mid')
    property real rpm_color_high:       paramController.getValue('RPM_color_high')

    property real error_color_min:   paramController.getValue('error_color_minimum')
    property real error_color_med:   paramController.getValue('error_color_medium')
    property real error_color_max:   paramController.getValue('error_color_maximum')

    property color color_rpm_min: paramController.getColor('color_rpm_min')
    property color color_rpm_med: paramController.getColor('color_rpm_med')
    property color color_rpm_max: paramController.getColor('color_rpm_max')

    property color color_batt_min: paramController.getColor('color_batt_min')
    property color color_batt_med: paramController.getColor('color_batt_med')
    property color color_batt_max: paramController.getColor('color_batt_max')

    property double batt_low: paramController.getValue('batt_low')
    property double batt_mid: paramController.getValue('batt_mid')

    property color color_error_min: paramController.getColor('color_error_min')
    property color color_error_med: paramController.getColor('color_error_med')
    property color color_error_max: paramController.getColor('color_error_max')

    property bool _errorDisp: paramController.getValue('error')
    property bool _droneDisp: paramController.getValue('drone')
    property bool _batteryDisp: paramController.getValue('battery')
    property bool _buttonsDisp: paramController.getValue('buttons')
    property bool _windDisp: paramController.getValue('windDisplay')
    property bool _woutDisp: paramController.getValue('wout')
    property bool _minmaxDisp: paramController.getValue('minmax')

    property FactGroup weatherFactGroup: paramController.vehicle.getFactGroup("wind")
    property Fact windDirection: weatherFactGroup.getFact("direction")
    property Fact windSpeed: weatherFactGroup.getFact("speed")

    property int top_left_val: 0
    property int top_left_min
    property int top_left_max

    property int top_right_val: 0
    property int top_right_min
    property int top_right_max

    property int bottom_left_val: 0
    property int bottom_left_min
    property int bottom_left_max

    property int bottom_right_val: 0
    property int bottom_right_min
    property int bottom_right_max

    property int first: 1


    Timer {
        id:         update_custo
        interval:   1
        running:    true
        repeat: true
        onTriggered: {

            error_bar_max      =    paramController.getValue('Rerror_color_maximum')
            rpm_color_low_min  =    paramController.getValue('RPM_color_low_min')
            rpm_color_low_max  =    paramController.getValue('RPM_color_low_max')
            rpm_color_mid_max  =    paramController.getValue('RPM_color_mid_max')
            rpm_color_high_max =    paramController.getValue('RPM_color_high_max')

            rpm_color_mid      =    paramController.getValue('RPM_color_mid')
            rpm_color_high     =    paramController.getValue('RPM_color_high')

            error_color_min    =    paramController.getValue('error_color_minimum')
            error_color_med    =    paramController.getValue('error_color_medium')
            error_color_max    =    paramController.getValue('error_color_maximum')

            color_rpm_min      =    paramController.getColor('color_rpm_min')
            color_rpm_med      =    paramController.getColor('color_rpm_med')
            color_rpm_max      =    paramController.getColor('color_rpm_max')
            color_error_min    =    paramController.getColor('color_error_min')
            color_error_med    =    paramController.getColor('color_error_med')
            color_error_max    =    paramController.getColor('color_error_max')

            _errorDisp         =    paramController.getValue('error')
            _droneDisp         =    paramController.getValue('drone')
            _batteryDisp       =    paramController.getValue('battery')
            _buttonsDisp       =    paramController.getValue('buttons')
            _windDisp          =    paramController.getValue('windDisplay')
            _woutDisp          =    paramController.getValue('wout')
            _minmaxDisp        =    paramController.getValue('minmax')

            color_batt_min     =    paramController.getColor('color_batt_min')
            color_batt_med     =    paramController.getColor('color_batt_med')
            color_batt_max     =    paramController.getColor('color_batt_max')

            batt_low           =    paramController.getValue('batt_low')
            batt_mid           =    paramController.getValue('batt_mid')

            if(_activeVehicle){
                //Live Flight
                if(_activeVehicle.servoRaw.value < 1 || _activeVehicle.servoRaw2.value < 1 || _activeVehicle.servoRaw3.value < 1 || _activeVehicle.servoRaw4.value < 1){
                    top_left_val       =    _activeVehicle.chanRaw3.value
                    top_right_val      =    _activeVehicle.chanRaw1.value
                    bottom_left_val    =    _activeVehicle.chanRaw2.value
                    bottom_right_val   =    _activeVehicle.chanRaw4.value
                }
                //Simulated Flight
                else if(_activeVehicle.chanRaw3.value < 1 || _activeVehicle.chanRaw1.value < 1 || _activeVehicle.chanRaw2.value < 1 || _activeVehicle.chanRaw4.value < 1){
                    top_left_val       =    _activeVehicle.servoRaw3.value
                    top_right_val      =    _activeVehicle.servoRaw.value
                    bottom_left_val    =    _activeVehicle.servoRaw2.value
                    bottom_right_val   =    _activeVehicle.servoRaw4.value
                }
                else{
                    top_left_val       =    0
                    top_right_val      =    0
                    bottom_left_val    =    0
                    bottom_right_val   =    0
                }
            }
            else{
                top_left_val       =    0
                top_right_val      =    0
                bottom_left_val    =    0
                bottom_right_val   =    0
            }
            if(_activeVehicle)
            {
                //batt           =   (_activeVehicle.batteries.get(0).percentRemaining.rawValue)
            }
            if(train_button.state === 'train_on'){
                if(first === 1){
                    top_left_min = top_left_val
                    top_left_max = top_left_val

                    top_right_min = top_right_val
                    top_right_max = top_right_val

                    bottom_left_min = bottom_left_val
                    bottom_left_max = bottom_left_val

                    bottom_right_min = bottom_right_val
                    bottom_right_max = bottom_right_val

                    first = 0
                }
                if(top_left_val > top_left_max){
                    top_left_max = top_left_val
                }
                if(top_left_val < top_left_min){
                    top_left_min = top_left_val
                }

                if(top_right_val > top_right_max){
                    top_right_max = top_right_val
                }
                if(top_right_val < top_right_min){
                    top_right_min = top_right_val
                }

                if(bottom_left_val > bottom_left_max){
                    bottom_left_max = bottom_left_val
                }
                if(bottom_left_val < bottom_left_min){
                    bottom_left_min = bottom_left_val
                }

                if(bottom_right_val > bottom_right_max){
                    bottom_right_max = bottom_right_val
                }
                if(bottom_right_val < bottom_right_min){
                    bottom_right_min = bottom_right_val
                }
            }
            else{
                first = 1
            }
        }
    }
    function widthOfBackground(start_width){
        if((_droneDisp || _batteryDisp || _windDisp)  && !_buttonsDisp && !_woutDisp){
            return start_width * (2.0 / 3)
        }
        else if(!_droneDisp && !_batteryDisp && !_windDisp  && !_buttonsDisp && !_woutDisp  && _errorDisp){
            return start_width * (1 / 4.5)
        }
        else if(!_droneDisp && !_batteryDisp && !_windDisp  && !_buttonsDisp && !_woutDisp  && !_errorDisp){
            return 0
        }
        else{
            return start_width
        }
    }

    function errorHeight(error, height, index){
        if(error * height / 2 * (100 / error_bar_max) > height / 2){
            maximum_error[index] = true
            return height / 2
        }
        else{
            maximum_error[index] = false
            return error * height / 2 * (100 / error_bar_max)
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
//            Item{
//                id: battery_bar

//                width: parent.width/15
//                x: parent.width<parent.height?parent.width:parent.height
//                height: width
//                anchors.right: parent.right
//                anchors.top: drone.bottom
//                anchors.rightMargin: 2.5 * (top_left_prop.width)
//                anchors.bottomMargin: 1 * top_left_prop.width
//                visible: _batteryDisp
//                Rectangle{
//                    z: 10

//                    id: battery_outline_faux
//                    height: buttons.width / 8
//                    width: buttons.width / 2.725 // 3         //2.825
//                    anchors.verticalCenter: battery_bar.verticalCenter
//                    anchors.horizontalCenter: battery_bar.horizontalCenter
//                    visible: false
//                    radius: 8
//                }
//                Rectangle{
//                    z: 10

//                    id: battery_outline
//                    height: buttons.width / 7.75 //8
//                    width: buttons.width / 2.5     //2.75
//                    anchors.verticalCenter: battery_bar.verticalCenter
//                    anchors.horizontalCenter: battery_bar.horizontalCenter
//                    color: "black"
//                    radius: 8
//                    border.color: "white"
//                    border.width: 3
//                }
//                Rectangle{
//                    z: 10

//                    id: battery_outline_2
//                    height: buttons.width / 7.5
//                    width: buttons.width / 2.4125
//                    anchors.verticalCenter: battery_bar.verticalCenter
//                    anchors.horizontalCenter: battery_bar.horizontalCenter
//                    color: "transparent"
//                    radius: 8
//                    border.color: "black"
//                    border.width: 2

//                }
//                Rectangle{
//                    z: 10

//                    id: battery_ornate
//                    height: battery_outline.height / 3.25
//                    width: height / 2
//                    anchors.right: battery_outline_2.left
//                    anchors.verticalCenter: battery_outline.verticalCenter
//                    color: "white"
//                    radius: 8
//                    border.color: "black"
//                    border.width: 1
//                }

//                Rectangle{
//                    z: 10

//                    id: battery
//                    height: battery_outline.height / 1.425   //1.2 //1.325
//                    width: (battery_outline.width / 1.0925) * (batt / 100)  //1.0725
//                    anchors.right: battery_outline_faux.right
//                    anchors.verticalCenter: battery_bar.verticalCenter
//                    radius: 2
//                    Text {
//                        color: "white"
//                        //anchors.left: parent.right
//                        anchors.horizontalCenter: parent.horizontalCenter
//                        anchors.verticalCenter: parent.verticalCenter
//                        visible:  batt > 40
//                        font.pointSize: 12
//                        style: Text.Outline
//                        styleColor: "black"
//                        text: batt + "%"
//                    }
//                    Text {
//                        color: "white"
//                        anchors.right: parent.left
//                        anchors.verticalCenter: parent.verticalCenter
//                        visible:  batt <= 40
//                        font.pointSize: 12
//                        style: Text.Outline
//                        styleColor: "black"
//                        text: batt + "%"
//                    }
//                    states:[
//                        State {
//                            name: "green"; when: batt > 70
//                            PropertyChanges {target: battery; color: color_batt_max}
//                        },
//                        State {
//                            name: "yellow"; when:batt > 20 && batt <= 70
//                            PropertyChanges {target: battery; color: color_batt_med}
//                        },
//                        State {
//                            name: "red"; when: batt <= 20
//                            PropertyChanges {target: battery; color: color_batt_min}
//                        }
//                    ]
//                    transitions:[
//                        Transition{
//                            from: "green"; to: "yellow"; reversible: true
//                            ParallelAnimation{
//                                ColorAnimation { duration: 1000 }
//                            }
//                        },
//                        Transition{
//                            from: "yellow"; to: "red"; reversible: true
//                            ParallelAnimation{
//                                ColorAnimation { duration: 1000 }
//                            }
//                        }
//                    ]

//                }


//            }
            Rectangle{
                id: borders
                width: parent.width/15
                x: parent.width<parent.height?parent.width:parent.height
                height: width / 4
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.rightMargin: 2.5*(top_left_prop.width)
                anchors.bottomMargin: top_left_prop.width
                visible: false
            }

            Item{
                id: drone
                width: parent.width/15
                x: parent.width<parent.height?parent.width:parent.height
                z: 10
                height: width
                anchors.right: parent.right
                anchors.bottom: borders.top
                anchors.rightMargin: 2.5*(top_left_prop.width)
                anchors.bottomMargin: top_left_prop.width
                property real heading: _activeVehicle ? _activeVehicle.heading.rawValue : 0
                property real headingToWP: _activeVehicle ? calculateTravelDirection() : 0
                property real groundSpeed: _activeVehicle ? _activeVehicle.groundSpeed.value : 0
                function calculateTravelDirection(){
                    //How to find??
                    return 0;
                }

                function getHeadingDisplay(){
                    if(heading.toFixed(0) > 9 && heading.toFixed(0) < 100){
                        return '0' + heading.toFixed(0);
                    }

                    else if(heading.toFixed(0) < 10){
                        return '00' + heading.toFixed(0);
                    }
                    else{
                        return heading.toFixed(0) + '';
                    }
                }
                function getTravelHeadingDisplay(){

                    return getHeadingDisplay();

//                    if(headingToWP.toFixed(0) > 9 && headingToWP.toFixed(0) < 100){
//                        return '0' + headingToWP.toFixed(0);
//                    }

//                    else if(headingToWP.toFixed(0) < 10){
//                        return '00' + headingToWP.toFixed(0);
//                    }
//                    else{
//                        return headingToWP.toFixed(0) + '';
//                    }
                }
                function getWindHeadingDisplay(){
                    if(windDirection.rawValue.toFixed(0) > 9 && windDirection.rawValue.toFixed(0) < 100){
                        return '0' + windDirection.rawValue.toFixed(0);
                    }

                    else if(windDirection.rawValue.toFixed(0) < 10){
                        return '00' + windDirection.rawValue.toFixed(0);
                    }
                    else{
                        return windDirection.rawValue.toFixed(0) + '';
                    }
                }
                Rectangle{
                    id: battery_bar
                    z: 10

                    //width: parent.width/15
                    //x: parent.width<parent.height?parent.width:parent.height
                    //height: width
                    anchors.horizontalCenter: drone.horizontalCenter
                    anchors.top: bottom_left_prop.verticalCenter
                    anchors.topMargin: .65 * top_left_prop.width
                    visible: _batteryDisp
                    Rectangle{
                        z: 10

                        id: battery_outline_faux
                        height: buttons.width / 8
                        width: buttons.width / 2.725 // 3         //2.825
                        anchors.verticalCenter: battery_bar.verticalCenter
                        anchors.horizontalCenter: battery_bar.horizontalCenter
                        visible: false
                        radius: 8
                    }
                    Rectangle{
                        z: 10

                        id: battery_outline
                        height: buttons.width / 7.75 //8
                        width: buttons.width / 2.5     //2.75
                        anchors.verticalCenter: battery_bar.verticalCenter
                        anchors.horizontalCenter: battery_bar.horizontalCenter
                        color: "black"
                        radius: 8
                        border.color: "white"
                        border.width: 3
                    }
                    Rectangle{
                        z: 10

                        id: battery_outline_2
                        height: buttons.width / 7.5
                        width: buttons.width / 2.4125
                        anchors.verticalCenter: battery_bar.verticalCenter
                        anchors.horizontalCenter: battery_bar.horizontalCenter
                        color: "transparent"
                        radius: 8
                        border.color: "black"
                        border.width: 2

                    }
                    Rectangle{
                        z: 10

                        id: battery_ornate
                        height: battery_outline.height / 3.25
                        width: height / 2
                        anchors.right: battery_outline_2.left
                        anchors.verticalCenter: battery_outline.verticalCenter
                        color: "white"
                        radius: 8
                        border.color: "black"
                        border.width: 1
                    }

                    Rectangle{
                        z: 10

                        id: battery
                        height: battery_outline.height / 1.425   //1.2 //1.325
                        width: (battery_outline.width / 1.0925) * (batt / 100)  //1.0725
                        anchors.right: battery_outline_faux.right
                        anchors.verticalCenter: battery_bar.verticalCenter
                        radius: 2
                        Text {
                            color: "white"
                            //anchors.left: parent.right
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.verticalCenter: parent.verticalCenter
                            visible:  batt > 40
                            font.pointSize: 12
                            style: Text.Outline
                            styleColor: "black"
                            text: batt + "%"
                        }
                        Text {
                            color: "white"
                            anchors.right: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            visible:  batt <= 40
                            font.pointSize: 12
                            style: Text.Outline
                            styleColor: "black"
                            text: batt + "%"
                        }
                        states:[
                            State {
                                name: "green"; when: batt > batt_mid
                                PropertyChanges {target: battery; color: color_batt_max}
                            },
                            State {
                                name: "yellow"; when:batt > batt_low && batt <= batt_mid
                                PropertyChanges {target: battery; color: color_batt_med}
                            },
                            State {
                                name: "red"; when: batt <= batt_low
                                PropertyChanges {target: battery; color: color_batt_min}
                            }
                        ]
                        transitions:[
                            Transition{
                                from: "green"; to: "yellow"; reversible: true
                                ParallelAnimation{
                                    ColorAnimation { duration: 1000 }
                                }
                            },
                            Transition{
                                from: "yellow"; to: "red"; reversible: true
                                ParallelAnimation{
                                    ColorAnimation { duration: 1000 }
                                }
                            }
                        ]

                    }


                }
                Image {
                    z: 10

                    visible: _droneDisp
                    id: drone_center
                    width: drone.width / 1.25
                    height: width * 1.5
                    source: "/qmlimages/newDroneBody.png"
                    anchors.verticalCenter: drone.verticalCenter
                    anchors.horizontalCenter: drone.horizontalCenter
                }
                Rectangle{
                    z: 10

                    visible: _windDisp
                    id: vehicleHeadingDisplay
                    width: drone.width / 3
                    height: width / 2
                    anchors.horizontalCenter: drone_center.horizontalCenter
                    anchors.top: vehicleDisplayAnchors.top
                    color: 'white'
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        visible:                true
                        text: _activeVehicle ? drone.getHeadingDisplay() + '°' : '--.--'
                    }
                    border.color: 'black'
                    border.width: 1.5
                }
                Rectangle{
                    z: 10

                    visible: _windDisp

                    id: vehicleHeadingDisplay_tic_main
                    width: vehicleHeadingDisplay.width / 16
                    height: vehicleHeadingDisplay.width / 4
                    anchors.horizontalCenter: drone_center.horizontalCenter
                    anchors.top: vehicleHeadingDisplay.bottom
                    color: 'black'
                    border.color: 'black'
                    border.width: 1.5
                }
                Rectangle{
                    z: 10

                    id: vehicleHeadingDisplay_tic_main_skele
                    width: vehicleHeadingDisplay_tic_main.width * 6
                    height: vehicleHeadingDisplay_tic_main.height * 1.5
                    anchors.horizontalCenter: vehicleHeadingDisplay_tic_main.horizontalCenter
                    anchors.verticalCenter: vehicleHeadingDisplay_tic_main.verticalCenter
                    color: 'black'
                    border.color: 'black'
                    border.width: 1
                    visible: false
                }
                Rectangle{
                    z: 10

                    visible: _windDisp

                    id: vehicleHeadingDisplay_tic_1L
                    width: vehicleHeadingDisplay_tic_main.width / 2
                    height: vehicleHeadingDisplay_tic_main.height / 1.5
                    anchors.bottom: vehicleHeadingDisplay_tic_main.bottom
                    anchors.right: vehicleHeadingDisplay_tic_main_skele.left
                    color: 'black'
                    rotation: 170
                }
                Rectangle{
                    z: 10

                    id: vehicleHeadingDisplay_tic_1L_skele
                    width: vehicleHeadingDisplay_tic_1L.width * 8
                    height: vehicleHeadingDisplay_tic_1L.height * 2
                    anchors.horizontalCenter: vehicleHeadingDisplay_tic_1L.horizontalCenter
                    anchors.verticalCenter: vehicleHeadingDisplay_tic_1L.verticalCenter
                    visible: false
                    color: 'black'
                    border.color: 'black'
                    border.width: 1
                }
                Rectangle{
                    visible: _windDisp
                    z: 10

                    id: vehicleHeadingDisplay_tic_2L
                    width: vehicleHeadingDisplay_tic_main.width / 2
                    height: vehicleHeadingDisplay_tic_main.height / 1.5
                    anchors.bottom: vehicleHeadingDisplay_tic_1L_skele.bottom
                    anchors.right: vehicleHeadingDisplay_tic_1L_skele.left
                    color: 'black'
                    rotation: 160
                }
                Rectangle{
                    visible: _windDisp
                    z: 10

                    id: vehicleHeadingDisplay_tic_1R
                    width: vehicleHeadingDisplay_tic_main.width / 2
                    height: vehicleHeadingDisplay_tic_main.height / 1.5
                    anchors.bottom: vehicleHeadingDisplay_tic_main.bottom
                    anchors.left: vehicleHeadingDisplay_tic_main_skele.right
                    color: 'black'
                    rotation: 190
                }
                Rectangle{
                    z: 10

                    id: vehicleHeadingDisplay_tic_1R_skele
                    width: vehicleHeadingDisplay_tic_1R.width * 8
                    height: vehicleHeadingDisplay_tic_1R.height * 2
                    anchors.horizontalCenter: vehicleHeadingDisplay_tic_1R.horizontalCenter
                    anchors.verticalCenter: vehicleHeadingDisplay_tic_1R.verticalCenter
                    visible: false
                    color: 'black'
                    border.color: 'black'
                    border.width: 1
                }
                Rectangle{
                    visible: _windDisp
                    z: 10

                    id: vehicleHeadingDisplay_tic_RL
                    width: vehicleHeadingDisplay_tic_main.width / 2
                    height: vehicleHeadingDisplay_tic_main.height / 1.5
                    anchors.bottom: vehicleHeadingDisplay_tic_1R_skele.bottom
                    anchors.left: vehicleHeadingDisplay_tic_1R_skele.right
                    color: 'black'
                    rotation: 200
                }
                Rectangle{
                    visible: _windDisp
                    z: 10

                    id: headingAnchors
                    anchors.verticalCenter: drone.verticalCenter
                    anchors.horizontalCenter: drone.horizontalCenter
                    width: drone_center.width * 2.5
                    height: drone_center.height * 2.75
                    color: "transparent"
                    //border.color: "black"
                    //border.width: 1
                    radius: width * .5
                }
                Rectangle{
                    visible: _windDisp
                    z: 10

                    id: vehicleDisplayAnchors
                    anchors.verticalCenter: headingAnchors.verticalCenter
                    anchors.horizontalCenter: headingAnchors.horizontalCenter
                    width: drone_center.width
                    height: drone_center.height * 1.625
                    color: "transparent"
                    //border.color: "black"
                    //border.width: 1
                    radius: width * .5
                }
//                Rectangle{
//                    id: windIndicator
//                    Text {
//                        anchors.top: parent.top
//                        anchors.horizontalCenter: parent.horizontalCenter
//                        visible:                true
//                        text: _activeVehicle ? windSpeed.rawValue + 'm/s' : '-- m/s'
//                        font.pointSize: 8
//                    }
//                    Text {
//                        anchors.top: parent.bottom
//                        anchors.horizontalCenter: parent.horizontalCenter
//                        visible:                true
//                        text: _activeVehicle ? drone.getWindHeadingDisplay() + '°' : '--.--'
//                        font.pointSize: 8
//                    }
//                    width: drone.width / 2.5
//                    height: width * 1.5
//                    x: windArrowPath_top.x
//                    y: windArrowPath_top.y
//                    rotation: windArrowPath_top.angle
//                }
                function getGroundSpeed(){
                    if(drone.groundSpeed >= 10){
                        return drone.groundSpeed.toFixed(0);
                    }
                    else{
                        return drone.groundSpeed.toFixed(1);
                    }
                }
                function getWindIndicatorWidth(){
                        return 2 * (5 - drone.groundSpeed.toFixed(0));
                }
                function getTravelIndicatorWidth(){
                        return 2 * (5 - drone.groundSpeed.toFixed(0));
                }
                Image{

                    id: travelDirectionIndicator
                    visible: _activeVehicle ? _windDisp:false
                    source: "/qmlimages/blue_arrow.png"
                    z: 10000
                    Text {
                        anchors.bottom: travelDirectionIndicator_anchors2.bottom
                        anchors.horizontalCenter: parent.horizontalCenter
                        visible:                true
                        text: _activeVehicle ? drone.getHeadingDisplay() + '°' : '--.--'
                        font.pointSize: 8
                    }
                    Text {
                        anchors.top: travelDirectionIndicator_anchors.bottom
                        anchors.horizontalCenter: parent.horizontalCenter
                        visible:                true
                        text: _activeVehicle ? drone.getGroundSpeed() : ''
                        color: 'white'
                        font.pointSize: 10
                        font.bold: true
                    }
                    width: drone.width / 1.125
                    height: width - drone.getWindIndicatorWidth()
                    x: drone.get_travel_x()
                    y: drone.get_travel_y()
                    rotation:  drone.get_travel_angle()
                    Rectangle{
                        z: 10

                        id: travelDirectionIndicator_anchors
                        width: travelDirectionIndicator.width
                        height: travelDirectionIndicator.height / 6
                        visible: false
                        color: 'red'
                    }
                    Rectangle{
                        z: 10

                        id: travelDirectionIndicator_anchors2
                        width: travelDirectionIndicator.width / 6
                        height: travelDirectionIndicator.height * 1.05
                        visible: false
                        color: 'red'
                    }
                }
                Image{
                    id: _travelDirectionIndicator
                    visible: _activeVehicle ? _windDisp: false
                    source: "/qmlimages/white_arrow.png"
                    z: 10000
                    Text {
                        anchors.bottom: _travelDirectionIndicator_anchors.bottom
                        anchors.horizontalCenter: parent.horizontalCenter
                        visible:                true
                        text: _activeVehicle ? drone.getTravelHeadingDisplay() + '°' : '--.--'
                        font.pointSize: 8
                    }
                    Text {
                        anchors.bottom: _travelDirectionIndicator_anchors2.bottom
                        anchors.horizontalCenter: parent.horizontalCenter
                        visible:                true
                        text: _activeVehicle ? drone.getGroundSpeed() : ''
                        color: 'black'
                        font.pointSize: 10
                        font.bold: true
                    }
                    width: drone.width / 1.125
                    height: width - drone.getTravelIndicatorWidth()
                    x: drone.get_tdir_x()
                    y: drone.get_tdir_y()
                    rotation: drone.get_tdir_angle()
                    Rectangle{
                        id: _travelDirectionIndicator_anchors
                        width: _travelDirectionIndicator.width
                        height: _travelDirectionIndicator.height / 30
                        visible: false
                        color: 'red'
                        z: 10

                    }
                    Rectangle{
                        id: _travelDirectionIndicator_anchors2
                        width: _travelDirectionIndicator.width / 6
                        height: _travelDirectionIndicator.height * .85
                        visible: false
                        color: 'blue'
                        z: 10

                    }
                }


                property real firstBreak: 33
                property real secondBreak: 147
                property real thirdBreak: 213
                property real fourthBreak: 303
                property real fifthBreak: 0
                property real fifthBreak_360: 360

                function get_travel_x(){
                    return travelArrow_circ.x;
//                    if(drone.getHeadingDisplay() >= firstBreak && drone.getHeadingDisplay() < secondBreak){
//                        return travelArrowPath_top.x;
//                    }
//                    else if(drone.getHeadingDisplay() >= secondBreak && drone.getHeadingDisplay() < thirdBreak){
//                        return travelArrowPath_right.x;
//                    }
//                    else if(drone.getHeadingDisplay() >= thirdBreak && drone.getHeadingDisplay() < fourthBreak){
//                        return travelArrowPath_bottom.x;
//                    }
//                    else if(drone.getHeadingDisplay() >= fourthBreak && drone.getHeadingDisplay() <= fifthBreak_360){
//                        return travelArrowPath_left.x;
//                    }
//                    else if(drone.getHeadingDisplay() >= fifthBreak && drone.getHeadingDisplay() < firstBreak){
//                        return travelArrowPath_left_0_plus.x;
//                    }
                }
                function get_travel_y(){
                    return travelArrow_circ.y;
//                    if(drone.getHeadingDisplay() >= firstBreak && drone.getHeadingDisplay() < secondBreak){
//                        return travelArrowPath_top.y;
//                    }
//                    else if(drone.getHeadingDisplay() >= secondBreak && drone.getHeadingDisplay() < thirdBreak){
//                        return travelArrowPath_right.y;
//                    }
//                    else if(drone.getHeadingDisplay() >= thirdBreak && drone.getHeadingDisplay() < fourthBreak){
//                        return travelArrowPath_bottom.y;
//                    }
//                    else if(drone.getHeadingDisplay() >= fourthBreak && drone.getHeadingDisplay() <= fifthBreak_360){
//                        return travelArrowPath_left.y;
//                    }
//                    else if(drone.getHeadingDisplay() >= fifthBreak && drone.getHeadingDisplay() < firstBreak){
//                        return travelArrowPath_left_0_plus.y;
//                    }
                }
                function get_travel_angle(){
                    return travelArrow_circ.angle;
//                    if(drone.getHeadingDisplay() >= firstBreak && drone.getHeadingDisplay() < secondBreak){
//                        return travelArrowPath_top.angle;
//                    }
//                    else if(drone.getHeadingDisplay() >= secondBreak && drone.getHeadingDisplay() < thirdBreak){
//                        return 90;
//                        //travelArrowPath_right.angle;
//                    }
//                    else if(drone.getHeadingDisplay() >= thirdBreak && drone.getHeadingDisplay() < fourthBreak){
//                        return travelArrowPath_bottom.angle;
//                    }
//                    else if(drone.getHeadingDisplay() >= fourthBreak && drone.getHeadingDisplay() <= fifthBreak_360){
//                        return 270;
//                        //travelArrowPath_left.angle;
//                    }
//                    else if(drone.getHeadingDisplay() >= fifthBreak && drone.getHeadingDisplay() < firstBreak){
//                        return 270;
//                    }
                }
                function get_tdir_x(){
                    return travelDirection_circ.x;
                }
                function get_tdir_y(){
                    return travelDirection_circ.y;
                }
                function get_tdir_angle(){
                    return travelDirection_circ.angle;
                }

                PathInterpolator {
                    id: travelArrow_circ
                    path: Path {
                        startX: headingAnchors.x + headingAnchors.radius / 1.75; startY: headingAnchors.y - headingAnchors.radius / 4
                        PathArc {
                            x: headingAnchors.x + headingAnchors.radius / 1.75; y: headingAnchors.y + 2.5 * headingAnchors.radius
                            radiusX: headingAnchors.radius / 1.5; radiusY: headingAnchors.radius / 1.5
                            direction: PathArc.Clockwise
                        }
                        PathArc {
                            x: headingAnchors.x + headingAnchors.radius / 1.75; y: headingAnchors.y - headingAnchors.radius / 4
                            radiusX: headingAnchors.radius / 1.5; radiusY: headingAnchors.radius / 1.5
                            direction: PathArc.Clockwise
                        }
                    }
                    //NumberAnimation on progress { from: 0; to: 1; duration: 90000 }

                    progress: (drone.getHeadingDisplay() / drone.fifthBreak_360 )
                }
                PathInterpolator {
                    id: travelDirection_circ
                    path: Path {
                        startX: headingAnchors.x + headingAnchors.radius / 1.75; startY: headingAnchors.y - headingAnchors.radius / 4
                        PathArc {
                            x: headingAnchors.x + headingAnchors.radius / 1.75; y: headingAnchors.y + 2.5 * headingAnchors.radius
                            radiusX: headingAnchors.radius / 1.5; radiusY: headingAnchors.radius / 1.5
                            direction: PathArc.Clockwise
                        }
                        PathArc {
                            x: headingAnchors.x + headingAnchors.radius / 1.75; y: headingAnchors.y - headingAnchors.radius / 4
                            radiusX: headingAnchors.radius / 1.5; radiusY: headingAnchors.radius / 1.5
                            direction: PathArc.Clockwise
                        }
                    }
                    //NumberAnimation on progress { from: 1; to: 0; duration: 90000 }

                    progress: ((360 - drone.getHeadingDisplay()) / drone.fifthBreak_360 )
                }
                PathInterpolator {
                    id: travelArrowPath_top
                    path: Path {
                        startX: headingAnchors.x - 100; startY: headingAnchors.y
                        PathArc {
                            x: headingAnchors.x - 25 + 2 * radiusX; y: headingAnchors.y
                            radiusX: headingAnchors.radius * 1.25; radiusY: headingAnchors.radius / 1.25
                            direction: PathArc.Clockwise
                        }
                    }
                    //NumberAnimation on progress { from: 0; to: 1; duration: 20000 }

                    progress: (drone.getHeadingDisplay() - drone.firstBreak)/ (drone.secondBreak - drone.firstBreak)
                }
                PathInterpolator {
                    id: travelArrowPath_right
                    path: Path {
                        startX: headingAnchors.x - 25 + 2 * headingAnchors.radius * 1.25; startY: headingAnchors.y
                        PathLine{
                            x: headingAnchors.x - 25 + 2 * headingAnchors.radius * 1.25
                            y: - headingAnchors.y
                        }
                    }
                    //NumberAnimation on progress { from: 0; to: 1; duration: 20000 }

                    progress: (drone.getHeadingDisplay() - drone.secondBreak)/ (drone.thirdBreak - drone.secondBreak)
                }
//                Timer {
//                    interval:       1
//                    running:        true
//                    repeat:         true
//                    onTriggered:    travelArrowPath_left.updateLeftSideProgress()
//                }
//                PathInterpolator {
//                    id: travelArrowPath_left

//                    property real left_side_progress: 0

//                    function updateLeftSideProgress(){
//                        if(drone.getHeadingDisplay() >= 0 && drone.getHeadingDisplay() <= drone.firstBreak){
//                            left_side_progress = drone.getHeadingDisplay() + (360 - drone.fourthBreak);
//                        }
//                        else{
//                            left_side_progress = drone.getHeadingDisplay() - drone.fourthBreak;
//                        }
//                    }

//                    path: Path {
//                        startX: headingAnchors.x - 100; startY: -headingAnchors.y
//                        PathLine{
//                            x: headingAnchors.x - 100
//                            y: headingAnchors.y
//                        }
//                    }

//                    //NumberAnimation on progress { from: 0; to: 1; duration: 20000 }

//                    progress: left_side_progress / (drone.firstBreak + (360 - drone.fourthBreak))
//                }
                PathInterpolator {
                    id: travelArrowPath_left
                    path: Path {
                        startX: headingAnchors.x - 100; startY: -headingAnchors.y
                        PathLine{
                            x: headingAnchors.x - 100
                            y: headingAnchors.y * (57 / 90) //ratio
                        }
                    }

                    //NumberAnimation on progress { from: 0; to: 1; duration: 20000 }

                    progress: (drone.getHeadingDisplay() - drone.fourthBreak)/ (drone.fifthBreak_360 - drone.fourthBreak)
                }
                PathInterpolator {
                    id: travelArrowPath_left_0_plus

                    path: Path {
                        startX: headingAnchors.x - 100; startY: headingAnchors.y * (57 / 90)
                        PathLine{
                            x: headingAnchors.x - 100
                            y: headingAnchors.y
                        }
                    }

                    //NumberAnimation on progress { from: 0; to: 1; duration: 20000 }

                    progress: (drone.getHeadingDisplay())/ (drone.firstBreak)
                }

                PathInterpolator {
                    id: travelArrowPath_bottom
                    path: Path {
                        startX: headingAnchors.x - 25 + 2 * headingAnchors.radius * 1.25; startY: -headingAnchors.y
                        PathArc {
                            x: headingAnchors.x - 100; y: -headingAnchors.y
                            radiusX: headingAnchors.radius * 1.25; radiusY: headingAnchors.radius / 1.5
                            direction: PathArc.Clockwise
                        }
                    }
                    //NumberAnimation on progress { from: 0; to: 1; duration: 20000 }

                    progress: (drone.getHeadingDisplay() - drone.thirdBreak)/ (drone.fourthBreak - drone.thirdBreak)
                }
                PathInterpolator {
                    id: windArrowPath_top
                    path: Path {
                        startX: headingAnchors.x - 25; startY: headingAnchors.y

                        PathArc {
                            x: headingAnchors.x - 100 + 2 * radiusX; y: headingAnchors.y
                            radiusX: headingAnchors.radius * 1.25; radiusY: headingAnchors.radius / 2
                            direction: PathArc.Clockwise
                        }
                    }

                    NumberAnimation on progress { loops: 20; from: 0; to: 1;  duration: 20000 }
                }
                Rectangle {
                    visible: _droneDisp
                    z: 10
                    id: top_left_prop
                    width: drone.width / 1.35
                    height: width
                    color: "white"
                    states:[
                        State {
                            name: "green"; when: _activeVehicle && top_left_val < rpm_color_mid
                            PropertyChanges {target: top_left_prop; color: color_rpm_min}
                        },
                        State {
                            name: "yellow"; when: top_left_val >= rpm_color_mid && top_left_val < rpm_color_high
                            PropertyChanges {target: top_left_prop; color: color_rpm_med}
                        },
                        State {
                            name: "red"; when: top_left_val >= rpm_color_high
                            PropertyChanges {target: top_left_prop; color: color_rpm_max}
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
                        }
                    ]

                    border.color: "black"
                    border.width: 1
                    radius: width*0.5
                    anchors.top: drone.top
                    anchors.left: drone.left
                    anchors.topMargin: -top_left_prop.height / 1.65
                    anchors.leftMargin: -top_left_prop.width / 1.65
                    Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.verticalCenter: parent.verticalCenter
                            visible:                true
                            font.pointSize: 20
                            text:                   top_left_val
                    }
                }
                Text {
                    id: top_left_prop_min_max
                    z:1000
                    visible: _minmaxDisp
                    anchors.verticalCenter: top_left_prop.verticalCenter
                    anchors.right: top_left_prop.left
                    anchors.rightMargin: 2
                    text: top_left_max + '\n' + top_left_min
                }
                Rectangle {
                    visible: _droneDisp
                    z: 10

                    id: bottom_left_prop
                    width: top_left_prop.width
                    height: width
                    color: "white"
                    states:[
                        State {
                            name: "green"; when: _activeVehicle && bottom_left_val < rpm_color_mid
                            PropertyChanges {target: bottom_left_prop; color: color_rpm_min}
                        },
                        State {
                            name: "yellow"; when: bottom_left_val >= rpm_color_mid && bottom_left_val < rpm_color_high
                            PropertyChanges {target: bottom_left_prop; color: color_rpm_med}
                        },
                        State {
                            name: "red"; when: bottom_left_val >= rpm_color_high
                            PropertyChanges {target: bottom_left_prop; color: color_rpm_max}
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
                        }
                    ]

                    border.color: "black"
                    border.width: 1
                    radius: width*0.5
                    anchors.bottom: drone.bottom
                    anchors.left: drone.left
                    anchors.bottomMargin: -bottom_left_prop.height / 1.65
                    anchors.leftMargin: -bottom_left_prop.width / 1.65
                    Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.verticalCenter: parent.verticalCenter
                            visible:                true
                            font.pointSize: 20
                            text:                   bottom_left_val
                    }
                }
                Text {
                    id: bottom_left_prop_min_max
                    z:1000
                    visible: _minmaxDisp
                    anchors.verticalCenter: bottom_left_prop.verticalCenter
                    anchors.right: bottom_left_prop.left
                    anchors.rightMargin: 2
                    text: bottom_left_max + '\n' + bottom_left_min
                }
                Rectangle {
                    visible: _droneDisp
                    z: 10

                    id: bottom_right_prop
                    width: top_left_prop.width
                    height: width
                    color: "white"
                    states:[
                        State {
                            name: "green"; when: _activeVehicle && bottom_right_val < rpm_color_mid
                            PropertyChanges {target: bottom_right_prop; color: color_rpm_min}
                        },
                        State {
                            name: "yellow"; when: bottom_right_val >= rpm_color_mid && bottom_right_val < rpm_color_high
                            PropertyChanges {target: bottom_right_prop; color: color_rpm_med}
                        },
                        State {
                            name: "red"; when: bottom_right_val >= rpm_color_high
                            PropertyChanges {target: bottom_right_prop; color: color_rpm_max}
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
                        }
                    ]
                    border.color: "black"
                    border.width: 1
                    radius: width*0.5
                    anchors.bottom: drone.bottom
                    anchors.right: drone.right
                    anchors.bottomMargin: -bottom_right_prop.height / 1.65
                    anchors.rightMargin: -bottom_right_prop.width / 1.65
                    Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.verticalCenter: parent.verticalCenter
                            visible:                true
                            font.pointSize: 20
                            text:                   bottom_right_val
                    }
                }
                Text {
                    id: bottom_right_prop_min_max
                    z:1000
                    visible: _minmaxDisp
                    anchors.verticalCenter: bottom_right_prop.verticalCenter
                    anchors.left: bottom_right_prop.right
                    anchors.rightMargin: 2
                    text: bottom_right_max + '\n' + bottom_right_min
                }
                Rectangle {
                    visible: _droneDisp
                    z: 10

                    id: top_right_prop
                    width: top_left_prop.width
                    height: width
                    color: "white"
                    states:[
                        State {
                            name: "green"; when: _activeVehicle && top_left_val < rpm_color_mid
                            PropertyChanges {target: top_right_prop; color: color_rpm_min}
                        },
                        State {
                            name: "yellow"; when: top_left_val >= rpm_color_mid && top_left_val < rpm_color_high
                            PropertyChanges {target: top_right_prop; color: color_rpm_med}
                        },
                        State {
                            name: "red"; when: top_left_val >= rpm_color_high
                            PropertyChanges {target: top_right_prop; color: color_rpm_max}
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
                        }
                    ]

                    border.color: "black"
                    border.width: 1
                    radius: width*0.5
                    anchors.top: drone.top
                    anchors.right: drone.right
                    anchors.topMargin: -top_right_prop.height / 1.65
                    anchors.rightMargin: -top_right_prop.width / 1.65
                    Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.verticalCenter: parent.verticalCenter
                            visible:                true
                            font.pointSize: 20
                            text:                   top_right_val
                    }
                }

                Text {
                    id: top_right_prop_min_max
                    z:1000
                    visible: _minmaxDisp
                    anchors.verticalCenter: top_right_prop.verticalCenter
                    anchors.left: top_right_prop.right
                    anchors.rightMargin: 2
                    text: top_right_max + '\n' + top_right_min
                }
                    Rectangle{
                        visible: _buttonsDisp

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
                            visible: false
                            text: "On/Off"
                            onClicked: button.state = (button.state === 'off' ? 'on' : "off");
                        }
                }
                    Item{

                        id: buttons
                        width: 2.05*(drone.width)
                        height: 2.5*(drone.height)
                        anchors.verticalCenter: drone.verticalCenter
                        anchors.horizontalCenter: drone.horizontalCenter

                        Rectangle{
                            id: white_background_ghost
                            visible: false
                            z: 0
                            color: "white"
                            opacity: 0.5
                            width: (p_dis.width * 6.5 * 4.125)
                            height: p_dis.height * 1.2 * 2.7
                            anchors.left: sliderGhost.left
                            //anchors.rightMargin: 2
                            anchors.top: sliderGhost.top//p_dis.top
                            anchors.topMargin: -p_dis.width / 2
                            //anchors.leftMargin: -p_dis.width / 4

                        }
                        Rectangle{
                            id: white_background
                            visible: true
                            z: 0
                            color: "white"
                            opacity: 0.5
                            width: widthOfBackground(p_dis.width * 6.5 * 4.125)
                            height: white_background_ghost.height
                            anchors.right: white_background_ghost.right
                            anchors.top: white_background_ghost.top
                            anchors.topMargin: -p_dis.width / 2
                        }

                        Rectangle{
                            id: p_dis
                            z: 10
                            visible: _errorDisp
                            anchors.left: buttons.right
                            anchors.leftMargin: width / 1.5
                            anchors.top: buttons.top
                            anchors.topMargin: buttons.width / 3.5
                            height: buttons.height / 2
                            width: buttons.width / 10
                            color: "transparent"
                            border.color: "black"
                            border.width: 2
                            property real _pitch: _activeVehicle ? Math.abs(actualNormalize(_activeVehicle.pitch.value)) : 0
                            property real pitchError: _activeVehicle ? (Math.abs(_pitch - Math.abs(_activeVehicle.getSetpointPitch()))) / 180 : 0
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
                                z: 10

                                anchors.bottom: p_dis.verticalCenter
                                anchors.left: p_dis.left
                                anchors.right: p_dis.right
                                //anchors.topMargin: p_dis.border.width
                                anchors.leftMargin: p_dis.border.width
                                anchors.rightMargin: p_dis.border.width
                                color: "green"
                                height: _activeVehicle ? pos(Math.abs(p_dis._pitch), Math.abs(_activeVehicle.getSetpointPitch()), pitch_neg.height) * errorHeight(p_dis.pitchError, (p_dis.height - (p_dis.border.width * 2)), 1) : 0
                                Behavior on height { SmoothedAnimation { velocity: smoothingFactor } }
                                states:[
                                    State {
                                        name: "green"; when: pitch_pos.height / (p_dis.height / 2) < error_color_min
                                        PropertyChanges {target: pitch_pos; color: color_error_min}
                                    },
                                    State {
                                        name: "yellow"; when: pitch_pos.height / (p_dis.height / 2) >= error_color_min && pitch_pos.height / (p_dis.height / 2) < error_color_med
                                        PropertyChanges {target: pitch_pos; color: color_error_med}
                                    },
                                    State {
                                        name: "red"; when: pitch_pos.height / (p_dis.height / 2) <= error_color_max && pitch_pos.height / (p_dis.height / 2) >= error_color_med
                                        PropertyChanges {target: pitch_pos; color: color_error_max}
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
                                        from: "red"; to: "max"; reversible: true
                                        ParallelAnimation{
                                            ColorAnimation { duration: 500 }
                                        }
                                    }
                                ]
                            }
                            Rectangle{
                                id: pitch_neg
                                z: 10

                                anchors.top: p_dis.verticalCenter
                                anchors.left: p_dis.left
                                anchors.right: p_dis.right

                                //anchors.bottomMargin: p_dis.border.width * 2
                                anchors.leftMargin: p_dis.border.width
                                anchors.rightMargin: p_dis.border.width
                                color: "green"
                                height: _activeVehicle ? neg(Math.abs(p_dis._pitch), Math.abs(_activeVehicle.getSetpointPitch()), pitch_pos.height) * errorHeight(p_dis.pitchError, (p_dis.height - (p_dis.border.width * 2)), 1) : 0
                                Behavior on height { SmoothedAnimation { velocity: smoothingFactor } }
                                states:[
                                    State {
                                        name: "green"; when: pitch_neg.height / (p_dis.height / 2) < error_color_min
                                        PropertyChanges {target: pitch_neg; color: color_error_min}
                                    },
                                    State {
                                        name: "yellow"; when: pitch_neg.height / (p_dis.height / 2) >= error_color_min && pitch_neg.height / (p_dis.height / 2) < error_color_med
                                        PropertyChanges {target: pitch_neg; color: color_error_med}
                                    },
                                    State {
                                        name: "red"; when: pitch_neg.height / (p_dis.height / 2) <= error_color_max && pitch_neg.height / (p_dis.height / 2) >= error_color_med
                                        PropertyChanges {target: pitch_neg; color: color_error_max}
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
                                        from: "red"; to: "max"; reversible: true
                                        ParallelAnimation{
                                            ColorAnimation { duration: 500 }
                                        }
                                    }
                                ]
                            }

                        }

                        Rectangle{
                            id: r_dis
                            z: 10

                            visible: _errorDisp
                            anchors.left: p_dis.right
                            anchors.top: p_dis.top
                            anchors.leftMargin: r_dis.width / 3
                            height: p_dis.height
                            width: p_dis.width
                            color: "transparent"
                            border.color: "black"
                            border.width: 2
                            property real _roll: _activeVehicle ? Math.abs(actualNormalize(_activeVehicle.roll.value)) : 0
                            property real rollError: _activeVehicle ? (Math.abs(_roll - Math.abs(_activeVehicle.getSetpointRoll()))) / 180 : 0
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
                                z: 10


                                anchors.bottom: r_dis.verticalCenter
                                anchors.left: r_dis.left
                                anchors.right: r_dis.right

                                //anchors.topMargin: r_dis.border.width * 2
                                anchors.leftMargin: r_dis.border.width
                                anchors.rightMargin: r_dis.border.width
                                color: "green"
                                height: _activeVehicle ? pos(Math.abs(r_dis._roll), Math.abs(_activeVehicle.getSetpointRoll()), roll_neg.height) * errorHeight(r_dis.rollError, (r_dis.height - (r_dis.border.width * 2)), 0) : 0
                                Behavior on height { SmoothedAnimation { velocity: smoothingFactor } }
                                states:[
                                    State {
                                        name: "green"; when: roll_pos.height / (r_dis.height / 2) < error_color_min
                                        PropertyChanges {target: roll_pos; color: color_error_min}
                                    },
                                    State {
                                        name: "yellow"; when: roll_pos.height / (r_dis.height / 2) >= error_color_min && roll_pos.height / (r_dis.height / 2) < error_color_med
                                        PropertyChanges {target: roll_pos; color: color_error_med}
                                    },
                                    State {
                                        name: "red"; when: roll_pos.height / (r_dis.height / 2) <= error_color_max && roll_pos.height / (r_dis.height / 2) >= error_color_med
                                        PropertyChanges {target: roll_pos; color: color_error_max}
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
                                        from: "red"; to: "max"; reversible: true
                                        ParallelAnimation{
                                            ColorAnimation { duration: 500 }
                                        }
                                    }
                                ]
                            }
                            Rectangle{
                                id: roll_neg
                                z: 10

                                anchors.top: r_dis.verticalCenter
                                anchors.left: r_dis.left
                                anchors.right: r_dis.right

                                //anchors.bottomMargin: r_dis.border.width * 2
                                anchors.leftMargin: r_dis.border.width
                                anchors.rightMargin: r_dis.border.width
                                color: "green"
                                height: _activeVehicle ? neg(Math.abs(r_dis._roll), Math.abs(_activeVehicle.getSetpointRoll()), roll_pos.height) * errorHeight(r_dis.rollError, (r_dis.height - (r_dis.border.width * 2)), 0) : 0
                                Behavior on height { SmoothedAnimation { velocity: smoothingFactor } }
                                states:[
                                    State {
                                        name: "green"; when: roll_neg.height / (r_dis.height / 2) < error_color_min
                                        PropertyChanges {target: roll_neg; color: color_error_min}
                                    },
                                    State {
                                        name: "yellow"; when: roll_neg.height / (r_dis.height / 2) >= error_color_min && roll_neg.height / (r_dis.height / 2) < error_color_med
                                        PropertyChanges {target: roll_neg; color: color_error_med}
                                    },
                                    State {
                                        name: "red"; when: roll_neg.height / (r_dis.height / 2) <= error_color_max && roll_neg.height / (r_dis.height / 2) >= error_color_med
                                        PropertyChanges {target: roll_neg; color: color_error_max}
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
                                        from: "red"; to: "max"; reversible: true
                                        ParallelAnimation{
                                            ColorAnimation { duration: 500 }
                                        }
                                    }
                                ]
                            }

                        }

                        Rectangle{
                            id: y_dis
                            z: 10

                            visible: _errorDisp
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
                                z: 10

                                id: yaw_pos
                                anchors.bottom: y_dis.verticalCenter
                                anchors.left: y_dis.left
                                anchors.right: y_dis.right

                                //anchors.topMargin: y_dis.border.width * 2
                                anchors.rightMargin: y_dis.border.width
                                anchors.leftMargin: y_dis.border.width
                                color: "green"
                                height: _activeVehicle ? pos(Math.abs(y_dis.heading), Math.abs(_activeVehicle.getSetpointYaw()), yaw_neg.height) * errorHeight(y_dis.yawError, (y_dis.height - (y_dis.border.width * 2)), 2) : 0
                                Behavior on height { SmoothedAnimation { velocity: smoothingFactor } }
                                states:[
                                    State {
                                        name: "green"; when: yaw_pos.height / (y_dis.height / 2) < error_color_min
                                        PropertyChanges {target: yaw_pos; color: color_error_min}
                                    },
                                    State {
                                        name: "yellow"; when: yaw_pos.height / (y_dis.height / 2) >= error_color_min && yaw_pos.height / (y_dis.height / 2) < error_color_med
                                        PropertyChanges {target: yaw_pos; color: color_error_med}
                                    },
                                    State {
                                        name: "red"; when: yaw_pos.height / (y_dis.height / 2) <= error_color_max && yaw_pos.height / (y_dis.height / 2) >= error_color_med
                                        PropertyChanges {target: yaw_pos; color: color_error_max}
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
                                        from: "red"; to: "max"; reversible: true
                                        ParallelAnimation{
                                            ColorAnimation { duration: 500 }
                                        }
                                    }
                                ]
                            }
                            Rectangle{
                                id: yaw_neg
                                z: 10

                                anchors.top: y_dis.verticalCenter
                                anchors.left: y_dis.left
                                anchors.right: y_dis.right

                                //anchors.bottomMargin: y_dis.border.width * 2
                                anchors.leftMargin: y_dis.border.width
                                anchors.rightMargin: y_dis.border.width
                                color: "green"
                                height: _activeVehicle ? neg(Math.abs(y_dis.heading), Math.abs(_activeVehicle.getSetpointYaw()), yaw_pos.height) * errorHeight(y_dis.yawError, (y_dis.height - (y_dis.border.width * 2)), 2) : 0
                                Behavior on height { SmoothedAnimation { velocity: smoothingFactor } }
                                states:[
                                    State {
                                        name: "green"; when: yaw_neg.height / (y_dis.height / 2) < error_color_min
                                        PropertyChanges {target: yaw_neg; color: color_error_min}
                                    },
                                    State {
                                        name: "yellow"; when: yaw_neg.height / (y_dis.height / 2) >= error_color_min && yaw_neg.height / (y_dis.height / 2) < error_color_med
                                        PropertyChanges {target: yaw_neg; color: color_error_med}
                                    },
                                    State {
                                        name: "red"; when: yaw_neg.height / (y_dis.height / 2) <= error_color_max && yaw_neg.height / (y_dis.height / 2) >= error_color_med
                                        PropertyChanges {target: yaw_neg; color: color_error_max}
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
                                        from: "red"; to: "max"; reversible: true
                                        ParallelAnimation{
                                            ColorAnimation { duration: 500 }
                                        }
                                    }
                                ]
                            }
                        }

                        Rectangle{
                            z: 10

                            id: topRef
                            visible: _errorDisp
                            width: p_dis.width
                            height: 2
                            color: "black"
                            anchors.left: y_dis.right
                            anchors.top: p_dis.top
                            anchors.leftMargin: topRef.width / 3
                            Text{
                                text: error_bar_max
                                anchors.left: topRef.right
                                anchors.horizontalCenter: topRef.horizontalCenter
                            }
                        }

                        Rectangle{
                            z: 10

                            id: sideRef
                            visible: _errorDisp
                            width: 2
                            height: p_dis.height
                            color: "black"
                            anchors.left: y_dis.right
                            anchors.top: p_dis.top
                            anchors.leftMargin: topRef.width / 3
                        }

                        Rectangle{
                            id: bottomRef
                            z: 10

                            visible: _errorDisp
                            width: p_dis.width
                            height: 2
                            color: "black"
                            anchors.left: y_dis.right
                            anchors.bottom: p_dis.bottom
                            anchors.leftMargin: topRef.width / 3
                            Text{
                                text: "-" + error_bar_max
                                anchors.left: bottomRef.right
                                anchors.horizontalCenter: bottomRef.horizontalCenter
                            }
                        }

                        Rectangle{
                            id: midRef
                            z: 10

                            visible: _errorDisp
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
                            z: 10

                            width: buttons.width
                            height: buttons.height
                            color: "transparent"
                        }

                        Rectangle{
                            visible: _buttonsDisp
                            z: 10

                            id: rc_button
                            height: buttons.width / 8
                            width: buttons.width / 4.25
                            anchors.horizontalCenter: armed_button.left
                            anchors.top: rcGhost.bottom
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
                                visible: _buttonsDisp

                                id: rc_button_control
                                width: rc_button.width
                                height: rc_button.height
                                text: "RC"
                                anchors.horizontalCenter: rc_button.horizontalCenter
                                anchors.verticalCenter: rc_button.verticalCenter
                                palette.buttonText: "white"
                                palette.button: "steelblue"
                                Rectangle{
                                    width: rc_button.width
                                    height: rc_button.height
                                    border.color: rc_button.rc_border_color
                                    border.width: 2
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
                            visible: _buttonsDisp
                            z: 10

                            id: train_button
                            height: buttons.width / 8
                            width: buttons.width / 3.75
                            anchors.horizontalCenter: armed_button.right
                            anchors.top: learnGhost.bottom
                            property string train_border_color: "black"

                            color: "white"
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
                                visible: _buttonsDisp

                                id: train_button_control
                                width: train_button.width
                                height: train_button.height
                                text: "LEARN"
                                palette.text: "black"
                                anchors.horizontalCenter: train_button.horizontalCenter
                                anchors.verticalCenter: train_button.verticalCenter
                                palette.buttonText: "black"
                                palette.button: "white"
                                Rectangle{
                                    width: train_button.width
                                    height: train_button.height
                                    border.color: train_button.train_border_color
                                    border.width: 2
                                    color: "transparent"
                                }
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
                            visible: _buttonsDisp
                            z: 10

                            id: slider
                            anchors.bottom: buttons.top
                            anchors.right: slideGhost.left
                            anchors.horizontalCenterOffset: button.width
                            from: 0; to: 15; stepSize: 5
                            value: 0
                            ToolTip {
                                    parent: slider.handle
                                    visible: slider.pressed
                                    text: slider.valueAt(slider.position).toFixed(1)
                                }
                        }
                        Rectangle{
                            id: sliderGhost
                            anchors.bottom: slider.bottom
                            anchors.right: slider.left
                            height: slider.height * 2
                            width: slider.width / 2
                            visible: false
                            color: 'black'
                        }
                        Rectangle{
                            id: learnGhost
                            anchors.top: sliderGhost.bottom
                            anchors.left: sliderGhost.right
                            height: slider.height * 6
                            width: slider.width / 3
                            visible: false
                            color: 'lime'
                        }
                        Rectangle{
                            id: rcGhost
                            anchors.top: sliderGhost.bottom
                            anchors.left: sliderGhost.left
                            height: slider.height * 6
                            width: slider.width / 6
                            visible: false
                            color: 'blue'
                        }
                        Rectangle{
                            id: armedGhost
                            anchors.top: sliderGhost.bottom
                            anchors.left: rcGhost.right
                            height: slider.height * 7
                            width: slider.width / 4.25
                            visible: false
                            color: 'red'
                        }
                        Rectangle{
                            id: slideGhost
                            height: buttons.width / 8
                            width: buttons.width / 2.75
                            anchors.right: buttons.horizontalCenter
                            anchors.top: buttons.top
                            anchors.leftMargin: p_dis.width
                            property string rc_border_color: "lime"
                            visible: false
                        }
                        Rectangle{
                            id: block
                            anchors.bottom: rc_button.top
                            height: buttons.width / 15
                            color: 'purple'
                            visible: false
                            radius: 10
                        }
                        Rectangle{
                            id: block2
                            anchors.left: armed_button.horizontalCenter
                            width: buttons.width / 15
                            color: 'lime'
                            visible: false
                        }
                        Rectangle{
                            id: vert1Ghost
                            anchors.right: rc_button.right
                            anchors.bottom: block.top
                            width: buttons.width / 60
                            height: buttons.width / 1.75
                            color: 'black'
                            visible: false
                            radius: 10
                        }
                        Rectangle{
                            id: vert2Ghost
                            anchors.left: train_button.left
                            anchors.bottom: block.top
                            width: buttons.width / 60
                            height: buttons.width / 1.75
                            color: 'black'
                            visible: false
                            radius: 10
                        }
                        Rectangle{
                            id: vert1
                            anchors.right: vert1Ghost.left
                            anchors.bottom: block.top
                            width: buttons.width / 60
                            height: buttons.width / 1.75
                            color: 'black'
                            visible: _woutDisp
                            radius: 10
                        }
                        Rectangle{
                            id: vert2
                            anchors.left: vert2Ghost.right
                            anchors.bottom: block.top
                            width: buttons.width / 60
                            height: buttons.width / 1.75
                            color: 'black'
                            visible: _woutDisp
                            radius: 10
                        }
                        Rectangle{
                            id: horiz1
                            anchors.left: rc_button.left
                            y: vert1.y + 2 * vert1.height / 3
                            width: buttons.width / 1.6
                            height: buttons.width / 60
                            color: 'black'
                            visible: _woutDisp
                            radius: 10
                        }
                        Rectangle{
                            id: horiz2
                            anchors.left: rc_button.left
                            y: vert1.y + vert1.height / 3.5
                            width: buttons.width / 1.6
                            height: buttons.width / 60
                            color: 'black'
                            visible: _woutDisp
                            radius: 10
                        }
                        Grid {
                            anchors.horizontalCenter: block2.horizontalCenter
                            anchors.bottom: rc_button.top
                            columns: 3
                            rows: 3
                            spacing: 2
                            visible: _woutDisp
                            Rectangle {
                                id: c1r1
                                color: 'transparent'
                                width: buttons.width / 5
                                height: buttons.width / 5
                                Text {
                                    text: ""
                                }
                            }
                            Rectangle {
                                id: c1r2
                                color: 'transparent'
                                width: buttons.width / 5
                                height: buttons.width / 5
                                Text {
                                    text: ""
                                }
                            }
                            Rectangle {
                                id: c1r3
                                color: 'transparent'
                                width: buttons.width / 5
                                height: buttons.width / 5
                                Text {
                                    text: ""
                                }
                            }
                            Rectangle {
                                id: c2r1
                                color: 'transparent'
                                width: buttons.width / 5
                                height: buttons.width / 5
                                Text {
                                    text: ""
                                }
                            }
                            Rectangle {
                                id: c2r2
                                color: 'transparent'
                                width: buttons.width / 5
                                height: buttons.width / 5
                                Text {
                                    text: ""
                                }
                            }
                            Rectangle {
                                id: c2r3
                                color: 'transparent'
                                width: buttons.width / 5
                                height: buttons.width / 5
                                Text {
                                    text: ""
                                }
                            }
                            Rectangle {
                                id: c3r1
                                color: 'transparent'
                                width: buttons.width / 5
                                height: buttons.width / 5
                                Text {
                                    text: ""
                                }
                            }
                            Rectangle {
                                id: c3r2
                                color: 'transparent'
                                width: buttons.width / 5
                                height: buttons.width / 5
                                Text {
                                    text: ""
                                }
                            }
                            Rectangle {
                                id: c3r3
                                color: 'transparent'
                                width: buttons.width / 5
                                height: buttons.width / 5
                                Text {
                                    text: ""
                                }
                            }

                        }

                        Button {
                            visible: _buttonsDisp

                            id: armed_button
                            Rectangle{
                                width: armed_button.width
                                height: armed_button.height
                                border.color: 'lime'
                                border.width: 2
                                color: "transparent"
                            }
                            background: Rectangle{
                                color: "green"
                                id: button_comp

                            states: [
                                State {
                                    name: "ARMED"
                                    PropertyChanges { target: button_comp; color: "red" }
                                },
                                State {
                                    name: "DISARMED"
                                    PropertyChanges { target: button_comp; color: "green" }
                                }
                            ]

                            transitions: [
                                Transition {
                                    from: "DISARMED"; to: "ARMED"; reversible: true
                                }
                            ]
                            }
                            anchors.left: armedGhost.right
                            anchors.top: armedGhost.bottom

                            property bool   _armed:         _activeVehicle ? _activeVehicle.armed : false
                            Layout.alignment:   Qt.AlignHCenter
                            text:               _armed ?  qsTr("ARMED") : (forceArm ? qsTr("Force Arm") : qsTr("DISARMED"))
                            width: buttons.width / 2.5
                            property bool forceArm: false

                            onTextChanged: {
                                if (_armed == true) {
                                button_comp.state = 'ARMED'
                                } else {
                                    button_comp.state = 'DISARMED'
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

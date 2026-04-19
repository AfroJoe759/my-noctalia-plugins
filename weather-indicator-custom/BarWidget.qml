import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Commons
import qs.Services.Location
import qs.Widgets
import qs.Services.UI
import "." as Local

Item {
    id: root

    property var pluginApi: null
    readonly property bool weatherReady: Local.WeatherUtils.isWeatherReady()

    property ShellScreen screen
    property string widgetId: ""
    property string section: ""
    property int sectionWidgetIndex: -1
    property int sectionWidgetsCount: 0

    property var cfg: pluginApi?.pluginSettings || ({})
    property var defaults: pluginApi?.manifest?.metadata?.defaultSettings || ({})

    readonly property string customColor: cfg.customColor ?? defaults.customColor ?? "none"
    readonly property bool showTempValue: cfg.showTempValue ?? defaults.showTempValue ?? false
    readonly property bool showConditionIcon: cfg.showConditionIcon ?? defaults.showConditionIcon ?? false
    readonly property bool showTempUnit: cfg.showTempUnit ?? defaults.showTempUnit ?? false
    readonly property string temperatureMode: cfg.temperatureMode ?? defaults.temperatureMode ?? "both"
    readonly property string temperaturePriority: cfg.temperaturePriority ?? defaults.temperaturePriority ?? "celsius"
    readonly property string tooltipOption: cfg.tooltipOption ?? defaults.tooltipOption ?? "everything"

    readonly property string screenName: screen ? screen.name : ""
    readonly property string barPosition: Settings.getBarPositionForScreen(screenName)
    readonly property bool isVertical: barPosition === "left" || barPosition === "right"
    readonly property real barHeight: Style.getBarHeightForScreen(screenName)
    readonly property real capsuleHeight: Style.getCapsuleHeightForScreen(screenName)
    readonly property real barFontSize: Style.getBarFontSizeForScreen(screenName)

    readonly property color textColor: Local.Theme.text
    readonly property color iconColor: Local.Theme.accent
    readonly property color backgroundColor: mouseArea.containsMouse ? Local.Theme.bgCard : Local.Theme.bgElevated
    readonly property color borderColor: Local.Theme.borderSoft

    readonly property real contentWidth: isVertical ? root.barHeight - Style.marginL : layout.implicitWidth + Style.marginM * 2
    readonly property real contentHeight: Math.max(root.capsuleHeight, layout.implicitHeight + Style.marginS * 2)

    visible: true
    opacity: 1.0

    Behavior on opacity {
        NumberAnimation { duration: 200 }
    }

    Behavior on scale {
        NumberAnimation { duration: 120 }
    }

    scale: mouseArea.containsMouse ? 1.05 : 1.0

    implicitWidth: contentWidth
    implicitHeight: contentHeight

    Rectangle {
        id: visualCapsule
        x: Style.pixelAlignCenter(parent.width, width)
        y: Style.pixelAlignCenter(parent.height, height)
        width: root.contentWidth
        height: root.contentHeight
        color: root.backgroundColor
        radius: Style.radiusL
        border.color: root.borderColor
        border.width: Style.capsuleBorderWidth

        Item {
            id: layout
            anchors.centerIn: parent

            implicitWidth: row.implicitWidth
            implicitHeight: row.implicitHeight

            RowLayout {
                id: row
                spacing: Style.marginM
                anchors.verticalCenter: parent.verticalCenter

                Rectangle {
                    visible: root.showConditionIcon
                    Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                    implicitWidth: 28 * Style.uiScaleRatio
                    implicitHeight: 28 * Style.uiScaleRatio
                    radius: 10
                    color: Qt.rgba(0.30, 0.64, 1.0, 0.14)
                    border.color: Qt.rgba(0.30, 0.64, 1.0, 0.20)
                    border.width: 1

                    NIcon {
                        anchors.centerIn: parent
                        icon: weatherReady ? Local.WeatherUtils.getCurrentIcon() : "weather-cloud-off"
                        applyUiScale: true
                        color: root.iconColor
                    }
                }

                ColumnLayout {
                    spacing: Style.marginXXS

                    NText {
                        text: weatherReady ? root.formatTemperature(LocationService.data.weather.current_weather.temperature) : "..."
                        visible: root.showTempValue
                        color: root.textColor
                        font.weight: Font.Bold
                        pointSize: root.barFontSize
                        applyUiScale: false
                        features: ({ "tnum": 1 })
                    }

                }
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onEntered: {
            if (tooltipOption !== "disable") {
                buildTooltip();
            }
        }

        onExited: TooltipService.hide()

        onClicked: function (mouse) {
            if (mouse.button === Qt.LeftButton) {
                if (pluginApi) {
                    pluginApi.openPanel(root.screen, root);
                }
            } else if (mouse.button === Qt.RightButton) {
                PanelService.showContextMenu(contextMenu, root, screen);
            }
        }
    }

    NPopupContextMenu {
        id: contextMenu

        model: [
            { "label": pluginApi?.tr("menu.openPanel") || "Open Weather", "action": "open", "icon": "calendar" },
            { "label": pluginApi?.tr("menu.settings") || "Widget Settings", "action": "settings", "icon": "settings" }
        ]

        onTriggered: function (action) {
            contextMenu.close();
            PanelService.closeContextMenu(screen);

            if (action === "open") {
                pluginApi.openPanel(root.screen, root);
            } else if (action === "settings") {
                BarService.openPluginSettings(screen, pluginApi.manifest);
            }
        }
    }

    function formatTemperature(tempC) {
        return Local.WeatherUtils.formatCurrentTemperature(tempC, root.temperatureMode, root.showTempUnit, root.temperaturePriority);
    }

    function buildCurrentTemp() {
        if (!weatherReady)
            return [];

        let rows = [];
        rows.push([("Current"), root.formatTemperature(LocationService.data.weather.current_weather.temperature)]);
        return rows;
    }

    function buildHiLowTemps() {
        if (!weatherReady)
            return [];

        let rows = [];
        const daily = Local.WeatherUtils.getDaily(0);
        let max = daily.max;
        let min = daily.min;

        if (root.temperatureMode === "fahrenheit") {
            max = LocationService.celsiusToFahrenheit(max);
            min = LocationService.celsiusToFahrenheit(min);
            rows.push([("High"), Math.round(max) + (root.showTempUnit ? "°F" : "")]);
            rows.push([("Low"), Math.round(min) + (root.showTempUnit ? "°F" : "")]);
        } else if (root.temperatureMode === "both") {
            const maxF = LocationService.celsiusToFahrenheit(max);
            const minF = LocationService.celsiusToFahrenheit(min);
            rows.push([("High"), Local.WeatherUtils.formatCompactTemperature(max, root.temperatureMode, root.showTempUnit, root.temperaturePriority)]);
            rows.push([("Low"), Local.WeatherUtils.formatCompactTemperature(min, root.temperatureMode, root.showTempUnit, root.temperaturePriority)]);
        } else {
            rows.push([("High"), Math.round(max) + (root.showTempUnit ? "°C" : "")]);
            rows.push([("Low"), Math.round(min) + (root.showTempUnit ? "°C" : "")]);
        }

        return rows;
    }

    function buildSunriseSunset() {
        if (!weatherReady)
            return [];

        let rows = [];
        const times = Local.WeatherUtils.getSunTimes(0);
        rows.push([("Sunrise"), times.sunrise]);
        rows.push([("Sunset"), times.sunset]);
        return rows;
    }

    function buildTooltip() {
        let allRows = [];
        switch (tooltipOption) {
            case "highlow": {
                allRows.push(...buildHiLowTemps());
                break;
            }
            case "sunrise": {
                allRows.push(...buildSunriseSunset());
                break;
            }
            case "everything": {
                allRows.push(...buildCurrentTemp());
                allRows.push(...buildHiLowTemps());
                allRows.push(...buildSunriseSunset());
                break;
            }
            default:
                break;
        }

        if (allRows.length > 0) {
            TooltipService.show(root, allRows, BarService.getTooltipDirection(root.screen?.name));
        }
    }
}

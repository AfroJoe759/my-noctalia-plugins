import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Commons
import qs.Services.Location
import qs.Widgets
import qs.Services.UI

// Bar Widget Component
Item {
  id: root

  property var pluginApi: null
  readonly property bool weatherReady: Settings.data.location.weatherEnabled && (LocationService.data.weather !== null)

  // Required properties for bar widgets
  property ShellScreen screen
  property string widgetId: ""
  property string section: ""
  property int sectionWidgetIndex: -1
  property int sectionWidgetsCount: 0

  // Get Settings and defaultSettings
   property var cfg: pluginApi?.pluginSettings || ({})
   property var defaults: pluginApi?.manifest?.metadata?.defaultSettings || ({})

  // Get settings or use false
  readonly property string customColor: cfg.customColor ?? defaults.customColor ?? "none"
  readonly property bool showTempValue: cfg.showTempValue ?? defaults.showTempValue ?? false
  readonly property bool showConditionIcon: cfg.showConditionIcon ?? defaults.customColor ?? false
  readonly property bool showTempUnit: cfg.showTempUnit ?? defaults.showTempUnit ?? false
  readonly property string temperatureMode: cfg.temperatureMode ?? defaults.temperatureMode ?? "both"
  readonly property string tooltipOption: cfg.tooltipOption ?? defaults.tooltipOption ?? "everything"

  function formatTemperature(tempC) {
    var mode = root.temperatureMode;
    if (mode === "fahrenheit") {
      var tempF = LocationService.celsiusToFahrenheit(tempC);
      return `${Math.round(tempF)}${root.showTempUnit ? "°F" : ""}`;
    }

    if (mode === "both") {
      var tempF = LocationService.celsiusToFahrenheit(tempC);
      return `${Math.round(tempC)}°C / ${Math.round(tempF)}°F`;
    }

    return `${Math.round(tempC)}${root.showTempUnit ? "°C" : ""}`;
  }

  function formatHiLow(max, min) {
    var mode = root.temperatureMode;
    if (mode === "fahrenheit") {
      max = LocationService.celsiusToFahrenheit(max);
      min = LocationService.celsiusToFahrenheit(min);
      return `${Math.round(max)}°F / ${Math.round(min)}°F`;
    }

    if (mode === "both") {
      var maxF = LocationService.celsiusToFahrenheit(max);
      var minF = LocationService.celsiusToFahrenheit(min);
      return `${Math.round(max)}°C / ${Math.round(min)}°C / ${Math.round(maxF)}°F / ${Math.round(minF)}°F`;
    }

    return `${Math.round(max)}°C / ${Math.round(min)}°C`;
  }

  // Bar positioning properties
  readonly property string screenName: screen ? screen.name : ""
  readonly property string barPosition: Settings.getBarPositionForScreen(screenName)
  readonly property bool isVertical: barPosition === "left" || barPosition === "right"
  readonly property real barHeight: Style.getBarHeightForScreen(screenName)
  readonly property real capsuleHeight: Style.getCapsuleHeightForScreen(screenName)
  readonly property real barFontSize: Style.getBarFontSizeForScreen(screenName)

  readonly property real contentWidth: isVertical ? root.barHeight - Style.marginL : layout.implicitWidth + Style.marginM * 2
  readonly property real contentHeight: isVertical ? layout.implicitHeight + Style.marginS * 2 : root.capsuleHeight
  readonly property color contentColor: mouseArea.containsMouse ? Color.mOnHover : Color.resolveColorKey(customColor)

  visible: root.weatherReady
  opacity: root.weatherReady ? 1.0 : 0.0

  implicitWidth: contentWidth
  implicitHeight: contentHeight

  Rectangle {
    id: visualCapsule
    x: Style.pixelAlignCenter(parent.width, width)
    y: Style.pixelAlignCenter(parent.height, height)
    width: root.contentWidth
    height: root.contentHeight
    color: mouseArea.containsMouse ? Color.mHover : Style.capsuleColor
    radius: Style.radiusL
    border.color: Style.capsuleBorderColor
    border.width: Style.capsuleBorderWidth

    Item {
      id: layout
      anchors.centerIn: parent

      implicitWidth: grid.implicitWidth
      implicitHeight: grid.implicitHeight

      GridLayout {
        id: grid
        columns: root.isVertical ? 1 : 2
        rowSpacing: Style.marginS
        columnSpacing: Style.marginS

        NIcon {
          visible: root.showConditionIcon
          Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
          icon: weatherReady ? LocationService.weatherSymbolFromCode(LocationService.data.weather.current_weather.weathercode, LocationService.data.weather.current_weather.is_day) : "weather-cloud-off"
          applyUiScale: true
          color: contentColor
        }

        NText {
          visible: root.showTempValue
          text: {
            if (!weatherReady || !root.showTempValue) {
              return "";
            }
            var tempC = LocationService.data.weather.current_weather.temperature;
            var tempF = LocationService.celsiusToFahrenheit(tempC);
            return `${Math.round(tempC)}°C / ${Math.round(tempF)}°F`;
          }
          color: contentColor
          pointSize: root.barFontSize
          applyUiScale: false
          Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
          features: ({
              "tnum": 1
          })
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

    onExited: {
    TooltipService.hide();
    }

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
      {
        "label": pluginApi?.tr("menu.openPanel") || "Open Weather",
        "action": "open",
        "icon": "calendar"
      },
      {
        "label": pluginApi?.tr("menu.settings") || "Widget Settings",
        "action": "settings",
        "icon": "settings"
      }
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

function buildCurrentTemp() {
    let rows = [];
    var tempC = LocationService.data.weather.current_weather.temperature;
    rows.push([("Current"), root.formatTemperature(tempC)]);
    return rows;
}

function buildHiLowTemps() {
    let rows = [];
    var max = LocationService.data.weather.daily.temperature_2m_max[0]
    var min = LocationService.data.weather.daily.temperature_2m_min[0]
    var mode = root.temperatureMode;

    if (mode === "fahrenheit") {
        max = LocationService.celsiusToFahrenheit(max)
        min = LocationService.celsiusToFahrenheit(min)
        rows.push([("High"), `${Math.round(max)}${root.showTempUnit ? "°F" : ""}`]);
        rows.push([("Low"), `${Math.round(min)}${root.showTempUnit ? "°F" : ""}`]);
    } else if (mode === "both") {
        var maxF = LocationService.celsiusToFahrenheit(max)
        var minF = LocationService.celsiusToFahrenheit(min)
        rows.push([("High"), `${Math.round(max)}°C / ${Math.round(maxF)}°F`]);
        rows.push([("Low"), `${Math.round(min)}°C / ${Math.round(minF)}°F`]);
    } else {
        rows.push([("High"), `${Math.round(max)}${root.showTempUnit ? "°C" : ""}`]);
        rows.push([("Low"), `${Math.round(min)}${root.showTempUnit ? "°C" : ""}`]);
    }

    return rows;
}

function buildSunriseSunset() {
    let rows = [];
    var riseDate = new Date(LocationService.data.weather.daily.sunrise[0])
    var setDate  = new Date(LocationService.data.weather.daily.sunset[0])

    const timeFormat = Settings.data.location.use12hourFormat ? "hh:mm AP" : "HH:mm";
    const rise = I18n.locale.toString(riseDate, timeFormat);
    const set = I18n.locale.toString(setDate, timeFormat);

    rows.push([("Sunrise"), rise]);
    rows.push([("Sunset"), set]);
    return rows;
}

function buildTooltip() {
    let allRows = [];
    switch (tooltipOption) {
        case "highlow": {
            allRows.push(...buildHiLowTemps());
            break
        }
        case "sunrise": {
            allRows.push(...buildSunriseSunset())
            break
        }
        case "everything": {
            allRows.push(...buildCurrentTemp());
            allRows.push(...buildHiLowTemps())
            allRows.push(...buildSunriseSunset());
            break
        }
        default:
            break
    }
    if (allRows.length > 0) {
      TooltipService.show(root, allRows, BarService.getTooltipDirection(root.screen?.name))
    }
  }
}

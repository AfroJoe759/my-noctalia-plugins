import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import qs.Commons
import qs.Services.Location
import qs.Widgets

// Weather overview card (placeholder data)
NBox {
  id: root
  //readonly property real contentPreferredWidth: 675
  //readonly property real contentPreferredHeight: content.implicitHeight + (Style.marginL * 2)

  property var pluginApi: null
  property var cfg: pluginApi?.pluginSettings || ({})
  property var defaults: pluginApi?.manifest?.metadata?.defaultSettings || ({})
  readonly property bool showTempUnit: cfg.showTempUnit ?? defaults.showTempUnit ?? true
  readonly property string temperatureMode: cfg.temperatureMode ?? defaults.temperatureMode ?? "both"

  property int forecastDays: 7
  property bool showLocation: true
  property bool showEffects: Settings.data.location.weatherShowEffects
  readonly property bool weatherReady: Settings.data.location.weatherEnabled && (LocationService.data.weather !== null)

  // Test mode: set to "clear_day", "clear_night", "rain", "snow", "cloud" or "fog"
  property string testEffects: ""

  // Weather condition detection
  readonly property int currentWeatherCode: weatherReady ? LocationService.data.weather.current_weather.weathercode : 0
  readonly property bool isDayTime: weatherReady ? LocationService.data.weather.current_weather.is_day : true
  readonly property bool isRaining: testEffects === "rain" || (testEffects === "" && ((currentWeatherCode >= 51 && currentWeatherCode <= 67) || (currentWeatherCode >= 80 && currentWeatherCode <= 82)))
  readonly property bool isSnowing: testEffects === "snow" || (testEffects === "" && ((currentWeatherCode >= 71 && currentWeatherCode <= 77) || (currentWeatherCode >= 85 && currentWeatherCode <= 86)))
  readonly property bool isCloudy: testEffects === "cloud" || (testEffects === "" && (currentWeatherCode === 3))
  readonly property bool isFoggy: testEffects === "fog" || (testEffects === "" && (currentWeatherCode >= 40 && currentWeatherCode <= 49))
  readonly property bool isClearDay: testEffects === "clear_day" || (testEffects === "" && (currentWeatherCode === 0 && isDayTime))
  readonly property bool isClearNight: testEffects === "clear_night" || (testEffects === "" && (currentWeatherCode === 0 && !isDayTime))

  function formatTemperature(tempC) {
    if (temperatureMode === "fahrenheit") {
      var tempF = LocationService.celsiusToFahrenheit(tempC);
      return `${Math.round(tempF)}${showTempUnit ? "°F" : ""}`;
    }
    if (temperatureMode === "both") {
      var tempF = LocationService.celsiusToFahrenheit(tempC);
      return `${Math.round(tempC)}°C / ${Math.round(tempF)}°F`;
    }
    return `${Math.round(tempC)}${showTempUnit ? "°C" : ""}`;
  }

  function formatForecastHigh(max) {
    if (temperatureMode === "fahrenheit") {
      max = LocationService.celsiusToFahrenheit(max);
      return `${Math.round(max)}${showTempUnit ? "°F" : ""}`;
    }
    if (temperatureMode === "both") {
      var maxF = LocationService.celsiusToFahrenheit(max);
      return `${Math.round(max)}${showTempUnit ? "°C" : ""} / ${Math.round(maxF)}${showTempUnit ? "°F" : ""}`;
    }
    return `${Math.round(max)}${showTempUnit ? "°C" : ""}`;
  }

  function formatForecastLow(min) {
    if (temperatureMode === "fahrenheit") {
      min = LocationService.celsiusToFahrenheit(min);
      return `${Math.round(min)}${showTempUnit ? "°F" : ""}`;
    }
    if (temperatureMode === "both") {
      var minF = LocationService.celsiusToFahrenheit(min);
      return `${Math.round(min)}${showTempUnit ? "°C" : ""} / ${Math.round(minF)}${showTempUnit ? "°F" : ""}`;
    }
    return `${Math.round(min)}${showTempUnit ? "°C" : ""}`;
  }

  visible: Settings.data.location.weatherEnabled
  implicitHeight: Math.max(100 * Style.uiScaleRatio, content.implicitHeight + (Style.marginXL * 2))

  // Weather effect layer (rain/snow)
  Loader {
    id: weatherEffectLoader
    anchors.fill: parent
    active: root.showEffects && (root.isRaining || root.isSnowing || root.isCloudy || root.isFoggy || root.isClearDay || root.isClearNight)

    sourceComponent: Item {
      anchors.fill: parent

      // Animated time for shaders
      property real shaderTime: 0
      NumberAnimation on shaderTime {
        loops: Animation.Infinite
        from: 0
        to: 1000
        duration: 100000
      }

      ShaderEffect {
        id: weatherEffect
        anchors.fill: parent
        // Rain matches content margins, everything else fills the box
        anchors.margins: root.isRaining ? Style.marginXL : root.border.width

        property var source: ShaderEffectSource {
          sourceItem: content
          hideSource: root.isRaining // Only hide for rain (distortion), show for snow
        }

        property real time: parent.shaderTime
        property real itemWidth: weatherEffect.width
        property real itemHeight: weatherEffect.height
        property color bgColor: root.color
        property real cornerRadius: root.isRaining ? 0 : (root.radius - root.border.width)
        property real alternative: root.isFoggy

        fragmentShader: {
          let shaderName;
          if (root.isSnowing)
            shaderName = "weather_snow";
          else if (root.isRaining)
            shaderName = "weather_rain";
          else if (root.isCloudy || root.isFoggy)
            shaderName = "weather_cloud";
          else if (root.isClearDay)
            shaderName = "weather_sun";
          else if (root.isClearNight)
            shaderName = "weather_stars";
          else
            shaderName = "";

          return Qt.resolvedUrl(Quickshell.shellDir + "/Shaders/qsb/" + shaderName + ".frag.qsb");
        }
      }
    }
  }

  ColumnLayout {
    id: content
    anchors.fill: parent
    anchors.margins: Style.marginXL
    spacing: Style.marginM
    clip: true

    RowLayout {
      Layout.fillWidth: true
      spacing: Style.marginS

      Item {
        Layout.preferredWidth: Style.marginXXS
      }

      RowLayout {
        spacing: Style.marginL
        Layout.fillWidth: true

        NIcon {
          Layout.alignment: Qt.AlignVCenter
          icon: weatherReady ? LocationService.weatherSymbolFromCode(LocationService.data.weather.current_weather.weathercode, LocationService.data.weather.current_weather.is_day) : "weather-cloud-off"
          pointSize: Style.fontSizeXXXL * 1.75
          color: Color.mPrimary
        }

        ColumnLayout {
          spacing: Style.marginXXS
          NText {
            text: {
              // Ensure the name is not too long if one had to specify the country
              const chunks = Settings.data.location.name.split(",");
              return chunks[0];
            }
            pointSize: Style.fontSizeL
            font.weight: Style.fontWeightBold
            visible: showLocation && !Settings.data.location.hideWeatherCityName
          }

          RowLayout {
            NText {
              visible: weatherReady
              text: {
                if (!weatherReady) {
                  return "";
                }
                var tempC = LocationService.data.weather.current_weather.temperature;
                return root.formatTemperature(tempC);
              }
              pointSize: showLocation ? Style.fontSizeXL : Style.fontSizeXL * 1.6
              font.weight: Style.fontWeightBold
            }

            NText {
              text: weatherReady ? `(${LocationService.data.weather.timezone_abbreviation})` : ""
              pointSize: Style.fontSizeXS
              color: Color.mOnSurfaceVariant
              visible: LocationService.data.weather && showLocation && !Settings.data.location.hideWeatherTimezone
            }
          }
        }
      }
    }

    NDivider {
      visible: weatherReady
      Layout.fillWidth: true
    }

    RowLayout {
      visible: weatherReady
      Layout.fillWidth: true
      Layout.alignment: Qt.AlignVCenter
      spacing: Style.marginM

      Repeater {
        model: weatherReady ? Math.min(root.forecastDays, LocationService.data.weather.daily.time.length) : 0
        delegate: ColumnLayout {
          Layout.fillWidth: true
          spacing: Style.marginXS
          Item {
            Layout.fillWidth: true
          }
          NText {
            Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
            text: {
              var weatherDate = new Date(LocationService.data.weather.daily.time[index].replace(/-/g, "/"));
              return I18n.locale.toString(weatherDate, "ddd");
            }
            color: Color.mOnSurface
          }
          NIcon {
            Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
            icon: LocationService.weatherSymbolFromCode(LocationService.data.weather.daily.weathercode[index])
            pointSize: Style.fontSizeXXL * 1.6
            color: Color.mPrimary
          }
          NText {
            Layout.alignment: Qt.AlignHCenter
            text: {
              var max = LocationService.data.weather.daily.temperature_2m_max[index];
              return root.formatForecastHigh(max);
            }
            pointSize: Style.fontSizeXS
            color: Color.mOnSurfaceVariant
          }
          NText {
            Layout.alignment: Qt.AlignHCenter
            text: {
              var min = LocationService.data.weather.daily.temperature_2m_min[index];
              return root.formatForecastLow(min);
            }
            pointSize: Style.fontSizeXS
            color: Color.mOnSurfaceVariant
          }
        NText {
            Layout.alignment: Qt.AlignHCenter
            text: {
                var riseDate = new Date(LocationService.data.weather.daily.sunrise[index])

                const timeFormat = Settings.data.location.use12hourFormat ? "hh:mm AP" : "HH:mm";
                const rise = I18n.locale.toString(riseDate, timeFormat);
                return `${rise}`;
            }
            pointSize: Style.fontSizeXS
            color: Color.mOnSurfaceVariant
        }
        NText {
            Layout.alignment: Qt.AlignHCenter
            text: {
                var setDate = new Date(LocationService.data.weather.daily.sunset[index])

                const timeFormat = Settings.data.location.use12hourFormat ? "hh:mm AP" : "HH:mm";
                const set = I18n.locale.toString(setDate, timeFormat);
                return `${set}`;
            }
            pointSize: Style.fontSizeXS
            color: Color.mOnSurfaceVariant
        }
      }
    }

    Loader {
      active: !weatherReady
      Layout.alignment: Qt.AlignCenter
      sourceComponent: NBusyIndicator {}
    }
  }
}
}

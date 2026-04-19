import QtQuick
import QtQuick.Layouts
import qs.Commons
import qs.Widgets
import "." as Local
import "components"

NBox {
    id: root

    property var pluginApi: null
    property var cfg: pluginApi?.pluginSettings || ({})
    property var defaults: pluginApi?.manifest?.metadata?.defaultSettings || ({})
    readonly property bool showTempUnit: cfg.showTempUnit ?? defaults.showTempUnit ?? true
    readonly property string temperatureMode: cfg.temperatureMode ?? defaults.temperatureMode ?? (Settings.data.location.useFahrenheit ? "fahrenheit" : "celsius")
    readonly property string temperaturePriority: cfg.temperaturePriority ?? defaults.temperaturePriority ?? "celsius"

    property int forecastDays: 7
    property bool showLocation: true
    property bool showEffects: Settings.data.location.weatherShowEffects
    readonly property bool weatherReady: Local.WeatherUtils.isWeatherReady()
    readonly property var temp: weatherReady ? Local.WeatherUtils.getTemp() : {c: 0, f: 0}
    readonly property int currentWeatherCode: weatherReady ? Local.WeatherUtils.getCurrentWeatherCode() : 0
    readonly property bool isDayTime: weatherReady ? Local.WeatherUtils.isDayTime() : true
    readonly property bool isRaining: (currentWeatherCode >= 51 && currentWeatherCode <= 67) || (currentWeatherCode >= 80 && currentWeatherCode <= 82)
    readonly property bool isSnowing: (currentWeatherCode >= 71 && currentWeatherCode <= 77) || (currentWeatherCode >= 85 && currentWeatherCode <= 86)
    readonly property bool isCloudy: currentWeatherCode === 3
    readonly property bool isFoggy: currentWeatherCode >= 40 && currentWeatherCode <= 49
    readonly property bool isClearDay: currentWeatherCode === 0 && isDayTime
    readonly property bool isClearNight: currentWeatherCode === 0 && !isDayTime
    readonly property var sunTimes: weatherReady ? Local.WeatherUtils.getSunTimes(0) : ({ sunrise: "--:--", sunset: "--:--" })
    readonly property int feelsLikeValue: weatherReady ? Math.round(Local.WeatherUtils.getFeelsLikeValue()) : 0
    readonly property var windKmh: weatherReady ? Local.WeatherUtils.getCurrentWindKmh() : null
    readonly property var humidityPercent: weatherReady ? Local.WeatherUtils.getCurrentHumidityPercent() : null
    readonly property string locationRegion: weatherReady ? Local.WeatherUtils.getLocationRegion() : ""

    color: Local.Theme.bg
    radius: 22
    border.color: Local.Theme.borderSoft
    border.width: 1

    visible: Settings.data.location.weatherEnabled
    implicitHeight: Math.max(100 * Style.uiScaleRatio, content.implicitHeight + (Style.marginXL * 2))

    Item {
        id: contentLayer
        anchors.fill: parent

        ColumnLayout {
            id: content
            anchors.fill: parent
            anchors.margins: Style.marginXL
            spacing: Style.marginL
            clip: true

            WeatherHeader {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                iconName: weatherReady ? Local.WeatherUtils.getCurrentIcon() : "weather-cloud-off"
                temperatureText: weatherReady ? root.primaryCurrentTemperature() : "..."
                secondaryTemperatureText: weatherReady ? root.secondaryCurrentTemperature() : ""
                locationText: weatherReady ? Local.WeatherUtils.getLocationName() : ""
                subtitleText: weatherReady ? Local.WeatherUtils.getCurrentDescription() : ""
                showLocation: root.showLocation
                windText: weatherReady ? root.windText() : "--"
                humidityText: weatherReady ? root.humidityText() : "--"
            }

            NDivider {
                visible: weatherReady
                Layout.fillWidth: true
                color: Local.Theme.borderSoft
            }

            ForecastRow {
                visible: weatherReady
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                forecastDays: root.forecastDays
                temperatureMode: root.temperatureMode
                temperaturePriority: root.temperaturePriority
                showTempUnit: root.showTempUnit
            }

            Rectangle {
                visible: weatherReady
                Layout.fillWidth: true
                implicitHeight: footerRow.implicitHeight + Style.marginS * 2
                radius: 20
                color: Local.Theme.bgElevated
                border.color: Qt.rgba(0.33, 0.56, 1.0, 0.14)
                border.width: 1

                RowLayout {
                    id: footerRow
                    anchors.fill: parent
                    anchors.margins: Style.marginS
                    spacing: Style.marginL

                    Rectangle {
                        Layout.fillWidth: true
                        radius: 16
                        color: Local.Theme.cardPink
                        border.color: "transparent"
                        implicitHeight: sunriseRow.implicitHeight + Style.marginS * 2

                        RowLayout {
                            id: sunriseRow
                            anchors.fill: parent
                            anchors.margins: Style.marginS
                            spacing: Style.marginS

                            NIcon {
                                icon: "weather-sunset-up"
                                color: Local.Theme.accentAlt
                                pointSize: Style.fontSizeXL
                            }

                            ColumnLayout {
                                spacing: 0

                                NText {
                                    text: sunTimes.sunrise
                                    color: Local.Theme.text
                                    font.weight: Font.Bold
                                }

                                NText {
                                    text: "Sunrise"
                                    color: Local.Theme.textMuted
                                    pointSize: Style.fontSizeXS
                                }
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        radius: 16
                        color: Local.Theme.cardAmber
                        border.color: "transparent"
                        implicitHeight: sunsetRow.implicitHeight + Style.marginS * 2

                        RowLayout {
                            id: sunsetRow
                            anchors.fill: parent
                            anchors.margins: Style.marginS
                            spacing: Style.marginS

                            NIcon {
                                icon: "weather-sunset-down"
                                color: Local.Theme.accentWarm
                                pointSize: Style.fontSizeXL
                            }

                            ColumnLayout {
                                spacing: 0

                                NText {
                                    text: sunTimes.sunset
                                    color: Local.Theme.text
                                    font.weight: Font.Bold
                                }

                                NText {
                                    text: "Sunset"
                                    color: Local.Theme.textMuted
                                    pointSize: Style.fontSizeXS
                                }
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        radius: 16
                        color: Local.Theme.cardBlue
                        border.color: "transparent"
                        implicitHeight: locationRow.implicitHeight + Style.marginS * 2

                        RowLayout {
                            id: locationRow
                            anchors.fill: parent
                            anchors.margins: Style.marginS
                            spacing: Style.marginS

                            NIcon {
                                icon: "map-marker"
                                color: Local.Theme.accent
                                pointSize: Style.fontSizeXL
                            }

                            ColumnLayout {
                                spacing: 0

                                NText {
                                    text: Local.WeatherUtils.getLocationName()
                                    color: Local.Theme.text
                                    font.weight: Font.Bold
                                }

                                NText {
                                    text: locationRegion.length > 0 ? locationRegion : "Current location"
                                    color: Local.Theme.textMuted
                                    pointSize: Style.fontSizeXS
                                }
                            }
                        }
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

    WeatherEffects {
        id: effectLayer
        anchors.fill: parent
        sourceLayer: content
        bgColor: root.color
        cornerRadius: root.isRaining ? 0 : (root.radius - root.border.width)
        showEffects: root.showEffects
        isRaining: root.isRaining
        isSnowing: root.isSnowing
        isCloudy: root.isCloudy
        isFoggy: root.isFoggy
        isClearDay: root.isClearDay
        isClearNight: root.isClearNight
    }

    function formatCurrentTemperature() {
        return Local.WeatherUtils.formatCurrentTemperature(
            Local.WeatherUtils.getCurrentTemperatureValue(),
            root.temperatureMode,
            root.showTempUnit,
            root.temperaturePriority
        );
    }

    function primaryCurrentTemperature() {
        return Local.WeatherUtils.formatCurrentTemperature(
            Local.WeatherUtils.getCurrentTemperatureValue(),
            root.temperatureMode,
            root.showTempUnit,
            root.temperaturePriority
        );
    }

    function secondaryCurrentTemperature() {
        const feelsLike = Local.WeatherUtils.getFeelsLikeValue();
        return "Feels like " + Local.WeatherUtils.formatSecondaryTemperature(feelsLike, root.temperatureMode, root.showTempUnit, root.temperaturePriority);
    }

    function windText() {
        return windKmh === null ? "--" : (windKmh + " km/h");
    }

    function humidityText() {
        return humidityPercent === null ? "--" : (humidityPercent + "%");
    }
}

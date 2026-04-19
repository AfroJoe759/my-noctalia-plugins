import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Commons
import qs.Services.Location
import qs.Widgets
import qs.Services.UI
import "." as Local

NIconButtonHot {
    id: root

    property ShellScreen screen
    property var pluginApi: null
    readonly property bool weatherReady: Local.WeatherUtils.isWeatherReady()

    property var cfg: pluginApi?.pluginSettings || ({})
    property var defaults: pluginApi?.manifest?.metadata?.defaultSettings || ({})

    readonly property bool showTempUnit: cfg.showTempUnit ?? defaults.showTempUnit ?? true
    readonly property string temperatureMode: cfg.temperatureMode ?? defaults.temperatureMode ?? "both"
    readonly property string temperaturePriority: cfg.temperaturePriority ?? defaults.temperaturePriority ?? "celsius"
    readonly property string tooltipOption: cfg.tooltipOption ?? defaults.tooltipOption ?? "everything"
    readonly property string iconText: weatherReady ? Local.WeatherUtils.getCurrentIcon() : "weather-cloud-off"
    icon: iconText

    property real baseSize: Style.baseWidgetSize
    implicitWidth: Math.round(baseSize * Style.uiScaleRatio)
    implicitHeight: Math.round(baseSize * Style.uiScaleRatio)

    tooltipText: {
        if (!weatherReady)
            return [];

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
                Logger.e("WeatherIndicator", "tooltipOption option: " + tooltipOption + " not recognized.");
        }
        return allRows;
    }

    onClicked: {
        if (pluginApi) {
            pluginApi.togglePanel(screen, this);
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

        if (temperatureMode === "fahrenheit") {
            max = LocationService.celsiusToFahrenheit(max);
            min = LocationService.celsiusToFahrenheit(min);
            rows.push(["High", Math.round(max) + (showTempUnit ? "°F" : "")]);
            rows.push(["Low", Math.round(min) + (showTempUnit ? "°F" : "")]);
        } else if (temperatureMode === "both") {
            rows.push(["High", Local.WeatherUtils.formatCompactTemperature(max, temperatureMode, showTempUnit, temperaturePriority)]);
            rows.push(["Low", Local.WeatherUtils.formatCompactTemperature(min, temperatureMode, showTempUnit, temperaturePriority)]);
        } else {
            rows.push(["High", Math.round(max) + (showTempUnit ? "°C" : "")]);
            rows.push(["Low", Math.round(min) + (showTempUnit ? "°C" : "")]);
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
}

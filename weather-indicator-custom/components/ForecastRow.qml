import QtQuick
import QtQuick.Layouts
import qs.Commons
import qs.Services.Location
import qs.Services.UI
import qs.Widgets
import ".." as Local

RowLayout {
    id: root

    property int forecastDays: 7
    property string temperatureMode: "both"
    property bool showTempUnit: true
    property string temperaturePriority: "celsius"

    spacing: Style.marginM

    Repeater {
        model: Local.WeatherUtils.isWeatherReady() ? Math.min(root.forecastDays, LocationService.data.weather.daily.time.length) : 0

        delegate: Item {
            required property int index

            Layout.fillWidth: true
            Layout.minimumWidth: 0
            Behavior on scale {
                NumberAnimation { duration: 120 }
            }

            Behavior on opacity {
                NumberAnimation { duration: 200 }
            }

            scale: hoverArea.containsMouse ? 1.05 : 1.0
            opacity: hoverArea.containsMouse ? 1.0 : 0.94

            implicitHeight: forecastContent.implicitHeight + Style.marginM * 2

            ColumnLayout {
                id: forecastContent
                anchors.fill: parent
                spacing: Style.marginS

                NText {
                    Layout.alignment: Qt.AlignHCenter
                    text: Local.WeatherUtils.getDayLabel(index).toUpperCase()
                    color: Local.Theme.text
                    font.weight: Font.Bold
                }

                Rectangle {
                    Layout.alignment: Qt.AlignHCenter
                    implicitWidth: 72 * Style.uiScaleRatio
                    implicitHeight: 72 * Style.uiScaleRatio
                    radius: 16
                    color: hoverArea.containsMouse ? Local.Theme.bgCard : Local.Theme.bgElevated
                    border.color: hoverArea.containsMouse ? Qt.rgba(0.33, 0.56, 1.0, 0.28) : Local.Theme.borderSoft
                    border.width: 1

                    NIcon {
                        anchors.centerIn: parent
                        icon: LocationService.weatherSymbolFromCode(LocationService.data.weather.daily.weathercode[index])
                        pointSize: Style.fontSizeXXL * 1.3
                        color: Local.Theme.accent
                    }
                }

                NText {
                    Layout.alignment: Qt.AlignHCenter
                    text: {
                        const daily = Local.WeatherUtils.getDaily(index);
                        return Local.WeatherUtils.formatCompactTemperature(daily.max, root.temperatureMode, root.showTempUnit, root.temperaturePriority);
                    }
                    pointSize: root.temperatureMode === "both" ? Style.fontSizeXS : Style.fontSizeL
                    font.weight: Font.Bold
                    color: Local.Theme.text
                }

                NText {
                    Layout.alignment: Qt.AlignHCenter
                    text: {
                        const daily = Local.WeatherUtils.getDaily(index);
                        return Local.WeatherUtils.formatCompactTemperature(daily.min, root.temperatureMode, root.showTempUnit, root.temperaturePriority);
                    }
                    pointSize: root.temperatureMode === "both" ? Style.fontSizeXS : Style.fontSizeM
                    color: Local.Theme.textMuted
                    font.weight: Font.Medium
                }
            }

            MouseArea {
                id: hoverArea
                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.NoButton

                onEntered: {
                    const times = Local.WeatherUtils.getSunTimes(index);
                    TooltipService.show(parent, [["Sunrise", times.sunrise], ["Sunset", times.sunset]]);
                }

                onExited: TooltipService.hide()
            }
        }
    }
}

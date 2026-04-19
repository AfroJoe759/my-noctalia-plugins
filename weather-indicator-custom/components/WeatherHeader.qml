import QtQuick
import QtQuick.Layouts
import qs.Commons
import qs.Widgets
import ".." as Local

RowLayout {
    id: root

    property string iconName: "weather-cloud-off"
    property string temperatureText: "..."
    property string secondaryTemperatureText: ""
    property string locationText: ""
    property string subtitleText: ""
    property bool showLocation: true
    property string windText: "--"
    property string humidityText: "--"

    spacing: Style.marginXL

    Rectangle {
        Layout.alignment: Qt.AlignTop
        implicitWidth: 104 * Style.uiScaleRatio
        implicitHeight: 104 * Style.uiScaleRatio
        radius: 28
        color: Qt.rgba(0.27, 0.43, 0.96, 0.16)
        border.color: Qt.rgba(0.33, 0.56, 1.0, 0.24)
        border.width: 1

        NIcon {
            anchors.centerIn: parent
            icon: root.iconName
            pointSize: Style.fontSizeXXXL * 2.5
            color: Local.Theme.accent
        }
    }

    ColumnLayout {
        spacing: Style.marginXS
        Layout.alignment: Qt.AlignTop
        Layout.fillWidth: true

        NText {
            text: root.temperatureText
            pointSize: root.temperatureText.indexOf("/") !== -1 ? Style.fontSizeXXXL * 1.2 : Style.fontSizeXXXL * 2.2
            font.weight: Font.Bold
            color: Local.Theme.text
            wrapMode: Text.NoWrap
            elide: Text.ElideRight
            maximumLineCount: 1
            Layout.fillWidth: true
            Layout.minimumWidth: 0
        }

        NText {
            visible: root.secondaryTemperatureText.length > 0
            text: root.secondaryTemperatureText
            color: Local.Theme.textSoft
            pointSize: Style.fontSizeM
            wrapMode: Text.NoWrap
            elide: Text.ElideRight
            Layout.fillWidth: true
            Layout.minimumWidth: 0
        }

        NText {
            visible: root.subtitleText.length > 0
            text: root.subtitleText
            color: Local.Theme.textMuted
            pointSize: Style.fontSizeM
            wrapMode: Text.NoWrap
            elide: Text.ElideRight
            Layout.fillWidth: true
            Layout.minimumWidth: 0
        }
    }

    Rectangle {
        Layout.fillHeight: true
        Layout.preferredWidth: 1
        color: Local.Theme.borderSoft
        opacity: 0.9
    }

    ColumnLayout {
        Layout.preferredWidth: 220
        Layout.alignment: Qt.AlignTop
        spacing: Style.marginM
        Layout.fillHeight: true

        NText {
            text: root.subtitleText.length > 0 ? root.subtitleText.toUpperCase() : ""
            color: Qt.lighter(Local.Theme.accentAlt, 1.15)
            pointSize: Style.fontSizeL
            font.weight: Font.Bold
            wrapMode: Text.NoWrap
            elide: Text.ElideRight
            Layout.fillWidth: true
            Layout.minimumWidth: 0
        }

        RowLayout {
            spacing: Style.marginL

            RowLayout {
                spacing: Style.marginS

                NIcon {
                    icon: "weather-windy"
                    color: Local.Theme.accent
                    pointSize: Style.fontSizeM
                }

                NText {
                    text: root.windText
                    color: Local.Theme.textSoft
                    pointSize: Style.fontSizeM
                    wrapMode: Text.NoWrap
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                    Layout.minimumWidth: 0
                }
            }

            RowLayout {
                spacing: Style.marginS

                NIcon {
                    icon: "water-percent"
                    color: Local.Theme.accentAlt
                    pointSize: Style.fontSizeM
                }

                NText {
                    text: root.humidityText
                    color: Local.Theme.textSoft
                    pointSize: Style.fontSizeM
                    wrapMode: Text.NoWrap
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                    Layout.minimumWidth: 0
                }
            }
        }

        RowLayout {
            visible: root.showLocation && root.locationText.length > 0
            spacing: Style.marginS

            NIcon {
                icon: "map-marker"
                color: Local.Theme.accent
                pointSize: Style.fontSizeL
            }

            NText {
                text: root.locationText
                color: Local.Theme.textMuted
                pointSize: Style.fontSizeS
                wrapMode: Text.NoWrap
                elide: Text.ElideRight
                Layout.fillWidth: true
                Layout.minimumWidth: 0
            }
        }
    }
}

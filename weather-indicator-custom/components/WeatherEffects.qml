import QtQuick
import QtQuick.Effects
import Quickshell

Item {
    id: root

    property Item sourceLayer: null
    property color bgColor: "transparent"
    property real cornerRadius: 0
    property bool showEffects: false
    property bool isRaining: false
    property bool isSnowing: false
    property bool isCloudy: false
    property bool isFoggy: false
    property bool isClearDay: false
    property bool isClearNight: false

    opacity: 0.2
    visible: root.showEffects && (root.isRaining || root.isSnowing || root.isCloudy || root.isFoggy || root.isClearDay || root.isClearNight)

    ShaderEffect {
        anchors.fill: parent

        property var source: ShaderEffectSource {
            sourceItem: root.sourceLayer
            hideSource: root.isRaining
        }
        property real time: root.weatherTime
        property real itemWidth: width
        property real itemHeight: height
        property color bgColor: root.bgColor
        property real cornerRadius: root.cornerRadius
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

    property real weatherTime: 0
    NumberAnimation on weatherTime {
        loops: Animation.Infinite
        from: 0
        to: 1000
        duration: 100000
    }
}

import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Commons
import qs.Widgets

ColumnLayout {
  id: root

  property var pluginApi: null

  property var cfg: pluginApi?.pluginSettings || ({})
  property var defaults: pluginApi?.manifest?.metadata?.defaultSettings || ({})

  property bool showTempValue: cfg.showTempValue ?? defaults.showTempValue
  property bool showConditionIcon: cfg.showConditionIcon ?? defaults.showConditionIcon
  property bool showTempUnit: cfg.showTempUnit ?? defaults.showTempUnit
  property string temperatureMode: cfg.temperatureMode ?? defaults.temperatureMode
  property string temperaturePriority: cfg.temperaturePriority ?? defaults.temperaturePriority ?? "celsius"
  property string tooltipOption: cfg.tooltipOption ?? defaults.tooltipOption
  property string customColor: cfg.customColor ?? defaults.customColor
  spacing: Style.marginL

  Component.onCompleted: {
    Logger.i("WeatherIndicator", "Settings UI loaded");
  }

  function tr(key, fallback) {
    var text = pluginApi?.tr(key);
    if (text && text.indexOf("!!") === -1) {
      return text;
    }
    return fallback;
  }

  NColorChoice {
    label: tr("settings.customColor.label", "Custom color")
    description: tr("settings.customColor.desc", "Choose what color you would like the icon and text to be.")
    currentKey: root.customColor
    onSelected: key => {
                  root.customColor = key;
                }
  }

  NToggle {
    id: toggleIcon
    label: tr("settings.showConditionIcon.label", "Show condition icon")
    description: tr("settings.showConditionIcon.desc", "Include the visual weather symbol in the widget.")
    checked: root.showConditionIcon
    onToggled: checked => {
      root.showConditionIcon = checked;
      root.showTempValue = true;
    }
    defaultValue: true
  }

  NToggle {
    id: toggleTempText
    label: tr("settings.showTempValue.label", "Show temperature value")
    description: tr("settings.showTempValue.desc", "Display the current degrees alongside the condition.")
    checked: root.showTempValue
    onToggled: checked => {
      root.showTempValue = checked;
      root.showConditionIcon = true;
    }
    defaultValue: true
  }

  NToggle {
    id: toggleTempLetter
    label: tr("settings.showTempUnit.label", "Show temperature unit when horizontal")
    description: tr("settings.showTempUnit.desc", "Show °C or °F indicating the temperature unit when using a horizontal bar.")
    checked: root.showTempUnit
    visible: root.showTempValue
    onToggled: checked => {
      root.showTempUnit = checked;
    }
    defaultValue: true
  }

  NComboBox {
    Layout.fillWidth: true
    label: tr("settings.temperatureMode.label", "Temperature Mode")
    description: tr("settings.temperatureMode.desc", "Choose whether to show Celsius, Fahrenheit, or both.")
    model: [
      { "key": "celsius", "name": tr("settings.mode.celsius", "Celsius") },
      { "key": "fahrenheit", "name": tr("settings.mode.fahrenheit", "Fahrenheit") },
      { "key": "both", "name": tr("settings.mode.both", "Both") }
    ]
    currentKey: root.temperatureMode
    onSelected: function (key) {
      root.temperatureMode = key;
    }
    defaultValue: "both"
  }

  NComboBox {
    Layout.fillWidth: true
    visible: root.temperatureMode === "both"
    label: tr("settings.temperaturePriority.label", "Primary temperature order")
    description: tr("settings.temperaturePriority.desc", "Choose the primary unit order when both temperatures are shown.")
    model: [
      { "key": "fahrenheit", "name": tr("settings.priority.fahrenheit", "Fahrenheit (F/C)") },
      { "key": "celsius", "name": tr("settings.priority.celsius", "Celsius (C/F)") }
    ]
    currentKey: root.temperaturePriority
    onSelected: function (key) {
      root.temperaturePriority = key;
    }
    defaultValue: "celsius"
  }

  NComboBox {
    Layout.fillWidth: true
    label: tr("settings.tooltipOption.label", "Tooltip options")
    description: tr("settings.tooltipOption.desc", "Choose what you would like the tooltip to display.")
    model: [
      {
        "key": "disable",
        "name": tr("settings.mode.disable", "Disable the Tooltip")
      },
      {
        "key": "highlow",
        "name": tr("settings.mode.highlow", "High/Low temps")
      },
      {
        "key": "sunrise",
        "name": tr("settings.mode.sunrise", "Sunrise/set times")
      },
      {
        "key": "everything",
        "name": tr("settings.mode.everything", "Show all")
      }
    ]
    currentKey: root.tooltipOption
    onSelected: function (key) {
      root.tooltipOption = key;
    }
    defaultValue: "everything"
  }

  function saveSettings() {
    if (!pluginApi) {
      Logger.e("WeatherIndicator", "Cannot save settings: pluginApi is null");
      return;
    }

    pluginApi.pluginSettings.showTempValue = root.showTempValue;
    pluginApi.pluginSettings.showConditionIcon = root.showConditionIcon;
    pluginApi.pluginSettings.showTempUnit = root.showTempUnit;
    pluginApi.pluginSettings.temperatureMode = root.temperatureMode;
    pluginApi.pluginSettings.temperaturePriority = root.temperaturePriority;
    pluginApi.pluginSettings.tooltipOption = root.tooltipOption;
    pluginApi.pluginSettings.customColor = root.customColor;
    pluginApi.saveSettings();

    Logger.i("WeatherIndicator", "Settings saved successfully");
    pluginApi.closePanel(root.screen);
  }
}

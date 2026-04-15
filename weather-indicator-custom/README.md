# Weather Indicator (Custom)

A Noctalia plugin that displays current weather information with a customizable bar widget, control center widget, and forecast panel.

## Features

- Show the current weather condition icon and temperature.
- Display temperature units (°C or °F).
- Customize tooltip content: high/low temperatures, sunrise/sunset times, or all details.
- Add an optional widget to the Control Center for a cleaner bar layout.
- Open a panel for a seven-day forecast with sunrise and sunset times.
- Built-in settings support and translations in `en`, `de`, and `zh-CN`.

## Included Files

- `BarWidget.qml` — main weather widget for the Noctalia bar.
- `ControlCenterWidget.qml` — optional widget for the Control Center.
- `Panel.qml` — forecast panel with a seven-day view.
- `Settings.qml` — preferences UI for the plugin.
- `WeatherCardExtra.qml` — extra weather card display components.
- `manifest.json` — Noctalia plugin metadata and entry points.
- `i18n/` — translation files for supported languages.
- `preview.png` — plugin preview image.

## Installation

1. Copy the `weather-indicator-custom` folder into your Noctalia plugins directory.
2. Restart Noctalia or refresh plugins.
3. Enable the plugin in Noctalia settings.

## Plugin Metadata

- Name: `Weather Indicator (Custom)`
- Version: `1.0.0`
- Author: `Sovereign`
- License: `MIT`
- Repository: `https://github.com/AfroJoe759/my-noctalia-plugins`
- Requires Noctalia ≥ `4.6.8`

## Notes

- The plugin is designed to work in the Noctalia bar and Control Center.
- You can change widget appearance and tooltip behavior from `Settings.qml`.
- Translation files are available under `i18n/`.

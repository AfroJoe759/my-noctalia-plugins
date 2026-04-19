pragma Singleton
import QtQuick
import qs.Commons
import qs.Services.Location

QtObject {
    readonly property var usStateNames: ({
        "AL": "Alabama", "AK": "Alaska", "AZ": "Arizona", "AR": "Arkansas",
        "CA": "California", "CO": "Colorado", "CT": "Connecticut", "DE": "Delaware",
        "FL": "Florida", "GA": "Georgia", "HI": "Hawaii", "ID": "Idaho",
        "IL": "Illinois", "IN": "Indiana", "IA": "Iowa", "KS": "Kansas",
        "KY": "Kentucky", "LA": "Louisiana", "ME": "Maine", "MD": "Maryland",
        "MA": "Massachusetts", "MI": "Michigan", "MN": "Minnesota", "MS": "Mississippi",
        "MO": "Missouri", "MT": "Montana", "NE": "Nebraska", "NV": "Nevada",
        "NH": "New Hampshire", "NJ": "New Jersey", "NM": "New Mexico", "NY": "New York",
        "NC": "North Carolina", "ND": "North Dakota", "OH": "Ohio", "OK": "Oklahoma",
        "OR": "Oregon", "PA": "Pennsylvania", "RI": "Rhode Island", "SC": "South Carolina",
        "SD": "South Dakota", "TN": "Tennessee", "TX": "Texas", "UT": "Utah",
        "VT": "Vermont", "VA": "Virginia", "WA": "Washington", "WV": "West Virginia",
        "WI": "Wisconsin", "WY": "Wyoming", "DC": "District of Columbia"
    })

    readonly property var countryNames: ({
        "US": "United States",
        "USA": "United States",
        "UK": "United Kingdom",
        "UAE": "United Arab Emirates"
    })

    function isWeatherReady() {
        return Settings.data.location.weatherEnabled && (LocationService.data.weather !== null);
    }

    function getTemp() {
        var tempC = LocationService.data.weather.current_weather.temperature;
        var tempF = LocationService.celsiusToFahrenheit(tempC);

        return {
            c: Math.round(tempC),
            f: Math.round(tempF)
        };
    }

    function getCurrentTemperatureValue() {
        return LocationService.data.weather.current_weather.temperature;
    }

    function getFeelsLikeValue() {
        var weather = LocationService.data.weather;

        if (weather.current && weather.current.apparent_temperature !== undefined)
            return weather.current.apparent_temperature;
        if (weather.hourly && weather.hourly.apparent_temperature && weather.hourly.apparent_temperature.length > 0)
            return weather.hourly.apparent_temperature[0];

        return getCurrentTemperatureValue();
    }

    function getDaily(index) {
        return {
            max: Math.round(LocationService.data.weather.daily.temperature_2m_max[index]),
            min: Math.round(LocationService.data.weather.daily.temperature_2m_min[index]),
            code: LocationService.data.weather.daily.weathercode[index]
        };
    }

    function getCurrentWeatherCode() {
        return LocationService.data.weather.current_weather.weathercode;
    }

    function isDayTime() {
        return LocationService.data.weather.current_weather.is_day;
    }

    function getCurrentIcon() {
        return LocationService.weatherSymbolFromCode(getCurrentWeatherCode(), isDayTime());
    }

    function getCurrentDescription() {
        return LocationService.weatherDescriptionFromCode(getCurrentWeatherCode());
    }

    function getCurrentWindKmh() {
        var current = LocationService.data.weather.current_weather;

        if (current.windspeed !== undefined)
            return Math.round(current.windspeed);
        if (current.wind_speed !== undefined)
            return Math.round(current.wind_speed);
        if (current.wind_speed_10m !== undefined)
            return Math.round(current.wind_speed_10m);

        return null;
    }

    function getCurrentHumidityPercent() {
        var weather = LocationService.data.weather;

        if (weather.current && weather.current.relative_humidity_2m !== undefined)
            return Math.round(weather.current.relative_humidity_2m);
        if (weather.current && weather.current.relativehumidity_2m !== undefined)
            return Math.round(weather.current.relativehumidity_2m);
        if (weather.hourly && weather.hourly.relative_humidity_2m && weather.hourly.relative_humidity_2m.length > 0)
            return Math.round(weather.hourly.relative_humidity_2m[0]);
        if (weather.hourly && weather.hourly.relativehumidity_2m && weather.hourly.relativehumidity_2m.length > 0)
            return Math.round(weather.hourly.relativehumidity_2m[0]);

        return null;
    }

    function getLocationName() {
        var location = getLocationParts();

        if (location.region.length > 0)
            return location.city + ", " + location.region;

        return location.city;
    }

    function getLocationRegion() {
        var location = getLocationParts();
        return location.country;
    }

    function getLocationParts() {
        var name = Settings.data.location.name || "";
        var parts = name.split(",").map(function(part) { return part.trim(); }).filter(function(part) { return part.length > 0; });
        var city = parts.length > 0 ? parts[0] : "";
        var region = parts.length > 1 ? formatRegion(parts[1], parts.length > 2 ? parts[2] : "") : "";
        var country = parts.length > 2 ? normalizeCountry(parts[2]) : "";

        if (parts.length === 2 && country.length === 0) {
            var upper = parts[1].toUpperCase();

            if (usStateNames[upper] !== undefined) {
                country = "United States";
            } else if (parts[1].length > 2) {
                country = normalizeCountry(parts[1]);
            }
        }

        return {
            city: city,
            region: region,
            country: country
        };
    }

    function normalizeRegion(region, country) {
        var normalizedCountry = normalizeCountry(country);
        var upper = region.toUpperCase();

        if ((normalizedCountry === "United States" || normalizedCountry === "") && usStateNames[upper] !== undefined)
            return usStateNames[upper];

        return region;
    }

    function formatRegion(region, country) {
        var normalizedCountry = normalizeCountry(country);
        var upper = region.toUpperCase();

        if ((normalizedCountry === "United States" || normalizedCountry === "") && usStateNames[upper] !== undefined)
            return upper;

        return region;
    }

    function normalizeCountry(country) {
        var upper = country.toUpperCase();

        if (countryNames[upper] !== undefined)
            return countryNames[upper];

        return country;
    }

    function getDayLabel(index) {
        var weatherDate = new Date(LocationService.data.weather.daily.time[index].replace(/-/g, "/"));
        return I18n.locale.toString(weatherDate, "ddd");
    }

    function getSunTimes(index) {
        var riseDate = new Date(LocationService.data.weather.daily.sunrise[index]);
        var setDate = new Date(LocationService.data.weather.daily.sunset[index]);
        var timeFormat = Settings.data.location.use12hourFormat ? "hh:mm AP" : "HH:mm";

        return {
            sunrise: I18n.locale.toString(riseDate, timeFormat),
            sunset: I18n.locale.toString(setDate, timeFormat)
        };
    }

    function formatTemperaturePair(tempC, mode, showUnit, priority) {
        var roundedC = Math.round(tempC);
        var roundedF = Math.round(LocationService.celsiusToFahrenheit(tempC));
        priority = priority || "celsius";

        if (mode === "both") {
            if (priority === "fahrenheit")
                return roundedF + (showUnit ? "°F" : "") + " / " + roundedC + (showUnit ? "°C" : "");
            return roundedC + (showUnit ? "°C" : "") + " / " + roundedF + (showUnit ? "°F" : "");
        }

        if (mode === "fahrenheit")
            return roundedF + (showUnit ? "°F" : "");

        return roundedC + (showUnit ? "°C" : "");
    }

    function formatCompactTemperature(tempC, mode, showUnit, priority) {
        return formatTemperaturePair(tempC, mode, showUnit, priority);
    }

    function formatSecondaryTemperature(tempC, mode, showUnit, priority) {
        var roundedC = Math.round(tempC);
        var roundedF = Math.round(LocationService.celsiusToFahrenheit(tempC));
        priority = priority || "celsius";

        if (mode === "both") {
            return formatTemperaturePair(tempC, mode, showUnit, priority);
        }

        if (mode === "fahrenheit")
            return roundedF + (showUnit ? "°F" : "");
        return roundedC + (showUnit ? "°C" : "");
    }

    function formatCurrentTemperature(tempC, mode, showUnit, priority) {
        priority = priority || "celsius";

        if (mode === "fahrenheit") {
            var tempF = LocationService.celsiusToFahrenheit(tempC);
            return Math.round(tempF) + (showUnit ? "°F" : "");
        }

        if (mode === "both") {
            return formatTemperaturePair(tempC, mode, showUnit, priority);
        }

        return Math.round(tempC) + (showUnit ? "°C" : "");
    }

    function formatForecastTemperature(tempC, mode, showUnit, priority) {
        priority = priority || "celsius";

        if (mode === "both") {
            return formatTemperaturePair(tempC, mode, showUnit, priority);
        }

        if (mode === "fahrenheit") {
            var tempF = LocationService.celsiusToFahrenheit(tempC);
            return Math.round(tempF) + (showUnit ? "°F" : "");
        }

        return Math.round(tempC) + (showUnit ? "°C" : "");
    }
}

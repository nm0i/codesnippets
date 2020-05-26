#!/usr/bin/tclsh

package require http
package require json

# To run this script, use openweathermap.tcl London,UK stat

# Your api key goes here
set apikey ""

set location "q=[lindex $argv 0]"
set forecastURI "http://api.openweathermap.org/data/2.5/forecast/daily/?$location&cnt=2&APPID=$apikey"
set currentURI "http://api.openweathermap.org/data/2.5/weather?$location&APPID=$apikey"

# This script essentially just remaps json you get from openweathermap into a tcl dictionary and then formats some of its fields.

proc getCurrentWeather {} {
    global currentWeather currentURI

    set httpToken [::http::config  -urlencoding utf-8 ]

    set httpToken [::http::geturl "$currentURI"]
    set currentJson [::json::json2dict [::http::data $httpToken]]

    ::http::cleanup $httpToken

    dict append currentWeather description [dict get [lindex [dict get $currentJson weather] 0] description]
    dict append currentWeather temp [expr [dict get $currentJson main temp] - 273.15]
    dict append currentWeather humidity [dict get $currentJson main humidity]
    dict append currentWeather clouds [dict get $currentJson clouds all]
}

proc getForecast {} {
    global forecastWeather forecastURI
    set httpToken [::http::geturl "$forecastURI"]
    set forecastJson [::json::json2dict [::http::data $httpToken]]

    ::http::cleanup $httpToken
    foreach dayJson [dict get $forecastJson list] {
        dict append dayData time [dict get $dayJson dt]

        dict append dayData description [dict get [lindex [dict get $dayJson weather] 0] description]

        dict append tempData max [expr [dict get $dayJson temp max] - 273.15]
        dict append tempData min [expr [dict get $dayJson temp min] - 273.15]
        dict append tempData day [expr [dict get $dayJson temp day] - 273.15]
        dict append tempData night [expr [dict get $dayJson temp night] - 273.15]
        dict append tempData eve [expr [dict get $dayJson temp eve] - 273.15]
        dict append tempData morn [expr [dict get $dayJson temp morn] - 273.15]

        dict append dayData temp $tempData

        dict append dayData humidity [dict get $dayJson humidity]
        dict append dayData clouds [dict get $dayJson clouds]

        lappend forecastWeather $dayData
        unset dayData tempData
    }
}

# This block defines output format
if [string equal [lindex $argv 1] "stat"] {
    getForecast
    getCurrentWeather
    append statStr "(Now) [format {%.1f} [dict get $currentWeather clouds]]% [format {%.1f} [dict get $currentWeather temp]]° "
    foreach dayData $forecastWeather {
        append statStr "([clock format [dict get $dayData time] -format {%d.%m}]) [dict get $dayData clouds]% [format {%.1f} [dict get $dayData temp min]]°/[format {%.1f} [dict get $dayData temp max]]° "
    }
    puts $statStr
    exit
}

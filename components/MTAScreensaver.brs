Function init()
    m.top.backgroundColor = "0x662d91FF" '#662d91
    m.top.backgroundURI = ""

    m.TempLabel = m.top.findNode("temperature_label")
    m.DateLabel = m.top.findNode("date_label")
    m.TimeLabel = m.top.findNode("time_label")
    m.Background = m.top.findNode("background")
    m.Sponsor = m.top.findNode("sponsor_ad")

    m.subway = m.top.findNode("subway_data")
    'm.bus = m.top.findNode("bus_data")
    m.bt = m.top.findNode("bt_data")
    m.lirr = m.top.findNode("lirr_data")
    m.mnr = m.top.findNode("mnr_data")

    m.global.observeField("Weather", "updateWeather")
    m.global.observeField("BackgroundUri", "updateBackground")
    m.global.observeField("Mta", "updateMta")
    m.global.observeField("Sponsor", "updateSponsor")

    m.Timer = m.top.findNode("secondTimer")
    m.Timer.control = "start"
    m.Timer.ObserveField("fire", "updateDate")
end Function

'Date/Time functions
Function getDay()
    months = [
        "January",
        "February",
        "March",
        "April",
        "May",
        "June",
        "July",
        "August",
        "September",
        "October",
        "November",
        "December"
    ]

    today = CreateObject("roDateTime")
    today.ToLocalTime()

    day = today.GetWeekday()
    month = today.GetMonth()
    date = today.GetDayOfMonth()

    if(date > 3 and date < 21)
        suffix = "th"
    else if date MOD 10 = 1
        suffix = "st"
    else if date MOD 10 = 2
        suffix = "nd"
    else if date MOD 10 = 3
        suffix = "rd"
    else
        suffix = "th"
    end if

    return day + ", " + months[month-1] + " " + date.ToStr() + suffix
end Function

Function getTime()
    now = CreateObject("roDateTime")
    now.ToLocalTime()

    hour = now.GetHours()

    minutes = now.GetMinutes().ToStr()
    minutes = Right("0"+minutes, 2)

    if hour = 0
        hour = 12
        AmPm = " am"
    else if hour = 12
        AmPm = " pm"
    else if hour > 12
        hour = hour - 12
        AmPm = " pm"
    else 
        AmPm = " am"
    end if

    return hour.ToStr() + ":" + minutes + AmPm
end Function

function updateDate()
    m.DateLabel.text = getDay()
    m.TimeLabel.text = getTime()
end Function

function updateWeather()
    if(m.global.Weather <> invalid)
        temperature = Int((m.global.Weather.main.temp - 273.15) * 1.8 + 32)
        'm.TempLabel.text = temperature.ToStr() + "° and " + m.global.Weather.weather[0].description + " in " + + m.global.Weather.name
        m.TempLabel.text = temperature.ToStr() + "° and " + m.global.Weather.weather[0].description
    end if
end function

Function updateMta()
    if(m.global.Mta <> invalid)

        r1 = CreateObject("roRegex", "Stand clear of the closing doors please!", "i")
        r2 = CreateObject("roRegex", "Please exit through the rear doors!", "i")
        r3 = CreateObject("roRegex", "Sunglasses off, lights on!", "i")
        r4 = CreateObject("roRegex", "Tickets please!", "i")
        r5 = CreateObject("roRegex", "Tickets please!", "i")

        subway = r1.Replace(m.global.Mta.subway.mainText.trim(), "")
        bus = r2.Replace(m.global.Mta.bus.mainText.trim(), "")
        bt = r3.Replace(m.global.Mta.bt.mainText.trim(), "")
        lirr = r4.Replace(m.global.Mta.lirr.mainText.trim(), "")
        mnr = r5.Replace(m.global.Mta.mnr.mainText.trim(), "")

        m.subway.text = subway
        'm.bus.text = bus
        m.bt.text = bt
        m.lirr.text = lirr
        m.mnr.text = mnr

        'mta = subway + bus + bt + lirr + mnr

        'ace = chr(10)+ "A C E - "+ m.global.Mta.ace.mainText
        'bdfm = chr(10) + "B D F M - " +m.global.Mta.bdfm.mainText
        'nqrw = chr(10) + "N Q R W - " +m.global.Mta.nqrw.mainText
        'g = chr(10) + "G - " +m.global.Mta.g.mainText
        'l = chr(10) + "L - " +m.global.Mta.l.mainText
        'one23 = chr(10) + "1 2 3 - " +m.global.Mta["123"].mainText
        'four56= chr(10) + "4 5 6 - " +m.global.Mta["456"].mainText
        'seven = chr(10) + "7 8 9 - " +m.global.Mta["7"].mainText
        'jz = chr(10) + "J Z - " +m.global.Mta.jz.mainText
        'sir = chr(10) + "Staten Island RR - " +m.global.Mta.sir.mainText
        's = chr(10) + "Shuttle - " +m.global.Mta.s.mainText
        'mta = ace + bdfm + nqrw + g + l + one23 + four56 + seven + jz + sir + s

        'm.MtaLabel.text = mta
    end if
end function

'Background functions
function updateBackground()
    if(m.global.BackgroundUri <> invalId)
        m.Background.uri = m.global.BackgroundUri
        'm.Background.uri = getBackground()
    end if
end function

'Update Sponsor
function updateSponsor()
    if(m.global.Sponsor <> invalid)
        m.Sponsor.uri = m.global.Sponsor
    end if
end function
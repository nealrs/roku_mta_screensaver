function RunScreenSaver(params as Object) as Object 'This function is required for screensavers. It acts as a main method for screensavers
    main()
End function

sub main()
    m.config = ReadAsciiFile("pkg:/source/config.json")
    m.config = ParseJSON(m.config)

    screen = createObject("roSGScreen") 'Creates screen to display screensaver

    port = createObject("roMessagePort") 'Port to listen to events on screen
    screen.setMessagePort(port)

    m.zip = getZip()
    m.bg = m.config.backgrounds

    m.global = screen.getGlobalNode()
    m.global.AddFields({"BackgroundUri": "", "Weather": {}, "Mta": {}})

    counter = 0

    scene = screen.createScene("MTAScreensaver") 'Creates scene to display on screen. Scene name (AnimatedScreensaver) must match ID of XML Scene Component
    screen.show()

    m.global.BackgroundUri = randomBG() 'getBackground()
    m.global.Weather = getWeather()
    m.global.Mta = getMta()

    while(true) 'Uses message port to listen if channel is closed
        msg = wait(1, port)
        counter++
        if (msg <> invalid)
            msgType = type(msg)
            if msgType = "roSGScreenEvent"
                if msg.isScreenClosed() then return
            end if
        else if counter = 180000 ' 3 minutes
            m.global.BackgroundUri = randomBG() 'getBackground()
            m.global.Weather = getWeather()
            m.global.Mta = getMta()
            counter = 0
        end if
    end while
end sub

function randomBG()
    if(m.bg <> invalid)
        return m.bg[RND(100)-1]
    else
        return "https://images.unsplash.com/photo-1518235506717-e1ed3306a89b?ixlib=rb-1.2.1&q=80&fm=jpg&crop=entropy&cs=tinysrgb&w=1080&fit=max&ixid=eyJhcHBfaWQiOjg3OTI1fQ"
    end if
end function

function getZip()
    request = CreateObject("roUrlTransfer")
    request.SetCertificatesFile("common:/certs/ca-bundle.crt")
    request.SetUrl("http://api.ipstack.com/check?access_key="+m.config.ipstack_api_key)
    response = request.GetToString()

    if(response <> "")
        json = ParseJSON(response)

        if(json <> invalid)
            return json.zip
        else
            return invalid
        end if
    else
        return invalid
    end if
end function

'Weather functions
function getWeather()
    request = CreateObject("roUrlTransfer")
    request.SetCertificatesFile("common:/certs/ca-bundle.crt")
    request.SetUrl("https://api.openweathermap.org/data/2.5/weather?zip="+m.zip+"&APPID="+m.config.openweathermap_api_key)
    response = request.GetToString()

    if(response <> "")
        json = ParseJSON(response)

        if(json <> invalid)
            return json
        else
            return invalid
        end if
    else
        return invalid
    end if
end function

'MTA
function getMTA()
    request = CreateObject("roUrlTransfer")
    request.SetCertificatesFile("common:/certs/ca-bundle.crt")
    request.SetUrl(m.config.mtaAPI)
    response = request.GetToString()

    if(response <> "")
        json = ParseJSON(response)

        if(json <> invalid)
            return json
        else
            return invalid
        end if
    else
        return invalid
    end if
end function
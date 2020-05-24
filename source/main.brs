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
    m.bg = getAllBackgrounds()

    m.global = screen.getGlobalNode()
    m.global.AddFields({"BackgroundUri": "", "Weather": {}, "Mta": {}, "Sponsor": ""})
   
    scene = screen.createScene("MTAScreensaver") 'Creates scene to display on screen. Scene name (AnimatedScreensaver) must match ID of XML Scene Component
    screen.show()

    m.global.BackgroundUri = randomBG() 'getBackground()
    m.global.Weather = getWeather()
    m.global.Mta = getMta()
    m.global.Sponsor = getSponsor()

    'Initialize GA & send launch event
    gaInit()
    while(true) 'Uses message port to listen if channel is closed
        msg = wait(3*60000, port) '3 min timer
        if (msg <> invalid)
            msgType = type(msg)
            if msgType = "roSGScreenEvent"
                if msg.isScreenClosed() then return
            end if
        else
            m.global.BackgroundUri = randomBG()
            m.global.Weather = getWeather()
            m.global.Mta = getMta()
            m.global.Sponsor = getSponsor()
            gaHeartBeat() 'send 3 min heartbeat
        end if
    end while
end sub

'Background rotator
function getAllBackgrounds()
    request = CreateObject("roUrlTransfer")
    request.SetCertificatesFile("common:/certs/ca-bundle.crt")
    request.SetUrl(m.config.backgrounds)
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

function randomBG()
    if(m.bg <> invalid)
        len = m.bg.Count()
        return m.bg[RND(len)-1]
    else
        return "https://images.unsplash.com/photo-1518235506717-e1ed3306a89b?ixlib=rb-1.2.1&q=80&fm=jpg&crop=entropy&cs=tinysrgb&w=1080&fit=max&ixid=eyJhcHBfaWQiOjg3OTI1fQ"
    end if
end function

'Weather
'get zip from cache, or get & set from ipstack
function getZip()
    print "getZip()"
    if (regRead("zip", "zip") <> invalid)
        'print "read from registry"
        return regRead("zip", "zip")
    else
        'print "save to registry"
        regWrite("zip", setZip(), "zip")
        return regRead("zip", "zip")
    end if
end function

function setZip()
    print 'setZIP()'
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

'MTA Status
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

'Get Sponsor message
function getSponsor()
    request = CreateObject("roUrlTransfer")
    request.SetCertificatesFile("common:/certs/ca-bundle.crt")
    'print m.config.sponsorAPI+"?loc="+m.zip
    request.SetUrl(m.config.sponsorAPI+"?loc="+m.zip)
    response = request.GetToString()

    if(response <> "")
        json = ParseJSON(response)

        if(json <> invalid)
            return json.ad
        else
            return invalid
        end if
    else
        return invalid
    end if
end function

'Google Analytics
sub gaInit()
    m.global.addField("GA","node", false)
    m.global.GA = CreateObject("roSGNode", "Roku_Analytics:AnalyticsNode")
    m.global.GA.debug=true
    m.global.GA.init = {
        google : {
            trackingID : m.config.gaID
            defaultParams : {
                an: "RokuAC"
            }
        }
    }
    gaLaunch()
end sub

sub gaLaunch()
    m.global.GA.trackEvent = {
        google: {
            t: "event",
            ec: "lifecycle",
            ea: "launch",
            ev: 0
        }
    }
end sub

sub gaHeartBeat()
    m.global.GA.trackEvent = {
        google: {
            t: "event",
            ec: "lifecycle",
            ea: "heart beat",
            ev: 3 'heartbeat in 3 minute chunks
        }
    }
end sub

'Registry functions
Function regRead(key,section=invalid)
If section=invalid section="Default"
sec=CreateObject("roRegistrySection",section)
If sec.Exists(key) Return sec.Read(key)
Return invalid
End Function

Function regWrite(key,val,section=invalid)
If section=invalid section="Default"
sec=CreateObject("roRegistrySection",section)
sec.Write(key,val)
sec.Flush() 'commit it
End Function

Function regDelete(key,section=invalid)
If section=invalid section="Default"
sec=CreateObject("roRegistrySection",section)
sec.Delete(key)
sec.Flush()
End Function

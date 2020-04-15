const toTitleCase = require('to-title-case');

const path = require('path');
const dbName = path.join(__dirname, './data.sqlite');
const db = require('better-sqlite3')(dbName, {readonly: true});

exports.handler = async (event) => {
    //console.log(JSON.stringify(event, null, 2));

    // get location/zip
    const clientIp = event.requestContext.identity.sourceIp;
    const location = (event.queryStringParameters === null || event.queryStringParameters.loc === undefined || event.queryStringParameters.loc === null || event.queryStringParameters.loc === "") ? null : event.queryStringParameters.loc;
    //console.log(`Client loc = ${location} | ${clientIp}`);
    let city = 'there';
    if (location){
      const row = db.prepare('SELECT city FROM zip WHERE zipCode=?').get(location);
      city = toTitleCase(row.City); 
    }

    /*
    // set ad copy
    const min=728; 
    const max=970;  
    const width = Math.floor(Math.random() * (+max - +min)) + +min;
    //const ad = `https://placekitten.com/${width}/90`
    //const ad = `https://dummyimage.com/leaderboard/000/fff.png&text=${encodeURIComponent('Go Brooklyn')}!`
    */

    const ad = `https://res.cloudinary.com/wakeywakey/image/upload/w_790,h_90/l_text:Arial_50:${encodeURIComponent(`Hey ${city}!`)},co_white/v1586822525/t.png`
    // ideally, we should also log an ad impression here (or clientside??)
    
    const body = JSON.stringify({
        ad,
        location,
        clientIp
    });
    
    const response = {
        statusCode: 200,
        headers: {"Content-Type": "application/json"},
        body
    };
    //console.log(response);
    return response;
};
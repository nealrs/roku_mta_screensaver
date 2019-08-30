const rokuDeploy = require('roku-deploy');
const cfg = require('./rokudeploy.json');

//create a signed package of your project
rokuDeploy.deployAndSignPackage(cfg).then(function(pathToSignedPackage){
    console.log('Signed package created at ', pathToSignedPackage);
}, function(error) {
    //it failed
    console.error(error);
});
fs = require('fs-extra')
path = require('path')
           
cleanTestPaths = (tester) ->

    testPath = tester.config.testPath
    testSrc = path.join(testPath, 'src')
    
    
    
    console.log("cleanTestPaths...")
    console.log(testSrc)
    try
        fs.removeSync path.join(testSrc,'documents','cms')
        fs.removeSync path.join(testSrc,'files','cms')
        fs.removeSync path.join(testSrc,'layouts','cms')
        console.log("Paths cleaned...")
    catch err
        console.log(err)
    
            
module.exports = cleanTestPaths
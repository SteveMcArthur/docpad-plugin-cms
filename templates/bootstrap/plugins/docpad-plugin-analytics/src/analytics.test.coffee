
# Test our plugin using DocPad's Testers
testerConfig =
    pluginPath: __dirname+'/..'
    autoExit: 'safe'
docpadConfig =
    plugins:
        analytics:
            credentials: {}

require('docpad').require('testers')
    .test(testerConfig)
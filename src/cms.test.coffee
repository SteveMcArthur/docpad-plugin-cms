# Test our plugin using DocPad's Testers
testerConfig =
    pluginPath: __dirname+'/..'
    autoExit: 'safe'
docpadConfig =
    plugins:
        cms:
            copyTemplates: false

require('docpad').require('testers')
    .test(testerConfig,docpadConfig)
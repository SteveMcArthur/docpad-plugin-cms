
# Test our plugin using DocPad's Testers
testerConfig =
    pluginPath: __dirname+'/..'
    autoExit: 'safe'
docpadConfig =
    plugins:
        analytics:
            credentials:
                client_email: 'email@email.com'
                private_key: 'xasde32345'

require('docpad').require('testers')
    .test(testerConfig,docpadConfig)
# Export Plugin Tester
module.exports = (testers) ->
    # PRepare
    {expect} = require('chai')
    request = require('request')
    fs = require('fs')
    util = require('util')

    # Define My Tester
    class AnalyticsTester extends testers.ServerTester
        # Test Generate
        #testGenerate: testers.RendererTester::testGenerate
        
        testCreate: ->
            super

        # Custom test for the server
        testServer: (next) ->
            # Prepare
            tester = @

            # Create the server
            super

            # Test
            @suite 'plugin properties', (suite,test) ->
                # Prepare

                plugin = tester.docpad.getPlugin('analytics')
                config = plugin.getConfig()
                expectedEndpoints = [
                        "7daysPageviews"
                        "yesterdayPageviews"
                        "60daySessions"
                        "30dayCountry"
                        "7daysCountry"
                        "yesterdayCountry"
                        "browserAndOS"
                        "timeOnSite"
                        "trafficSources"
                        "keywords"
                    ]
                
                @suite 'config properties exist', (suite,test,done) ->
                    expectedConfig = [
                        "dataURL"
                        "credentialsFile"
                        "minimiseData"
                        "cacheExpires"
                        "queries"
                    ]

                    expectedConfig.forEach (item) ->
                        test item+' property', () ->
                            expect(config).to.have.property(item)
                    done()
                    

                @suite 'plugin methods are functions', (suite,test,done) ->
                    expectedMethods = [
                        "formatData"
                        "retrieveData"
                        "init"
                        "serverExtend"
                    ]

                    expectedMethods.forEach (item) ->
                        test item+' method', () ->
                            console.log(item)
                            expect(plugin[item]).to.be.instanceof(Function)
                    done()

                @suite 'default queries exist', (suite,test,done) ->
                    
                    endpoints = []
                    for q in plugin.defaultQueries
                        if q.endPoint
                            endpoints.push(q.endPoint)

                    expectedEndpoints.forEach (item) ->
                        test item+' endpoint', () ->
                            i = endpoints.indexOf(item)
                            expect(i).to.be.above(-1)
                    done()

                @suite 'default queries copied to queries', (suite,test,done) ->
                    
                    endpoints = []
                    for q in config.queries
                        if q.endPoint
                            endpoints.push(q.endPoint)

                    expectedEndpoints.forEach (item) ->
                        test item+' endpoint', () ->
                            i = endpoints.indexOf(item)
                            expect(i).to.be.above(-1)
                    done()
                    
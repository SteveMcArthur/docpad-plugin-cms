# Export Plugin Tester
module.exports = (testers) ->
    # PRepare
    {expect} = require('chai')
    fs = require('safefs')
    path = require('path')
    util = require('util')
    cleanTestPaths = require('./helpers/cleanTestPaths')

    # Define My Tester
    class CmsTester extends testers.ServerTester
        # Test Generate
        #testGenerate: testers.RendererTester::testGenerate
        testCreate: ->
            tester = @
            cleanTestPaths(tester)
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
                
                plugin = tester.docpad.getPlugin('cms')
                
                
                @suite 'plugin properties exist', (suite,test) ->
                    expectedProperties = [
                        "layoutsPath"
                        "filesPath"
                        "documentsPath"
                        "editURL"
                        "imageURL"
                        "dataURL"
                        "requiredPlugins"
                        "templateHelpers"
                        "pagesQry"
                    ]

                    for item in expectedProperties
                        test item, (done) ->
                            expect(plugin).to.have.property(item)
                            done()
                        
                @suite 'plugin methods are functions', (suite,test) ->
                    expectedMethods = [
                        "checkPlugins"
                        "buildCollections"
                    ]

                    for item in expectedMethods
                        test item+' method', (done) ->
                            expect(plugin[item]).to.be.instanceof(Function)
                            done()
                        
                @suite 'plugin properties contain expected values', (suite,test) ->
                    dpConfig = tester.docpad.getConfig()
                    srcPath = dpConfig.srcPath
                    test 'editURL', (done) ->
                        expect(plugin.editURL).to.equal("/cms/edit/*")
                        done()
                        
                    test 'imageURL', (done) ->
                        expect(plugin.imageURL).to.equal("/cms/images")
                        done()
                        
                    test 'dataURL', (done) ->
                        expect(plugin.dataURL).to.equal("/cms/data/:item")
                        done()
                        
                @suite 'templateHelpers', (suite,test) ->
                    th = plugin.templateHelpers
                    expectedProperties = [
                        "getLatestPosts"
                        "getPosts"
                        "getPages"
                        "getDocuments"
                        "getSettings"
                    ]

                    for item in expectedProperties
                        test item, (done) ->
                            expect(th[item]).to.be.instanceof(Function)
                            done()
                        
                    
                @suite 'directory paths found', (suite,test) ->
                    plugin = tester.docpad.getPlugin('cms')
                    dpConfig = tester.docpad.getConfig()
                    srcPath = dpConfig.srcPath

                    test 'layoutsPath', (done) ->
                        expect(plugin.layoutsPath).to.equal(path.join(srcPath,'layouts','cms'))
                        done()

                    test 'filesPath', (done) ->
                        expect(plugin.filesPath).to.equal(path.join(srcPath,'files','cms'))
                        done()

                    test 'documentsPath', (done) ->
                        expect(plugin.documentsPath).to.equal(path.join(srcPath,'documents','cms'))
                        done()
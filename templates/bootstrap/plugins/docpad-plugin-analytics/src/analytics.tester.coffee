# Export Plugin Tester
module.exports = (testers) ->
    # PRepare
    {expect} = require('chai')

    # Define My Tester
    class AnalyticsTester extends testers.ServerTester
        # Test Generate
        #testGenerate: testers.RendererTester::testGenerate

        # Custom test for the server
        testServer: (next) ->
            # Prepare
            tester = @

            # Create the server
            super

            # Test
            @suite 'analytics', (suite,test) ->
                # Prepare
                
                test 'expect true to be true', (done) ->
                    expect(true).to.be.true
                    done()

                    
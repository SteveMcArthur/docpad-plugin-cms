# Export Plugin
module.exports = (BasePlugin) ->
    # Define Plugin
    google = require('googleapis')
    path = require('path')
    fs = require('fs')
    class AnalyticsPlugin extends BasePlugin
        # Plugin name
        name: 'analytics'
        # Config
        config:
            dataURL: '/analytics/data/:endPoint'

            #download your credentials file from
            #your google analytics account and place
            #it somewhere in your docpad project. The
            #default place is the root of the docpad application.
            credentialsFile: path.resolve(process.cwd(),'credentials.json')
            
            #possibility to add credentials directly to the config
            credentials: null
            
            #website id to add to queries when ids not supplied in query
            qryId: null
            
            #whether to send full data object returned by google or just
            #the rows and totals fields
            minimiseData: true
            
            cacheExpires: 1000*60*60
            
            #use google's query explorer (https://ga-dev-tools.appspot.com/query-explorer/)
            #to build your own queries.
            queries: []
        
        #common queries - these will be merged with any queries
        #provided as part of the config
        defaultQueries: require('./defaultQueries')
        
        getEndpoints: () ->
            queries = @getConfig().queries
            endpoints = []
            for q in queries
                if q.endPoint
                    endpoints.push(q.endPoint)
            return endpoints
        
        findQuery: (endPoint) ->
            queries = @getConfig().queries
            theQry = null
            for q in queries
                if q.endPoint instanceof Array
                    if q.endPoint.indexOf(endPoint) > -1
                        theQry = q.query
                else if q.endPoint == endPoint
                    theQry = q.query
            return theQry
        
        formatData: (rawData) ->
            minimiseData = @getConfig().minimiseData
            data = rawData
            if minimiseData
                data =
                    rows: rawData.rows
                    columnHeaders: rawData.columnHeaders
                    totalResults: rawData.totalResults
                    totalsForAllResults: rawData.totalsForAllResults
            return data
        
        retrieveData: (query,callback) ->
            authClient = @jwtClient
            plugin = @
            config = plugin.getConfig()
            
            cacheExpires = config.cacheExpires
            if query.cachedTime
                if ((new Date()).getTime() - query.cachedTime) < cacheExpires
                    data = plugin.formatData(query.cachedData)
                    return callback(null,data)
                else
                    query.cachedTime = undefined
                    query.cachedData = undefined
                    
            authClient.authorize (err, tokens) ->
                if (err)
                    callback(err)

                analytics = google.analytics('v3')
                query.auth = authClient
                analytics.data.ga.get query, (err, rawData) ->
                    if (err)
                        callback(err)
                    else
                        query.cachedTime = (new Date()).getTime()
                        query.cachedData = rawData
                        data = plugin.formatData(rawData)
                        callback(null,data)
                        
        
                        
            
        setConfig: ->
            super
            
            plugin = @
            endpoints = plugin.getEndpoints()
            queries = plugin.getConfig().queries
                    
            for q in plugin.defaultQueries
                if endpoints.indexOf(q.endPoint) == -1
                    queries.push(q)
            
            plugin.init()
            
            
         
        init: ->
            creds =  @config.credentials
            if !creds
                try
                    creds = require(@config.credentialsFile)
                catch err
                    @credentialsMissing = true
                    @docpad.log("warn","Analytics - no credentials file")
            if creds
                @jwtClient = new google.auth.JWT(creds.client_email, null, creds.private_key, ['https://www.googleapis.com/auth/analytics.readonly'], null)
            
        # Use to extend the server with routes that will be triggered before the DocPad routes.
        serverExtend: (opts) ->
            # Extract the server from the options
            {server} = opts
            plugin = @
            config = plugin.getConfig()
            
            queries = config.queries
            
            server.get config.dataURL, (req,res,next) ->
                if plugin.credentialsMissing
                    res.status(500).json({msg:"No credentials"})
                else                
                    endPoint = req.params.endPoint
                    if endPoint == "endpoints"
                        endPoints = plugin.getEndpoints()
                        res.json(endPoints)
                    else

                        theQry = plugin.findQuery(endPoint)

                        if theQry
                            try
                                if !theQry.ids
                                    theQry.ids = config.qryId
                                plugin.retrieveData theQry, (err,data) ->
                                    if err
                                        obj =
                                            msg:'error retrieving data',
                                            err: err
                                        res.status(500).json(obj)
                                    else
                                        res.json(data)
                            catch err
                                res.status(500).json(err)
                        else
                            res.status(500).json({msg:"Unable to find matching query"})
                        

            @
# Export Plugin
module.exports = (BasePlugin) ->
    # Define Plugin
    google = require('googleapis')
    path = require('path')
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
            
            cacheExpires: 1000*60*60*12
            
            #example of a google analytics api query. You will probably want
            #to use googles query explorer (https://ga-dev-tools.appspot.com/query-explorer/)
            #to build your own query.
            queries:[{
                'endPoint': ['30daysPageviews','uniquePageviews'],
                'query':{
                    'ids':'',#replace this with your own ID
                    'metrics': 'ga:uniquePageviews',
                    'dimensions': 'ga:pageTitle',
                    'start-date': '30daysAgo',
                    'end-date': 'yesterday',
                    'sort': '-ga:uniquePageviews',
                    'max-results': 10
                    }
                },{
                'endPoint': '7daysPageviews',
                'query':{
                    'ids':'',
                    'metrics': 'ga:uniquePageviews',
                    'dimensions': 'ga:pageTitle',
                    'start-date': '7daysAgo',
                    'end-date': 'yesterday',
                    'sort': '-ga:uniquePageviews',
                    'max-results': 10
                    }
                },{
                'endPoint': 'yesterdayPageviews',
                'query':{
                    'ids':'',
                    'metrics': 'ga:uniquePageviews',
                    'dimensions': 'ga:pageTitle',
                    'start-date': 'yesterday',
                    'end-date': 'yesterday',
                    'sort': '-ga:uniquePageviews',
                    'max-results': 10
                    }
                'endPoint': '60daySessions',
                'query':{
                    'ids':'',
                    'metrics': 'ga:sessions',
                    'dimensions': 'ga:date',
                    'start-date': '60daysAgo',
                    'end-date': 'yesterday',
                    'sort': '-ga:date',
                    'max-results': 60
                    }
                }]
        
        formatData: (rawData) ->
            minimiseData = @minimiseData
            data = rawData
            if minimiseData
                data =
                    rows: rawData.rows
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
        
        constructor: ->
            super
            
         
        init: ->
            creds =  @config.credentials
            if !creds
                creds = require(@config.credentialsFile)
            @jwtClient = new google.auth.JWT(creds.client_email, null, creds.private_key, ['https://www.googleapis.com/auth/analytics.readonly'], null)
            
        # Use to extend the server with routes that will be triggered before the DocPad routes.
        serverExtend: (opts) ->
            # Extract the server from the options
            {server} = opts
            plugin = @
            config = plugin.getConfig()
            
            plugin.init()
            queries = config.queries
            
            server.get config.dataURL, (req,res,next) ->
                endPoint = req.params.endPoint

                theQry = null
                for q in queries
                    if q.endPoint instanceof Array
                        if q.endPoint.indexOf(endPoint) > -1
                            theQry = q.query
                    else if q.endPoint == endPoint
                        theQry = q.query
                
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
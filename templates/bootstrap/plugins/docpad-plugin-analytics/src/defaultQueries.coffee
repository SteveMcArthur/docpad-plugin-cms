queries =
    [{
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
    },{
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
    },{
    'endPoint': '30dayCountry',
    'query':{
        'ids':'',
        'metrics': 'ga:sessions',
        'dimensions': 'ga:country,ga:countryIsoCode',
        'start-date': '30daysAgo',
        'end-date': 'yesterday',
        'sort': '-ga:sessions',
        'max-results': 10
        }
     },{
    'endPoint': '7daysCountry',
    'query':{
        'ids':'',
        'metrics': 'ga:sessions',
        'dimensions': 'ga:country,ga:countryIsoCode',
        'start-date': '7daysAgo',
        'end-date': 'yesterday',
        'sort': '-ga:sessions',
        'max-results': 10
        }
     },{
    'endPoint': 'yesterdayCountry',
    'query':{
        'ids':'',
        'metrics': 'ga:sessions',
        'dimensions': 'ga:country,ga:countryIsoCode',
        'start-date': 'yesterday',
        'end-date': 'yesterday',
        'sort': '-ga:sessions',
        'max-results': 10
        }
    },{
    'endPoint': 'browserAndOS',
    'query':{
        'ids':'',
        'metrics': 'ga:sessions',
        'dimensions': 'ga:browser,ga:browserVersion,ga:operatingSystem,ga:operatingSystemVersion',
        'start-date': '30daysAgo',
        'end-date': 'yesterday',
        'sort': '-ga:sessions',
        'max-results': 20
        }
    },{
    'endPoint': 'timeOnSite',
    'query':{
        'ids':'',
        'metrics': 'ga:sessions,ga:sessionDuration',
        'start-date': '30daysAgo',
        'end-date': 'yesterday',
        'max-results': 20
        }
    },{
    'endPoint': 'trafficSources',
    'query':{
        'ids':'',
        'metrics': 'ga:sessions,ga:pageviews,ga:sessionDuration,ga:exits',
        'dimensions': 'ga:source,ga:medium',
        'start-date': '30daysAgo',
        'end-date': 'yesterday',
        'max-results': 20
        }
    },{
    'endPoint': 'keywords',
    'query':{
        'ids':'',
        'metrics': 'ga:sessions',
        'dimensions': 'ga:keyword',
        'start-date': '30daysAgo',
        'end-date': 'yesterday',
        'sort': '-ga:sessions',
        'max-results': 20
        }
    }]

module.exports = queries
# The DocPad Configuration File
# It is simply a CoffeeScript Object which is parsed by CSON
docpadConfig =

    # =================================
    # Template Data
    # These are variables that will be accessible via our templates
    # To access one of these within our templates, refer to the FAQ: https://github.com/bevry/docpad/wiki/FAQ

    templateData:

        # Specify some site properties
        site:
            # The production url of our website
            # If not set, will default to the calculated site URL (e.g. http://localhost:9778)
            url: "http://website.com"

            # Here are some old site urls that you would like to redirect from
            oldUrls: [
                'www.website.com',
                'website.herokuapp.com'
            ]

            # The default title of our website
            title: "Your Website"

            # The website description (for SEO)
            description: """
                When your website appears in search results in say Google, the text here will be shown underneath your website's title.
                """

            # The website keywords (for SEO) separated by commas
            keywords: """
                place, your, website, keywoards, here, keep, them, related, to, the, content, of, your, website
                """

            # The website's styles
            styles: [
                '/vendor/normalize.css'
                '/vendor/h5bp.css'
                '/styles/style.css'
            ]

            # The website's scripts
            scripts: [
                """
                <!-- jQuery -->
                <script src="//ajax.googleapis.com/ajax/libs/jquery/2.1.0/jquery.min.js"></script>
                <script>window.jQuery || document.write('<script src="/vendor/jquery.js"><\\/script>')</script>
                """

                '/vendor/log.js'
                '/vendor/modernizr.js'
                '/scripts/script.js'
            ]


        # -----------------------------
        # Helper Functions

        # Get the prepared site/document title
        # Often we would like to specify particular formatting to our page's title
        # we can apply that formatting here
        getPreparedTitle: ->
            # if we have a document title, then we should use that and suffix the site's title onto it
            if @document.title
                "#{@document.title} | #{@site.title}"
            # if our document does not have it's own title, then we should just use the site's title
            else
                @site.title

        # Get the prepared site/document description
        getPreparedDescription: ->
            # if we have a document description, then we should use that, otherwise use the site's description
            @document.description or @site.description

        # Get the prepared site/document keywords
        getPreparedKeywords: ->
            # Merge the document keywords with the site keywords
            @site.keywords.concat(@document.keywords or []).join(', ')
            
        getLatestPosts: ->
            templateData = @
            collection = templateData.getCollection(templateData.postsCollectionName)
            if collection
                return collection.findAll({},{},{limit:4}).toJSON()
            else
                return templateData.getCollection('documents').findAll({},{},{limit:4}).toJSON()

        #required for the template that lists the posts
        getPosts: ->
            templateData = @
            collection = templateData.getCollection(templateData.postsCollectionName)
            if collection
                return collection.toJSON()
            else
                return templateData.getCollection('documents').findAllLive().toJSON()

        getPages: ->
            templateData = @
            collection = templateData.getCollection('pages')
            if collection
                return collection.toJSON()
            else
                return null

        getDocuments: ->
            templateData = @
            collection = templateData.getCollection('documents')
            if collection
                return collection.toJSON()
            else
                return null

        #required for the settings template
        getSettings: () ->
            settings = {}
            cfg = @config
            Object.keys(cfg).sort().forEach (key) ->
                settings[key] = cfg[key]
            return settings
        
        getUsers: () ->
            auth = @loadedPlugins["authentication"]
            auth.simpleMembership.getUsers()


    # =================================
    # Collections

    # Here we define our custom collections
    # What we do is we use findAllLive to find a subset of documents from the parent collection
    # creating a live collection out of it
    # A live collection is a collection that constantly stays up to date
    # You can learn more about live collections and querying via
    # http://bevry.me/queryengine/guide

    collections:

        # Create a collection called posts
        # That contains all the documents that will be going to the out path posts
        posts: ->
            @getCollection('documents').findAllLive({relativeOutDirPath: 'posts'})
            
        pages: ->
            pagesQry =
                relativeOutDirPath: $nin: ['cmsplus','posts']
                outExtension: 'html'
            @getCollection('documents').findAllLive(pagesQry)


    # =================================
    # Environments

    # DocPad's default environment is the production environment
    # The development environment, actually extends from the production environment

    # The following overrides our production url in our development environment with false
    # This allows DocPad's to use it's own calculated site URL instead, due to the falsey value
    # This allows <%- @site.url %> in our template data to work correctly, regardless what environment we are in

    environments:
        development:
            templateData:
                site:
                    url: false
                    
                    
    plugins:
        analytics:
            qryId: 'ga:97561085'

    # =================================
    # DocPad Events

    # Here we can define handlers for events that DocPad fires
    # You can find a full listing of events on the DocPad Wiki

    events:
    
        extendTemplateData: (opts) ->
            templateData = opts.templateData
            templateData.postsCollectionName = 'posts'

            #add the docpad config object to the templateData
            #so it can be accessed by the settings template
            templateData.config =  @docpad.getConfig()

        # Server Extend
        # Used to add our own custom routes to the server before the docpad routes are added
        serverExtend: (opts) ->
            # Extract the server from the options
            {server} = opts
            docpad = @docpad

            # As we are now running in an event,
            # ensure we are using the latest copy of the docpad configuraiton
            # and fetch our urls from it
            latestConfig = docpad.getConfig()
            oldUrls = latestConfig.templateData.site.oldUrls or []
            newUrl = latestConfig.templateData.site.url

            # Redirect any requests accessing one of our sites oldUrls to the new site url
            server.use (req,res,next) ->
                if req.headers.host in oldUrls
                    res.redirect(newUrl+req.url, 301)
                else
                    next()


# Export our DocPad Configuration
module.exports = docpadConfig
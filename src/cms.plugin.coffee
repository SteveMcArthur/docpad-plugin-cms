# Export Plugin
module.exports = (BasePlugin) ->
    fs = require('safefs')
    copy = require('fs-extra').copy
    path = require('path')
    ensurePaths = require('./helpers/ensurePaths')
    watchr = require('watchr')

    # Define Plugin
    class CmsPlugin extends BasePlugin
        # Plugin name
        name: 'cms'

        # Config
        config:
            #should be a better way of doing this
            templateLocation: path.join(fs.getParentPathSync(__dirname),'templates','bootstrap')
            templateFolder: 'cms'
            postsCollectionName: 'posts'
            copyTemplates: true
            
        layoutsPath: ''
        filesPath: ''
        documentsPath: ''
        tmpllayoutsDir: ''
        tmplfilesDir: ''
        tmpldocsDir: ''
        
        editURL: ''
        imageURL: ''
        dataURL: ''
        
        #destructor - needed to close
        #the watcher, else docpad will hang when
        #shutting down
        destroy: ->
            if @watcher
                @watcher.close()
                @watcher = null
            super
        
        setConfig: ->
            
            super
            
            plugin = @

            #setup data, versions and documents path
            ensurePaths(plugin.docpad,plugin)
            tplFolder = plugin.getConfig().templateFolder
            plugin.editURL = '/'+tplFolder+'/edit/*'
            plugin.imageURL =  '/'+tplFolder+'/images'
            plugin.dataURL = '/'+tplFolder+'/data/:item'
            
            #plugin.watchTemplates()
        
        watchListener: (type,pathToFile) ->
            if type == "update"
                dirname = path.dirname(pathToFile)
                outpath = ""
                inpath = ""
                if @tmpllayoutsDir.substr(dirname) == 0
                    outpath = @layoutsPath
                    inpath =  @tmpllayoutsDir
                else if @tmplfilesDir.substr(dirname) == 0
                    outpath = @filesPath
                    inpath = @tmplfilesDir
                else if @tmpldocsDir.substr(dirname) == 0
                    outpath = @docsPath
                    inpath = @tmpldocsDir
                if outpath
                    copy(inpath,outpath)
                
        
        watchTemplates: ->
            docpad = @docpad
            opts =
                path: @getConfig().templateLocation
                listener: @watchListener
            @watcher = watchr.watch(opts)

            
        requiredPlugins: ['eco','authentication','cleanurls','posteditor']
        checkPlugins: ->
            docpad = @docpad
            plugins = docpad.loadedPlugins
            for name in @requiredPlugins
                if !plugins[name]
                    docpad.log("warn","cms: "+name+" plugin not installed")
                
         
        pagesQry:
            relativeOutDirPath: $nin: ['cms','posts']
            outExtension: 'html'
        
        buildCollections: ->
            plugin = @
            docpad = plugin.docpad
            pagesCollection = docpad.getCollection('documents').findAllLive(plugin.pagesQry)
            pagesCollection.options.name = 'pages'
            docpad.addCollection(pagesCollection)
            
            
        #these properties will be added
        #to the docpad project's templateData
        templateHelpers:
            #used on the index template
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
         
        extendTemplateData: (opts) ->
            templateData = opts.templateData
            plugin = @
            templateData.postsCollectionName = plugin.getConfig().postsCollectionName
            plugin.buildCollections()
            plugin.checkPlugins()
            #add the docpad config object to the templateData
            #so it can be accessed by the settings template
            templateData.config =  plugin.docpad.getConfig()
            for key, val of plugin.templateHelpers
                if !templateData[key]
                    templateData[key] = plugin.templateHelpers[key]


        # Use to extend the server with routes that will be triggered before the DocPad routes.
        serverExtend: (opts) ->
            # Extract the server from the options
            {server} = opts
            plugin = @
            docpad = plugin.docpad
            
            #url to retrieve list of images to select for the feature image
            #in the post edit page
            server.get plugin.imageURL, (req,res,next) ->
                try
                    coll = docpad.getDatabase().findAllLive({relativeOutDirPath:'images'}).toJSON()
                    output = []
                    coll.forEach (item) ->
                        output.push(item.url)
                    
                    res.json(output)
                catch err
                    console.log(err)
                    res.status(500).json({success:false,msg:"unable to find images"})
             
            #retrieve the edit page from URL that contains the docId of the page
            #to be edited which is then loaded by js
            server.get plugin.editURL, (req,res,next) ->
                try
                    editPage = docpad.getCollection('documents').findOne({slug: 'cms-edit'})

                    if editPage
                        opts =
                            document:editPage
                            err:''
                            req: req
                            res: res

                        docpad.serveDocument(opts,next)
                    else
                        res.status(500).json({success:false,msg:'unable to find edit page!'})
                catch err
                    console.log("error getting edit page....")
                    console.log(err)
                    res.status(500).json({success:false,msg: err})
            
            #url to retrieve updated data by js
            server.get plugin.dataURL, (req,res,next) ->
                item = req.params.item
                if item == "user"
                    name = "Not logged in"
                    id = -1
                    if req.user and req.user.name
                        name = req.user.name
                        id = req.user.our_id
                    res.json({user:name,id: id})
            @
        


fs = require('safefs')
path = require('path')
copy = require('fs-extra').copy

dirExists = (pathname) ->
    try
        stats = fs.statSync(pathname)
        return stats.isDirectory()
    catch
        return false

setupFolders = (docpad,plugin) ->

    dpConfig = docpad.getConfig()
    tplFolder = plugin.getConfig().templateFolder
    dpConfig.layoutsPaths.forEach (item) ->
        if dirExists(item)
            plugin.layoutsPath = path.join(item,tplFolder)
    dpConfig.filesPaths.forEach (item) ->
        if dirExists(item)
            plugin.filesPath = path.join(item,tplFolder)
    dpConfig.documentsPaths.forEach (item) ->
        if dirExists(item)
            plugin.documentsPath = path.join(item,tplFolder)
                    
copyFiles = (plugin) ->
    config = plugin.getConfig()
    templateLocation = config.templateLocation
    plugin.tmpllayoutsDir = path.join(templateLocation,'src','layouts','cms')
    plugin.tmplfilesDir = path.join(templateLocation,'src','static','cms')
    plugin.tmpldocsDir = path.join(templateLocation,'src','render','cms')
    if config.copyTemplates
        console.log("Copy templates...")
        copy(plugin.tmpllayoutsDir,plugin.layoutsPath)
        copy(plugin.tmplfilesDir,plugin.filesPath)
        copy(plugin.tmpldocsDir,plugin.documentsPath)
    
ensurePaths = (docpad,plugin) ->
    setupFolders(docpad,plugin)
    copyFiles(plugin)
                    
                    
module.exports = ensurePaths
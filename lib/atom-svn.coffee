AtomSvnView = require './atom-svn-view'
AtomSvnFileList = require './models/file-list'
exec = require('child_process').exec

console.log "atom-svn here"

module.exports =
    atomSvnView: null
    atomSvnFileList: null

    activate: (state) ->
        atom.workspaceView.command 'svn:status', => @status()
        atom.workspaceView.command 'svn:close', => @close()
        console.log "atom-svn activated"

    deactivate: ->
        if @atomSvnView
            @atomSvnView.destroy()

    serialize: ->

    status: ->
        console.log "svn.status here"
        @atomSvnView = new AtomSvnView()
        atom.workspaceView.appendToRight(@atomSvnView)
        @atomSvnView.show()
        @atomSvnView.focus()

    close: ->
        @atomSvnView.destroy()

{$} = require 'atom'
AtomSvnFileListView = require './views/file-list'
AtomSvnFile = require './models/file'
execFile = require('child_process').execFile

console.log "atom-svn here"

module.exports =
    atomSvnFileListView: null
    files: null

    activate: (state) ->
        atom.workspaceView.command 'svn:status', => @status()
        atom.workspaceView.command 'svn:close', => @close()
        console.log "atom-svn activated"

    deactivate: ->
        if @atomSvnFileListView
            @atomSvnFileListView.destroy()

    serialize: ->

    status: ->
        console.log "svn.status here"
        # Run svn status
        # Construct model
        # Construct view and render it
        @atomSvnFileListView = new AtomSvnFileListView()
        atom.workspaceView.appendToRight(@atomSvnFileListView)
        @atomSvnFileListView.show()
        @atomSvnFileListView.focus()
        @_run_status()

    close: ->
        @atomSvnFileListView.destroy()

    _run_status: ->
        root = atom.project.getPath()
        @files = []
        execFile 'svn', ['status', '--xml'], { cwd: root }, (error, stdout, stderr) =>
            console.log "in svn status --xml..."
            if error
                console.error "Error running svn status: #{error}"
            if stderr
                console.error "svn status printed this error message: \n#{stderr}"
            if error or stderr
                return
            raw_data = stdout
            xml_data = $.parseXML(raw_data)
            xml_doc = $(xml_data)
            console.log xml_data
            xml_doc.find('entry').each (i, entry) =>
                file = new AtomSvnFile(entry)
                @files.push(file)
                file.select() if i is 0
            @atomSvnFileListView.populateFiles(@files)

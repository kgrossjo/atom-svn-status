{$} = require 'atom'
AtomSvnFileListView = require './views/file-list'
AtomSvnFile = require './models/file'
execFile = require('child_process').execFile

useSidebar = false

module.exports =
    atomSvnFileListView: null
    files: null

    activate: (state) ->
        atom.workspaceView.command 'svn:status', => @status()
        atom.workspaceView.command 'svn:close', => @close()

    deactivate: ->
        if @atomSvnFileListView
            @atomSvnFileListView.destroy()

    serialize: ->

    status: ->
        # Run svn status
        # Construct model
        # Construct view and render it
        @atomSvnFileListView = new AtomSvnFileListView(useSidebar)
        if (useSidebar)
            atom.workspaceView.appendToRight(@atomSvnFileListView)
        else
            atom.workspace.getActivePane().addItem(@atomSvnFileListView)
        @atomSvnFileListView.show()
        @atomSvnFileListView.focus()
        @_run_status()

    close: ->
        @atomSvnFileListView.destroy()

    _run_status: ->
        root = atom.project.getPath()
        @files = []
        execFile 'svn', ['status', '--xml'], { cwd: root }, (error, stdout, stderr) =>
            if error
                @atomSvnFileListView.populateErrors(["Error running svn status: #{error}"])
            if stderr
                @atomSvnFileListView.populateErrors("svn status printed this error message: \n#{stderr}")
            if error or stderr
                return
            raw_data = stdout
            xml_data = $.parseXML(raw_data)
            xml_doc = $(xml_data)
            xml_doc.find('entry').each (i, entry) =>
                file = new AtomSvnFile(entry)
                @files.push(file)
            @atomSvnFileListView.populateFiles(@files)

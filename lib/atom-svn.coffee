{$} = require 'atom'
AtomSvnFileListView = require './views/file-list'
AtomSvnFile = require './models/file'
execFile = require('child_process').execFile

module.exports =
    atomSvnFileListView: null
    files: null

    activate: (state) ->
        atom.workspaceView.command 'svn:status', => @status()
        atom.workspaceView.command 'svn:close', => @close()
        atom.workspaceView.command 'svn:toggle-selected', => @toggleMark()

    deactivate: ->
        if @atomSvnFileListView
            @atomSvnFileListView.destroy()

    serialize: ->

    status: ->
        # Run svn status
        # Construct model
        # Construct view and render it
        @atomSvnFileListView = new AtomSvnFileListView()
        pane = atom.workspace.getActivePane()
        pane.addItem(@atomSvnFileListView)
        pane.activateNextItem()
        @atomSvnFileListView.show()
        @atomSvnFileListView.focus()
        @_run_status()

    close: ->
        @atomSvnFileListView.destroy()
        pane = atom.workspace.getActivePane()
        pane.destroyItem(pane.getActiveItem())

    toggleMark: ->
        @atomSvnFileListView.toggleMark()

    _run_status: ->
        root = atom.project.getPath()
        @files = []
        execFile 'svn', ['status', '--xml'], { cwd: root }, (error, stdout, stderr) =>
            if error
                error = error.replace("\n", "<br>")
                @atomSvnFileListView.populateErrors(["Error running svn status: #{error}"])
            if stderr
                stderr = stderr.replace("\n", "<br>")
                @atomSvnFileListView.populateErrors(["svn status printed this error message: \n#{stderr}"])
            if error or stderr
                return
            raw_data = stdout
            xml_data = $.parseXML(raw_data)
            xml_doc = $(xml_data)
            xml_doc.find('entry').each (i, entry) =>
                file = new AtomSvnFile(entry)
                @files.push(file)
            @atomSvnFileListView.populateFiles(@files)

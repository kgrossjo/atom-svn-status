{$} = require 'atom-space-pen-views'
AtomSvnFileListView = require './views/file-list'
AtomSvnFile = require './models/file'
execFile = require('child_process').execFile

module.exports =
    atomSvnFileListView: null
    files: null

    activate: (state) ->
        atom.commands.add 'atom-workspace', 'svn:status', => @status()
        atom.commands.add 'atom-workspace', 'svn:close', => @close()
        atom.commands.add 'atom-workspace', 'svn:toggle-selected', => @toggleMark()
        atom.commands.add 'atom-workspace', 'svn:commit', => @commit()
        atom.commands.add 'atom-workspace', 'svn:refresh', => @refresh()

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

    refresh: ->
        @close()
        @status()

    toggleMark: ->
        @atomSvnFileListView.toggleMark()

    commit: ->
        roots = atom.project.getPaths()
        root = roots[0]
        files = @atomSvnFileListView.getFilesForCommit()
        console.log("Files")
        console.log(files)
        args = ['commit', '--editor-cmd', 'atom']
        console.log("Args")
        console.log( args.concat(files) )
        execFile 'svn', args.concat(files), { cwd: root }, (error, stdout, stderr) =>
            if error
                errstr = "#{error}"
                errlist = errstr.split(/\r?\n/)
                @atomSvnFileListView.populateErrors(
                    ["Error running svn commit:"].concat(errlist))
            if stderr
                errstr = "#{stderr}"
                errlist = errstr.split(/\r?\n/)
                @atomSvnFileListView.populateErrors(
                    ["svn commit printed this error message:"].concat(errlist))
            if error or stderr
                return
            console.log(stdout)
            @atomSvnFileListView.showOutput(stdout)

    _run_status: ->
        roots = atom.project.getPaths()
        root = roots[0]
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

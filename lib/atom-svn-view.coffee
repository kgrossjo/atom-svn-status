{$, $$, ScrollView} = require 'atom'
execFile = require('child_process').execFile
AtomSvnFile = require './models/file'
AtomSvnFileView = require './views/file'

module.exports =
    class AtomSvnView extends ScrollView
        fileList: null

        @content: ->
            @div class: 'atom-svn', =>
                @div class: 'resize-handle', outlet: 'resize_handle'
                @table class: 'table', =>
                    @thead =>
                        @tr =>
                            @th "Path"
                            @th "Status"
                            @th "PStatus"
                            @th "Working Rev"
                            @th "Committed"
                    @tbody outlet: 'entries'
                @div outlet: 'debug_data'

        initialize: (serializeState) ->
            @resize_handle.on "mousedown", @resize_started
            atom.workspaceView.command "svn:next", @next
            atom.workspaceView.command "svn:previous", @previous

        resize_started: =>
            $(document.body).on 'mousemove', @resize
            $(document.body).on 'mouseup', @resize_stopped

        resize_stopped: =>
            $(document.body).off 'mousemove', @resize
            $(document.body).off 'mouseup', @resize_stopped

        resize: ({pageX}) =>
            width = $(document.body).width() - pageX
            @width(width)


        # Returns an object that can be retrieved when package is activated
        serialize: ->

        # Tear down any state and detach
        destroy: ->
            console.log "Closing"
            @detach()

        show: ->
            root = atom.project.getPath()
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
                    file.select() if i is 0
                    file_view = new AtomSvnFileView(file)
                    @entries.append file_view

                @entries.find('td.svn-path').css('fontFamily', atom.config.get('editor.fontFamily'))

        _run_status: ->
            root = atom.project.getPath()
            files = []
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
                    files.push(file)
                    file.select() if i is 0
                # @_populate
                #     file_view = new AtomSvnFileView(file)
                #     @entries.append file_view
                #
                # @entries.find('td.svn-path').css('fontFamily', atom.config.get('editor.fontFamily'))


        next: ->

        previous: ->

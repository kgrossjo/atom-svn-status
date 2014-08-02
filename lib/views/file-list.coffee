{$, ScrollView} = require 'atom'
AtomSvnFile = require '../models/file'
AtomSvnFileView = require './file'

module.exports =
    class AtomSvnFileListView extends ScrollView
        files: null
        current: null

        @content: ->
            @div class: 'atom-svn', =>
                @div class: 'resize-handle', outlet: 'resize_handle'
                @div class: 'loading loading-spinner-small spinner', outlet: 'spinner'
                @div class: 'atom-svn-loading-indicator'
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
            @showSpinner()

        resize_started: =>
            $(document.body).on 'mousemove', @resize
            $(document.body).on 'mouseup', @resize_stopped

        resize_stopped: =>
            $(document.body).off 'mousemove', @resize
            $(document.body).off 'mouseup', @resize_stopped

        resize: ({pageX}) =>
            width = $(document.body).width() - pageX
            @width(width)

        showSpinner: ->
            @spinner.show()
        hideSpinner: ->
            @spinner.hide()

        # Returns an object that can be retrieved when package is activated
        serialize: ->

        # Tear down any state and detach
        destroy: ->
            console.log "Closing"
            @detach()

        populateFiles: (files) ->
            @files = []
            @current = 0
            for f in files
                v = new AtomSvnFileView(f)
                @files.push(v)
                @entries.append(v)
            @files[0].select()
            @entries.find('td.svn-path').css('fontFamily', atom.config.get('editor.fontFamily'))
            @hideSpinner()

        next: =>
            @files[@current].deselect()
            @current++
            if @current >= @files.length
                @current = @files.length
            @files[@current].select()

        previous: =>
            @files[@current].deselect()
            @current--
            if @current < 0
                @current = 0
            @files[@current].select()

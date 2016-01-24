{$, ScrollView} = require 'atom-space-pen-views'
AtomSvnFile = require '../models/file'
AtomSvnFileView = require './file'

module.exports =
    class AtomSvnFileListView extends ScrollView
        files: null
        current: null

        @content: () ->
            @div class: 'atom-svn', tabindex: -99, =>
                @div class: 'resize-handle', outlet: 'resize_handle'
                @div class: 'loading loading-spinner-small spinner', outlet: 'spinner'
                @ul outlet: 'errors', class: 'error-messages block'
                @div outlet: 'output_panel', class: 'atom-svn-output', =>
                    @h3 "Command output"
                    @pre outlet: 'output'
                @div class: 'atom-svn-filelist', =>
                    @table class: 'table', =>
                        @thead =>
                            @tr =>
                                @th " "
                                @th "Path"
                                @th "Status"
                                @th "PStatus"
                                @th "Working Rev"
                                @th "Committed"
                        @tbody outlet: 'entries'
                @div outlet: 'debug_data'

        initialize: () ->
            @output_panel.hide()
            @resize_handle.on "mousedown", @resize_started
            atom.commands.add '.atom-svn', 'svn:next', @next
            atom.commands.add '.atom-svn', 'svn:previous', @previous
            @showSpinner()
            @on 'click', @focus

        getTitle: ->
            return "svn status"

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

        focus: =>
            super
            $(this[0]).addClass('focused')

        unfocus: =>
            $(this[0]).removeClass('focused')

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
                v = new AtomSvnFileView(f, this)
                @files.push(v)
                @entries.append(v)
            @files[0].select()
            @entries.find('td.svn-path').css('fontFamily', atom.config.get('editor.fontFamily'))
            @hideSpinner()
            @errors.hide()

        populateErrors: (errors) ->
            for e in errors
                @errors.append("<li>#{e}</li>")
            @errors.show()
            @hideSpinner()

        showOutput: (output) ->
            @output.text(output)
            @output_panel.show()

        next: =>
            iLast = -1 + @files.length
            @files[@current].deselect()
            @current++
            if @current >= iLast
                @current = iLast
            @files[@current].select()

        previous: =>
            @files[@current].deselect()
            @current--
            if @current < 0
                @current = 0
            @files[@current].select()

        toggleMark: =>
            @files[@current].toggleMark()

        selectItem: (item) ->
            @files[@current].deselect()
            index = @files.indexOf(item)
            @current = index
            @files[@current].select()

        getFilesForCommit: ->
            markedFiles = @getMarkedFiles()
            console.log("getFilesForCommit")
            console.log(markedFiles)
            result = []
            for file in markedFiles
                console.log("File")
                console.log(file)
                continue if not file.canCommit()
                console.log("File path = " + file.getPath())
                result.push(file.getPath())
            return result

        getMarkedFiles: ->
            result = []
            for file in @files
                result.push(file) if file.isMarked()
            return result

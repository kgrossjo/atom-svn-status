{$} = require 'atom'

status_map =
    unversioned: '?'
    external: 'X'
    modified: 'M'

module.exports =
    class AtomSvnFile

        constructor: (entry) ->
            @marked = false
            wcstatus = $(entry).find('wc-status')
            @status = ''
            @longStatus = ''
            @pstatus = ''
            @wrev = ''
            if wcstatus
                commit = $(wcstatus).find('commit')
                @longStatus = wcstatus.attr('item')
                @status = status_map[@longStatus] or @longStatus
                @wrev = wcstatus.attr('revision') or ''
                @pstatus = wcstatus.attr('props')
                if commit
                    @crev = commit.attr('revision') or ''
                    @author = $(commit).find('author').text()
                    @date = $(commit).find('date').text()
            @path = $(entry).attr('path')

            @selected = false

            if not @path
                throw {name: 'NullError', message: 'path was null'}

        select: ->
            @selected = true
        deselect: ->
            @selected = false

        isSelected: ->
            @selected

        canCommit: ->
            return @longStatus == 'modified'

        toggleMark: ->
            @marked = ! @marked

        isMarked: ->
            return @marked

        getPath: ->
            return @path

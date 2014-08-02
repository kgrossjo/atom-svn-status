{$} = require 'atom'

status_map =
    unversioned: '?'
    external: 'X'
    modified: 'M'

module.exports =
    class AtomSvnFile

        constructor: (entry) ->
            wcstatus = $(entry).find('wc-status')
            @status = ''
            @pstatus = ''
            @wrev = ''
            if wcstatus
                commit = $(wcstatus).find('commit')
                @status = wcstatus.attr('item')
                @status = status_map[status] or status
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

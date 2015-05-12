{View} = require 'atom-space-pen-views'

module.exports =
    class AtomSvnFileView extends View
        file: null
        parent: null

        @content: (file, parent) ->
            selected_class = ''
            if file.isSelected()
                selected_class = 'selected'
            date = new Date(file.date) if file.date
            commit_info = ''
            commit_info += "r#{file.crev} " if file.crev
            commit_info += "by #{file.author} " if file.author
            commit_info += "at #{date}" if date
            @tr click: 'focus', class: selected_class, =>
                @td class: 'svn-marked', =>
                    @input type: 'checkbox', outlet: 'checkbox', selected: file.marked
                @td class: 'svn-path', file.path
                @td class: 'svn-status', file.status
                @td class: 'svn-pstatus', file.pstatus
                @td class: 'svn-wrev', file.wrev
                @td class: 'svn-commit', commit_info

        initialize: (_file, _parent) ->
            @file = _file
            @parent = _parent
            if @file is null
                throw new ReferenceError("@file is null")
            if @file is undefined
                throw new ReferenceError("@file is undefined")
            @checkbox.on('click', @toggleMark)

        select: () ->
            @file.select()
            @addClass('selected')

        deselect: () ->
            @file.deselect()
            @removeClass('selected')

        setSelected: (flag) ->
            if flag
                @select()
            else
                @deselect()

        focus: ->
            @parent.selectItem(this)

        toggleMark: =>
            @file.toggleMark()
            @find('td.svn-marked input').prop('checked', @file.marked)

        isMarked: ->
            return @file.isMarked()

        canCommit: ->
            return @file.canCommit()

        getPath: ->
            return @file.getPath()

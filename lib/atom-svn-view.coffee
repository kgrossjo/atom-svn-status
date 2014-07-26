{$, $$, ScrollView} = require 'atom'
exec = require('child_process').exec

status_map =
    unversioned: '?'
    external: 'X'
    modified: 'M'

module.exports =
    class AtomSvnView extends ScrollView
        @content: ->
            @div class: 'atom-svn', =>
                @table =>
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

        # Returns an object that can be retrieved when package is activated
        serialize: ->

        # Tear down any state and detach
        destroy: ->
            console.log "Closing"
            @detach()

        show: ->
            root = atom.project.getPath()
            exec 'svn status --xml', { cwd: root }, (error, stdout, stderr) =>
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
                    wcstatus = $(entry).find('wc-status')
                    status = ''
                    pstatus = ''
                    wrev = ''
                    commit_info = ''
                    if wcstatus
                        commit = $(wcstatus).find('commit')
                        status = wcstatus.attr('item')
                        status = status_map[status] or status
                        wrev = wcstatus.attr('revision') or ''
                        pstatus = wcstatus.attr('props')
                        if commit
                            crev = commit.attr('revision') or ''
                            author = $(commit).find('author').text()
                            date = $(commit).find('date').text()
                            if date
                                date = new Date(date)
                            commit_info = ''
                            commit_info += "r#{crev} " if crev
                            commit_info += "by #{author} " if author
                            commit_info += "at #{date}" if date
                    path = $(entry).attr('path')
                    @entries.append """
                        <tr>
                            <td class='svn-path'>#{path}</td>
                            <td class='svn-status'>#{status}</td>
                            <td class='svn-pstatus'>#{pstatus}</td>
                            <td class='svn-wrev'>#{wrev}</td>
                            <td class='svn-commit'>#{commit_info}</td>
                        </tr>
                    """

                @entries.find('td.svn-path').css('fontFamily', atom.config.get('editor.fontFamily'))

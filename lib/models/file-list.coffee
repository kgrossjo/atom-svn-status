
module.exports =
    class FileList

        constructor: (@files) ->
            @files.forEach (x) ->
                x.deselect()
            @current = 0
            @files[@current].select()

        previous: ->
            @files[@current].deselect()
            @current--
            if @current < 0
                @current = 0
            @files[@current].select()

        next: ->
            @files[@current].deselect()
            @current++
            if @current >= @files.length
                @current = -1 + @files.length
            @files[@current].select()
        

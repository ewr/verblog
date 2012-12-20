window.Verblog ?= {}

Verblog.highlight = (el) ->
    el = $(el)
        
    # get original background color
    orig = el.css("background-color")
    console.log "animating #{el} from ", orig
    
    el.animate "backgroundColor": "#ffc", "fast", "swing", ->
        console.log "at highlight bg"
        el.animate "background-color": orig, "fast", "swing", ->
            console.log "highlight reversed"
window.Verblog ?= {}

Verblog.highlight = (el) ->
    el = $(el)
        
    # get original background color
    orig = el.css("backgroundColor")
    console.log "animating #{el} from ", orig
    
    $(el).each ->
        el = $(this)
        $("<div/>")
        .width(el.outerWidth())
        .height(el.outerHeight())
        .css({
            "position": "absolute",
            "left": el.offset().left,
            "top": el.offset().top,
            "background-color": "#ffff99",
            "opacity": ".7",
            "z-index": "9999999"
        }).appendTo('body').fadeOut(1000).queue -> $(this).remove();

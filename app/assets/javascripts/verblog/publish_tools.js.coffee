#= require "verblog/templates/author_opts"
#= require "verblog/templates/author_view"
#= require "verblog/templates/preview"

class Verblog.AuthorWidget
  constructor: (el,url,@vsp) ->
    console.log "AuthorWidget Go!"
    
    @el = $(el)
    @aEl = $ "<div/>", class:"authors"
    @optsEl = $ "<div/>", class:"author_opts"
      
    @el.append @aEl, @optsEl
    
    @authors = new AuthorWidget.Authors()
    @authors.url = url
    
    @authorsView = new AuthorWidget.AuthorsView collection:@authors
    @aEl.html @authorsView.render()
    
    @optsView = new AuthorWidget.OptsView()
    @optsEl.html @optsView.render().el
    
    # -- set up a handler for adding authors -- #
    
    @optsView.on "click", (id) =>      
      # post to create an author
      $.post url, user_id:id, (data) =>
        @authors.add data
        @_rebuildAuthorOpts()
        
        # update preview if provided
        @vsp?.update()
      .error (resp) =>
        alert("Error: #{resp.responseText}")
        
    @authors.on "remove change:is_primary", => 
      @_rebuildAuthorOpts()
      
      # update preview if provided
      @vsp?.update()
    
    # -- get our current / available authors -- #
    
    $.getJSON url, (obj) =>
      # stash the list of all possible authors
      @all = obj.all
      
      # reset the authors collection
      @authors.reset obj.authors
      
      @_rebuildAuthorOpts(true)
      
  #----------
  
  _rebuildAuthorOpts: (skip_animation=false)->
    ids = @authors.pluck "user_id"
    
    rest = _(@all).reject (u) -> _(ids).contains u.id
    @optsView.render rest
    Verblog.highlight @el unless skip_animation
    true
      
  #----------
  
  @OptsView: Backbone.View.extend
    template: JST["verblog/templates/author_opts"]
    
    events:
      "click button": "_click"
    
    render: (opts=[]) ->
      # sort our opts
      opts = _(opts).sortBy (a) => a.name.split(" ").reverse().join("")
      
      @$el.html @template options:opts
      
      if opts.length == 0
        @$el.find("select").addClass("disabled")
        @$el.find("button").addClass("disabled")
      
      @
      
    _click: (evt) ->
      # which name is selected?
      a = @$el.find(":selected")[0]
      
      if a
        id = $(a).attr("value")
        @trigger "click", id
  
  #----------
      
  @AuthorView: Backbone.View.extend
    tagName: "li"
    template: JST["verblog/templates/author_view"]
    
    events:
      "click button.toggle": "_toggle"
      "click button.btn-danger": "_remove"
      
    initialize: ->
      @model.on "change", => @render()
    
    render: ->
      @$el.html @template @model.toJSON()
      @
      
    _toggle: ->
      @model.save is_primary: (if @model.get("is_primary") then false else true)
      @model.collection.sort()
      
    _remove: ->
      @model.destroy()
    
  #----------
    
  @AuthorsView: Backbone.CollectionView.extend
    itemView: @AuthorView
    tagName: "ul"
    
  #----------
    
  @Author: Backbone.Model.extend()
  
  #----------
    
  @Authors: Backbone.Collection.extend
    model: @Author
    
    comparator: (a) ->
      "#{Number(!a.get("is_primary"))}#{a.get('name').split(" ").reverse().join("")}"
      
#----------

class Verblog.AssetCatcher
  constructor: (el) ->
    @el = $(el)
    
    @posX = null
    @posY = null
    
    @el.bind "dragover", (evt) =>
      
      #evt.stopPropagation()
      #evt.preventDefault()
          
    @el.bind "drop", (evt) =>
      evt = evt.originalEvent
        
      evt.stopPropagation()
      evt.preventDefault()
      
      json = JSON.parse(evt.dataTransfer.getData 'application/json')
      
      if json
        pos = 0
        el = evt.target
        if el.selectionStart?
          pos = el.selectionStart
        else if document.selection?
          el.focus()
          Sel = document.selection.createRange()
          SelLength = document.selection.createRange().text.length
          Sel.moveStart('character', -el.value.length)
          pos = Sel.text.length - SelLength
        
        #console.log "Catcher got asset of ", json, evt, pos
        
        tag = "[ASSET #{json['id']} \"#{json['caption']}\"]"

        el.value = el.value.substr(0,pos) + tag + el.value.substr(pos)

#----------

class Verblog.StoryPreview
  constructor: (el,@url) ->
    @el = $(el)
    
  update: ->
    $.ajax
      url: @url
      type: "POST"
      data: {}
      dataType: "json"
      success: (r) =>
        console.log "got success of ", r
        @el.html r.preview
        Verblog.highlight @el

#----------
  
class Verblog.PopupPreview
  template: JST["verblog/templates/preview"]
  
  constructor: (btn,@url,model,fields) ->
    $(btn).on "click", (evt) =>
      # look up our values
      m = {}
      m[model] = {}
      
      for f in fields
        m[model][f] = $("##{model}_#{f}").val()
      
      $.ajax
        url: @url
        type: "POST"
        data: m
        dataType: "json"
        success: (r) =>
          console.log "got success of ", r
          
          $( @template(preview:r.preview) ).modal()

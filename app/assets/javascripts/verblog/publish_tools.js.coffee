#= require "verblog/templates/author_opts"

class Verblog.AuthorWidget
  constructor: (el,url) ->
    console.log "AuthorWidget Go!"
    
    @el = $(el)
    @aEl = $ "<div/>", class:"authors"
    @optsEl = $ "<div/>", class:"author_opts"
      
    @el.append @aEl, @optsEl
    
    @authors = new AuthorWidget.Authors()
    
    @authorsView = new AuthorWidget.AuthorsView collection:@authors
    @aEl.html @authorsView.render().el
    
    @optsView = new AuthorWidget.OptsView()
    @optsEl.html @optsView.render().el
    
    # get our current / available authors
    $.getJSON url, (obj) =>
      # reset the authors collection
      @authors.reset obj.authors
      
      ids = a.user_id for a in obj.authors
      
      # rebuild the opts array
      
      @optsView.render _(obj.all).reject (u) => @authors.where(id:u.id)
      
  #----------
  
  @OptsView: Backbone.View.extend
    template: JST["verblog/templates/author_opts"]
    
    render: (opts=[]) ->
      @$el.html @template options:opts
  
  #----------
      
  @AuthorView: Backbone.View.extend
    tagName: "li"
    
    render: ->
      @$el.html @model.get("name")
    
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
      "#{Number(a.is_primary)}#{a.get('name').split(" ").reverse().join("")}"
      
  #----------
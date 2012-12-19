Verblog::Engine.routes.draw do
  # Verblog routes
  match '/:year/:month/:id', :to => 'story#show', :constraints => {
    :year => /\d+/,
    :month => /\d+/,
    :id => /[\w-]+/
  }
  
  resources :story do
    member do
      post :assets
      post :scheme
      post :status
      post :preview
      post :authors
      get :authors
    end
  end
      
  match '/feed', :to => "feed#feed", :as => :feed
  match '/_feed', :to => "feed#feed"
      
  match '/archives', :to => 'archives#index', :as => :archives
  
  match '/:year/:month', :to => 'archives#month', :as => :archive_month, :constraints => {
    :year => /\d+/,
    :month => /\d+/
  }
  
  match '/page/:page', :to => "home#index", :as => :page
  root :to => 'home#index', :as => :home
end

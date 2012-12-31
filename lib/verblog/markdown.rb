module Verblog
  class Markdown
    # -- Asset Handling -- #
    
    class HTMLWithAssets < Redcarpet::Render::HTML
      def initialize(render_assets=true,options={})
        @render_assets = render_assets
        super options
      end
      
      #----------
      
      def preprocess(full_document)
        if @render_assets
          full_document.gsub!(/\[ASSET (\d+)(?: "([^"]+)")(?: (\w+))?\]/) do 
            # Look up the asset ID and make sure it is valid
            begin
              caption = $2
              scheme = $3
              a = Verblog::Engine.asset_model.find($1)
            rescue ActiveRecord::RecordNotFound
              "INVALID ASSET ID (#{$1})"
            else
              self._render_asset(a,caption,scheme)
            end

          end
        end
        
        full_document
      end
      
      #----------
      
      def _render_asset(asset,caption="",scheme="default")
        # Register a content trigger on the assets collection
        #register_content "#{content.obj_key}:assets"
        
        # create a fake story asset
        sa = StoryAsset.new
        sa.asset = asset
        sa.caption = caption || asset.caption
      
        view = ActionView::Base.new(ActionController::Base.view_paths, {})
        class << view
          include Verblog::ApplicationHelper
        end
                
        context = "inline"

        # set up our template precendence
        tmplt_opts = [
          "#{context}/#{scheme}",
          "#{context}/default",
          "default/#{scheme}",
          "default/default"
        ]
      
        partial = tmplt_opts.detect { |t| view.lookup_context.exists?(t,["verblog/shared/assets"],true) }

        view.render :partial => "verblog/shared/assets/#{partial}", :object => [sa], :as => :assets, :locals => { :content => nil }
      end
    end
    
    # -- Pygments Support -- #
    
    class HTMLWithPygments < HTMLWithAssets
      def block_code(code,language)    
        if language && Pygments.lexers.keys.collect {|k| k.downcase }.include?(language)
          Pygments.highlight(code, :lexer => language)
        else
          Pygments.highlight(code)      
        end
    
      end
    end
    
    #----------
    
    def initialize
      
      mclass = Verblog::Config.markdown_pygments ? HTMLWithPygments : HTMLWithAssets
      
      @markdown = Redcarpet::Markdown.new( mclass.new(Verblog::Config.markdown_assets),
        :no_intra_emphasis => true,
        :fenced_code_blocks => true
      )
    end
    
    #----------
    
    def render(text)
      @markdown.render(text)
    end
    
  end
end
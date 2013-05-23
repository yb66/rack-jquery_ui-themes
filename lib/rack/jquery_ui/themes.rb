require "rack/jquery_ui/themes/version"
require "rack/jquery/helpers"

# @see http://rack.github.io/
module Rack

  # @see https://github.com/yb66/rack-jquery_ui
  class JQueryUI
  
    # jQuery-UI themes' CDN script tags and fallback in one neat package.
    class Themes
      include JQuery::Helpers
  
      # The standard CSS file.
      JQUERY_UI_THEME_FILE = "jquery-ui.min.css"
  
      # Script tags for the Media Temple CDN
      MEDIA_TEMPLE = "<link rel='stylesheet' href='http://code.jquery.com/ui/#{JQueryUI::JQUERY_UI_VERSION}/themes/:THEME/jquery-ui.css' type='text/css' />"
  
      # Script tags for the Google CDN
      GOOGLE = "<link rel='stylesheet' href='//ajax.googleapis.com/ajax/libs/jqueryui/#{JQueryUI::JQUERY_UI_VERSION}/themes/:THEME/jquery-ui.css' type='text/css' />"
  
      # Script tags for the Microsoft CDN
      MICROSOFT = "<link rel='stylesheet' href='//ajax.microsoft.com/ajax/jquery.ui/#{JQueryUI::JQUERY_UI_VERSION}/themes/:THEME/jquery-ui.css' type='text/css' />"
  
      # This javascript checks if the jQuery-UI object has loaded. If not, that most likely means the CDN is unreachable, so it uses the local jQuery-UI theme.
      FALLBACK = <<STR
<script type="text/javascript">
$.each(document.styleSheets, function(i,sheet){
  if(sheet.href=='http://code.jquery.com/mobile/1.0b3/jquery.mobile-1.0b3.min.css') {
    var rules = sheet.rules ? sheet.rules : sheet.cssRules;
    if (rules.length == 0) {
      $('<link rel="stylesheet" type="text/css" href="/js/jquery-ui/#{JQueryUI::JQUERY_UI_VERSION}/themes/:THEME/#{JQUERY_UI_THEME_FILE}" />').appendTo('head');
    }
 }
})
</script>
STR
  
      # List of the standard themes provided by jQuery UI.
      STANDARD_THEMES = %w{base black-tie blitzer cupertino dark-hive dot-luv eggplant excite-bike flick hot-sneaks humanity le-frog mint-choc overcast pepper-grinder redmond smoothness south-street start sunny swanky-purse trontastic ui-darkness ui-lightness vader}
  

      # The chosen theme name.
      # @return [String]
      def self.theme
        @theme ||= "base"
      end
  

      # Set the theme.
      # @param [String] name Name of the theme.
      # @return [String]
      def self.theme=( name )
        fail ArgumentError, "That theme (#{name}) is unknown for this version of the rack-jquery_ui-themes library." unless STANDARD_THEMES.include? name
        @theme = name
      end
  
  
      # @param [Symbol] :organisation Choose which CDN to use, either :google, :microsoft or :media_temple
      # @param [Hash] opts
      # @option opts [#to_s] :theme
      # @return [String] The HTML script tags to get the CDN.
      # @example
      #   Rack::JQueryUI::Themes.cdn :google, theme: "dot-luv"
      def self.cdn( organisation=:google, opts={} )
        theme = opts.fetch :theme, self.theme
        fail ArgumentError, "That theme (#{theme}) is unknown for this version of the rack-jquery_ui-themes library." unless STANDARD_THEMES.include? theme
        script = case organisation
          when :media_temple then MEDIA_TEMPLE
          when :microsoft then MICROSOFT
          else GOOGLE
        end
        [script,FALLBACK].map{|x| x.sub(/\:THEME/, theme) }.join("\n")
      end
  
  
      # Default options hash for the middleware.
      DEFAULT_APP_OPTIONS = {
        :http_path => "/js/jquery-ui/#{JQueryUI::JQUERY_UI_VERSION}/themes/"
      }
  
  
      # @param [#call] app
      # @param [Hash] options
      # @option options [String] theme The theme to use. The default is "base".
      # @option options [String] :http_path If you wish the jQuery CSS fallback route to be "/js/jquery-ui/1.10.1/base/jquery-ui.min.css" (or whichever version this is at) then do nothing, that's the default. If you want the path to be "/assets/javascripts/jquery-ui/1.10.1/base…" then pass in `:http_path => "/assets/javascripts/#{Rack::JQueryUI::JQUERY_UI_VERSION}".
      # @note ***Don't leave out the version number!***. The scripts provided by jQuery don't contain the version in the filename like the jQuery scripts do, which means that organising them and sending the right headers back is bound to go wrong unless you put the version number somewhere in the route. You have been warned!
      # @example
      #   # The default:
      #   use Rack::JQueryUI::Themes
      def initialize( app, options={} )
        @app, @options  = app, DEFAULT_APP_OPTIONS.merge(options)
        self.class.theme = options[:theme] unless options[:theme].nil?
        @http_path_to_jquery_css = ::File.join(
          @options[:http_path],        
          self.class.theme,
          JQUERY_UI_THEME_FILE
        )
        @http_path_to_jquery_images = ::File.join(
          @options[:http_path],        
          self.class.theme,
          "images"
        )
  
        # set the path to all the assets
        rel_path_to_vendor = "../../../../"
        path_to_themes = "vendor/assets/javascripts/jquery-ui"
        version_and_theme = "#{JQueryUI::JQUERY_UI_VERSION}/themes/#{self.class.theme}"
        @path_to_theme = ::File.expand_path( ::File.join( rel_path_to_vendor, path_to_themes, version_and_theme ), __FILE__)
        @path_to_images = ::File.join @path_to_theme, "images"
        d = Dir.new(@path_to_images)
        @images = d.entries.delete_if{|f| f =~ /^\./ }.select{|f| 
          Rack::Mime.mime_type(::File.extname(f), "text/css" ).start_with? "image" 
        }
      end


      # @param [Hash] env Rack request environment hash.
      def call( env )
        dup._call env
      end
  
  
      # For thread safety
      # @param (see #call)
      def _call( env )
        request = Rack::Request.new(env.dup)
  
        # TODO path for images
  
        # path for CSS
        if request.path_info.start_with? @options[:http_path]
          response = Rack::Response.new
          if request.path_info.end_with? ::File.join(self.class.theme,JQUERY_UI_THEME_FILE)
            # serve CSS
            # for caching
            response.headers.merge! caching_headers("#{JQUERY_UI_THEME_FILE}-#{self.class.theme}-#{JQueryUI::JQUERY_UI_VERSION}", JQueryUI::JQUERY_UI_VERSION_DATE)
            # There's no need to test if the IF_MODIFIED_SINCE against the release date because the header will only be passed if the file was previously accessed by the requester, and the file is never updated. If it is updated then it is accessed by a different path.
            requested_file = open(::File.join(@path_to_theme, JQUERY_UI_THEME_FILE ), "r")
          elsif request.path_info =~ /images/ && 
                (fin = request.path_info.split("/").last)
                (img = @images.find{|img| img == fin })
            # serve images
            requested_file = open ::File.join( @path_to_images, img), "rb"
          else # bad route
            response.status = 404
            return response.finish # finish early, 404
          end
          if request.env['HTTP_IF_MODIFIED_SINCE']
            response.status = 304
          else
            response.status = 200
            mime = Mime.mime_type(::File.extname(requested_file.path), 'text/css')
            response.headers.merge!( "Content-Type" => mime ) if mime
            response.write ::File.read( requested_file )
          end
          response.finish
        else
          @app.call(env)
        end
      end # call
  
  
    end # Themes
  end
end

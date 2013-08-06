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


      # Namespaced for convenience, to help with checking
      # which CDN supports what.
      module CDN
  
        # URL for the Media Temple CDN
        MEDIA_TEMPLE = "http://code.jquery.com/ui/#{JQueryUI::JQUERY_UI_VERSION}/themes/:THEME/jquery-ui.min.css"
    
        # URL for the Google CDN
        GOOGLE = "//ajax.googleapis.com/ajax/libs/jqueryui/#{JQueryUI::JQUERY_UI_VERSION}/themes/:THEME/jquery-ui.min.css"
    
        # URL for the Microsoft CDN
        MICROSOFT = "//ajax.microsoft.com/ajax/jquery.ui/#{JQueryUI::JQUERY_UI_VERSION}/themes/:THEME/jquery-ui.min.css"

      end


      # This javascript checks if the jQuery-UI object has loaded by issuing a head request to the CDN. If it doesn't get a successful status, that most likely means the CDN is unreachable, so it uses the local jQuery-UI theme.
      FALLBACK = <<STR
<script type="text/javascript">
  var has_jquery_rules = false;
  var i = document.styleSheets.length - 1;
  while (i >= 0 ) {
    var sheet = document.styleSheets[i];
    if(sheet.href == ":CDNURL/ui/#{JQueryUI::JQUERY_UI_VERSION}/themes/:THEME/jquery-ui.min.css") {
      var rules = sheet.rules ? sheet.rules : sheet.cssRules;
      has_jquery_rules = rules.length == 0 ? false : true;
      break; // end the loop.
    }
    has_jquery_rules = false;
    i--;
  }
  if ( has_jquery_rules == false ) {
    $('<link rel="stylesheet" type="text/css" href="/js/jquery-ui/#{JQueryUI::JQUERY_UI_VERSION}/themes/:THEME/#{JQUERY_UI_THEME_FILE}" />').appendTo('head');
  }
</script>
STR

  
      # List of the standard themes provided by jQuery UI.
      STANDARD_THEMES = %w{black-tie blitzer cupertino dark-hive dot-luv eggplant excite-bike flick hot-sneaks humanity le-frog mint-choc overcast pepper-grinder redmond smoothness south-street start sunny swanky-purse trontastic ui-darkness ui-lightness vader}


      # @param [Hash] env The rack env hash.
      # @param [Hash] opts
      # @option opts [#to_sym] :organisation Choose which CDN to use, either :media_temple, :microsoft, or :media_temple.
      # @option opts [#to_s] :theme Theme to use. Won't set any routes or permanent settings, see note.
      # @option opts [TrueClass, Symbol] :fallback `true` if you want a fallback script, `false` if you don't, and `:only` if you don't want the CDN link but you do want just the fallback script. `true` is the default.
      # @return [String] The HTML script tags to get the CDN, with a JQuery function that will be called if the CDN fails and sets the fallback path.
      # @example
      #   # The easiest, use the defaults:
      #   Rack::JQueryUI::Themes.cdn env
      #
      #   # Choose a CDN to favour:
      #   Rack::JQueryUI::Themes.cdn env, :organisation => :media_temple
      #
      #   # Choose a theme to use:
      #   Rack::JQueryUI::Themes.cdn env, :organisation => :media_temple, theme: "dot-luv"
      #
      # @note
      #   The :theme option can override those given when
      #   setting up the middleware (see {#initialize}), but if the theme given here
      #   is not in the themes already set up, then there'll be
      #   no URL paths for it, so use this option to pick which
      #   theme is favoured *from the already given set*.
      def self.cdn( env, opts={} )
        organisation = opts[:organisation] || :media_temple
        themes = env["rack.jquery_ui-themes"]
        theme, themes = sort_out_options opts.merge :themes => themes
        fallback = opts[:fallback] || true

        # Get the CDN URL for the given organisation.
        url = case organisation.to_sym
          when :google then CDN::GOOGLE
          when :microsoft then CDN::MICROSOFT
          when :media_temple then CDN::MEDIA_TEMPLE
          else CDN::MEDIA_TEMPLE
        end

        script_name = env.fetch("SCRIPT_NAME","/")

        fallback_url = ::File.join script_name, "/js/jquery-ui/#{JQueryUI::JQUERY_UI_VERSION}/themes/:THEME/#{JQUERY_UI_THEME_FILE}"

        fallback_script = FALLBACK.gsub(/\:CDNURL/, url)
                                  .sub /\:FALLBACK_URL/, fallback_url

        if fallback == :only
          fallback_script.gsub(/\:THEME/, theme)
        else
          script = "<link rel='stylesheet' href='#{url}' type='text/css' />"
          if fallback == false
            script.gsub(/\:THEME/, theme)
          else
            [script,fallback_script].map{|x|
              x.gsub(/\:THEME/, theme)
            }.join("\n")
          end
        end
      end
  
  
      # Default options hash for the middleware.
      DEFAULT_APP_OPTIONS = {
        :http_path => "/js/jquery-ui/#{JQueryUI::JQUERY_UI_VERSION}/themes/"
      }


      # @private
      # Used internally to find the vendored files.
      Path_to_vendor = ::File.join(
        "../../../",
        "vendor/assets/javascripts/jquery-ui"
      )


      def self.sort_out_options( options={} )
        theme = options[:theme]
        themes = options[:themes]

        if theme
          t = Array(theme).map(&:to_s).uniq # put in an array
          themes = themes ?
            (t + themes).uniq :
            t
        else
          themes = ["smoothness"] if themes.nil? || themes.empty?
          theme = themes.first
        end
        
        unless (ts = themes - STANDARD_THEMES).empty?
          fail ArgumentError, %Q!The themes given (#{ts.join(" ")}) are unknown for this version of the rack-jquery_ui-themes library. Choose from #{STANDARD_THEMES}!
        end

        [theme,themes]
      end


      # @param [#call] app
      # @param [Hash] options
      # @option options [#to_s] theme The theme to use. The default is "smoothness".
      # @option options [Array<#to_s>] themes List of themes to allow. If the option for theme is set then this will be a backup set. If the option for theme is not set then the first theme listed will become the main theme.
      # @option options [String] :http_path If you wish the jQuery CSS fallback route to be "/js/jquery-ui/1.10.1/smoothness/jquery-ui.min.css" (or whichever version this is at) then do nothing, that's the default. If you want the path to be "/assets/javascripts/jquery-ui/1.10.1/smoothness…" then pass in `:http_path => "/assets/javascripts/#{Rack::JQueryUI::JQUERY_UI_VERSION}".
      # @note ***Don't leave out the version number when using the :http_path option!***. The scripts provided by jQuery don't contain the version in the filename like the jQuery scripts do, which means that organising them and sending the right headers back is bound to go wrong unless you put the version number somewhere in the route. You have been warned!
      # @example
      #   # The default:
      #   use Rack::JQueryUI::Themes
      #
      #   # With a default theme other than smoothness:
      #   use Rack::JQueryUI::Themes, :theme => "dot-luv"
      #
      #   # With a several themes, the main one being dot-luv:
      #   use Rack::JQueryUI::Themes, :themes => %w{dot-luv blitzer eggplant trontastic}
      #
      #   # Another way to do the same thing
      #   use Rack::JQueryUI::Themes, :theme => "dot-luv", :themes => %w{blitzer eggplant trontastic}
      def initialize( app, options={} )
        @app, @options  = app, DEFAULT_APP_OPTIONS.merge(options)
        theme, @themes = self.class.sort_out_options @options

        @http_base_path = @options[:http_path]

        # set the path to all the assets
        @paths = @themes.each_with_object({}) do |theme,paths|
          version_and_theme = ::File.join( 
            JQueryUI::JQUERY_UI_VERSION, "themes", theme
          )

          theme_url = ::File.join @http_base_path, theme
          theme_dir  = ::File.expand_path( ::File.join( Path_to_vendor, version_and_theme ), ::File.dirname(__FILE__) )

          # Store the HTTP path to the CSS as the key
          # with the file path to the CSS file as the value
          paths.store(
            ::File.join( theme_url, JQUERY_UI_THEME_FILE ),
            {
              :file => ::File.join( theme_dir, JQUERY_UI_THEME_FILE),
              :theme => theme
            }
          )

          images_dir = ::File.join theme_dir, "images"

          Dir.new(images_dir)
              .entries
              .delete_if{|f| f =~ /^\./ }
              .select{|f| 
                Rack::Mime.mime_type(
                  ::File.extname(f), "text/css" # fallback is a false
                ).start_with? "image"           # here
              }.each do |img|
                paths.store(
                  ::File.join( theme_url, "images", img ), # url
                  {
                    :file   =>  ::File.join( images_dir, img ),
                    :theme  =>  theme
                  }
                )
              end
        end
      end


      # @param [Hash] env Rack request environment hash.
      def call( env )
        dup._call env
      end
  
  
      # For thread safety
      # @param (see #call)
      def _call( env )
        env.merge! "rack.jquery_ui-themes" => @themes
        request = Rack::Request.new(env.dup)

        # path for CSS
        # TODO benchmark this condition
        # start_with? vs has_key vs regex
        if @paths.has_key? request.path_info
          response = Rack::Response.new
          if request.path_info.end_with? JQUERY_UI_THEME_FILE # CSS.
            # For caching:
            response.headers.merge! caching_headers("#{JQUERY_UI_THEME_FILE}-#{@paths[request.path_info][:theme]}-#{JQueryUI::JQUERY_UI_VERSION}", JQueryUI::JQUERY_UI_VERSION_DATE)
            # There's no need to test if the IF_MODIFIED_SINCE against the release date because the header will only be passed if the file was previously accessed by the requester, and the file is never updated. If it is updated then it is accessed by a different path.
            requested_file = open @paths[request.path_info][:file], "r"
          elsif request.path_info =~ /images/
            # serve images
            requested_file = open @paths[request.path_info][:file], "rb"
          else # bad route
            response.status = 404
            return response.finish # finish early, 404
          end

          # set status and read the requested file
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

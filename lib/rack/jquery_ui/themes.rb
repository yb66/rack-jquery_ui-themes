require "rack/jquery_ui/themes/version"

module Rack

  # jQuery CDN script tags and fallback in one neat package.
  class JQueryUI
  class Themes

    JQUERY_UI_THEME_FILE = "jquery-ui.min.css"

    # Script tags for the Media Temple CDN
    MEDIA_TEMPLE = "<link rel='stylesheet' href='http://code.jquery.com/ui/#{JQUERY_UI_VERSION}/themes/:THEME/jquery-ui.css' type='text/css' />"

    # Script tags for the Google CDN
    GOOGLE = "<link rel='stylesheet' href='//ajax.googleapis.com/ajax/libs/jqueryui/#{JQUERY_UI_VERSION}/themes/:THEME/jquery-ui.css' type='text/css' />"

    # Script tags for the Microsoft CDN
    MICROSOFT = "<link rel='stylesheet' href='//ajax.microsoft.com/ajax/jquery.ui/#{JQUERY_UI_VERSION}/themes/:THEME/jquery-ui.css' type='text/css' />"

    # This javascript checks if the jQuery-UI object has loaded. If not, that most likely means the CDN is unreachable, so it uses the local jQuery-UI theme.
    FALLBACK = <<STR
<script type="text/javascript">
$.each(document.styleSheets, function(i,sheet){
  if(sheet.href=='http://code.jquery.com/mobile/1.0b3/jquery.mobile-1.0b3.min.css') {
    var rules = sheet.rules ? sheet.rules : sheet.cssRules;
    if (rules.length == 0) {
      $('<link rel="stylesheet" type="text/css" href="/js/jquery-ui/#{JQUERY_UI_VERSION}/themes/:THEME/#{JQUERY_UI_THEME_FILE}" />').appendTo('head');
    }
 }
})
</script>
STR


    # Ten years in seconds.
    TEN_YEARS  = 60 * 60 * 24 * 365 * 10


    STANDARD_THEMES = %w{base black-tie blitzer cupertino dark-hive dot-luv eggplant excite-bike flick hot-sneaks humanity le-frog mint-choc overcast pepper-grinder redmond smoothness south-street start sunny swanky-purse trontastic ui-darkness ui-lightness vader}


    def self.theme
      @theme ||= "base"
    end


    def self.theme=( name )
      fail ArgumentError, "That theme (#{name}) is unknown for this version of the rack-jquery_ui-themes library." unless STANDARD_THEMES.include? name
      @theme = name
    end

    DEFAULT_CDN_OPTIONS = {
      organisation: :google
    }


    # @param [Hash] opts
    # @option opts [Symbol] :organisation Choose which CDN to use, either :google, :microsoft or :media_temple
    # @option opts [#to_s] :theme
    # @return [String] The HTML script tags to get the CDN.
    # @example
    #   Rack::JQueryUI::Themes.cdn organisation: :google, theme: "dot-luv"
    def self.cdn( opts={} )
      opts = DEFAULT_CDN_OPTIONS.merge opts.delete_if{|k,v| v.nil? }
      opts[:theme] ||= self.theme
      fail ArgumentError, "That theme (#{opts[:theme]}) is unknown for this version of the rack-jquery_ui-themes library." unless STANDARD_THEMES.include? opts[:theme]
      script = case opts[:organisation].to_sym
        when :media_temple then MEDIA_TEMPLE
        when :microsoft then MICROSOFT
        else GOOGLE
      end
      [script,FALLBACK].map{|x| x.sub(/\:THEME/, opts[:theme]) }.join("\n")
    end


    # Default options hash for the middleware.
    DEFAULT_APP_OPTIONS = {
      :http_path => "/js/jquery-ui/#{JQUERY_UI_VERSION}/themes/"
    }


    # @param [#call] app
    # @param [Hash] options
    # @option options [String] :http_path If you wish the jQuery fallback route to be "/js/jquery-ui/1.10.1/jquery-ui.min.js" (or whichever version this is at) then do nothing, that's the default. If you want the path to be "/assets/javascripts/jquery-ui/1.10.1/jquery-ui.min.js" then pass in `:http_path => "/assets/javascripts/#{Rack::JQueryUI::JQUERY_UI_VERSION}".
    # @note ***Don't leave out the version number!***. The scripts provided by jQuery don't contain the version in the filename like the jQuery scripts do, which means that organising them and sending the right headers back is bound to go wrong unless you put the version number somewhere in the route. You have been warned!
    # @example
    #   # The default:
    #   use Rack::JQueryUI
    #   # With a different route to the fallback:
    #   use Rack::JQueryUI, :http_path => "/assets/js/#{Rack::JQueryUI::JQUERY_UI_VERSION}"
    def initialize( app, options={} )
      @app, @options  = app, DEFAULT_APP_OPTIONS.merge(options)
      self.class.theme = options[:theme] unless options[:theme].nil?
      @http_path_to_jquery = ::File.join(
        @options[:http_path],        
        self.class.theme,
        JQUERY_UI_THEME_FILE
      )
    end


    # @param [Hash] env Rack request environment hash.
    def call( env )
      request = Rack::Request.new(env.dup)

      # TODO path for images

      # path for CSS
      if request.path_info == @http_path_to_jquery
        response = Rack::Response.new
        # for caching
        response.headers.merge! caching_headers("#{JQUERY_UI_THEME_FILE}-#{self.class.theme}-#{JQUERY_UI_VERSION}")

        # There's no need to test if the IF_MODIFIED_SINCE against the release date because the header will only be passed if the file was previously accessed by the requester, and the file is never updated. If it is updated then it is accessed by a different path.
        if request.env['HTTP_IF_MODIFIED_SINCE']
          response.status = 304
        else
          response.status = 200
          response.write ::File.read( ::File.expand_path "../../../../vendor/assets/javascripts/jquery-ui/#{JQUERY_UI_VERSION}/themes/#{self.class.theme}/#{JQUERY_UI_THEME_FILE}", __FILE__)
        end
        response.finish
      else
        @app.call(env)
      end
    end # call


    private

    def caching_headers( etag )
      {
        "Last-Modified" => JQUERY_UI_VERSION_DATE,
        "Expires"    => Rack::Utils.rfc2109(Time.now + TEN_YEARS),
        "Cache-Control" => "max-age=#{TEN_YEARS},public",
        "Etag"          => etag,
        'Content-Type' =>'application/javascript; charset=utf-8'
      }
    end

  end # Themes
  end
end

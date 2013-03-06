require "rack/jquery_ui/version"

module Rack

  # jQuery CDN script tags and fallback in one neat package.
  class JQueryUI

    JQUERY_UI_FILE_NAME = "jquery-ui.min.js"

    # Script tags for the Media Temple CDN
    MEDIA_TEMPLE = "<script src='http://code.jquery.com/ui/1.10.1/jquery-ui.js'></script>"

    # Script tags for the Google CDN
    GOOGLE = "<script src='//ajax.googleapis.com/ajax/libs/jqueryui/1.10.1/jquery-ui.min.js'></script>"

    # Script tags for the Microsoft CDN
    MICROSOFT = "<script src='//ajax.aspnetcdn.com/ajax/jquery.ui/1.10.1/jquery-ui.min.js'></script>"

    # This javascript checks if the jQuery-UI object has loaded. If not, that most likely means the CDN is unreachable, so it uses the local minified jQuery.
    FALLBACK = <<STR
<script type="text/javascript">
  !window.jQuery.ui && document.write(unescape("%3Cscript src='/js/jquery-ui/#{JQUERY_UI_VERSION}/#{JQUERY_UI_FILE_NAME}' type='text/javascript'%3E%3C/script%3E"))
</script>
STR


    # Ten years in seconds.
    TEN_YEARS  = 60 * 60 * 24 * 365 * 10


    # default options when setting up the CDN
    CDN_DEFAULTS = {css: true, js: true, fallback: true}

    # @param [Symbol] organisation Choose which CDN to use, either :google, :microsoft or :media_temple
    # @return [String] The HTML script tags to get the CDN.
    def self.cdn( opts={} )
      opts = CDN_DEFAULTS.merge opts
      organisation = opts.fetch :organisation, :google
      script = case organisation
        when :media_temple then MEDIA_TEMPLE
        when :microsoft then MICROSOFT
        else GOOGLE
      end
      "#{script}\n#{FALLBACK}"
    end


    # Default options hash for the middleware.
    DEFAULT_OPTIONS = {
      :http_path => "/js/jquery-ui/#{JQUERY_UI_VERSION}"
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
      @app, @options  = app, DEFAULT_OPTIONS.merge(options)
      @http_path_to_jquery = ::File.join @options[:http_path], JQUERY_UI_FILE_NAME
    end


    # @param [Hash] env Rack request environment hash.
    def call( env )
      request = Rack::Request.new(env.dup)
      if request.path_info == @http_path_to_jquery
        response = Rack::Response.new
        # for caching
        response.headers.merge!( {
          "Last-Modified" => JQUERY_UI_VERSION_DATE,
          "Expires"    => Rack::Utils.rfc2109(Time.now + TEN_YEARS),
          "Cache-Control" => "max-age=#{TEN_YEARS},public",
          "Etag"          => "#{JQUERY_UI_FILE_NAME}-#{JQUERY_UI_VERSION}",
          'Content-Type' =>'application/javascript; charset=utf-8'
        })

        # There's no need to test if the IF_MODIFIED_SINCE against the release date because the header will only be passed if the file was previously accessed by the requester, and the file is never updated. If it is updated then it is accessed by a different path.
        if request.env['HTTP_IF_MODIFIED_SINCE']
          response.status = 304
        else
          response.status = 200
          response.write ::File.read( ::File.expand_path "../../../vendor/assets/javascripts/jquery-ui/#{JQUERY_UI_VERSION}/#{JQUERY_UI_FILE_NAME}", __FILE__)
        end
        response.finish
      else
        @app.call(env)
      end
    end # call

  end
end

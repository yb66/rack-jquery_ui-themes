module Rack
  class JQueryUI

    # This is here in case another rack-jquery_ui library has already been loaded.
    jquery_ui_version = "1.10.1"
    if defined? JQUERY_UI_VERSION
      warn "JQUERY_UI_VERSION was already defined."
      unless JQUERY_UI_VERSION == jquery_ui_version
        warn "The JQUERY_UI_VERSION defined is #{JQUERY_UI_VERSION} but the version this library wants to use is #{jquery_ui_version}. You have been warned!"
      end
    else
      JQUERY_UI_VERSION = jquery_ui_version

      # This is the release date of the jQuery file, it makes an easy "Last-Modified" date for setting the headers around caching.
      # @todo remember to change Last-Modified with each release!
      JQUERY_UI_VERSION_DATE = "Fri, 15 Feb 2013 00:00:00 GMT"
    end

    class Themes
      VERSION = "0.1.1"
    end
  end
end

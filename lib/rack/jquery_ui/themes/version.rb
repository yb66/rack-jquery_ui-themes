module Rack
  class JQueryUI
    JQUERY_UI_VERSION = "1.10.1" unless defined? JQUERY_UI_VERSION

    # This is the release date of the jQuery file, it makes an easy "Last-Modified" date for setting the headers around caching.
    # @todo remember to change Last-Modified with each release!
    JQUERY_UI_VERSION_DATE = "Fri, 15 Feb 2013 00:00:00 GMT" unless defined? JQUERY_UI_VERSION_DATE

  class Themes
    VERSION = "0.0.1"
  end
  end
end

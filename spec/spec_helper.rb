# encoding: UTF-8

require 'rspec'
Spec_dir = File.expand_path( File.dirname __FILE__ )


# code coverage
require 'simplecov'
SimpleCov.start do
  add_filter "/vendor/"
  add_filter "/bin/"
  add_filter "/spec/"
  add_filter "/examples/"
end

require "rack/test"
ENV['RACK_ENV'] ||= 'test'
ENV["EXPECT_WITH"] ||= "racktest"


Dir[ File.join( Spec_dir, "/support/**/*.rb")].each do |f|
  require f
end
                                  

module RackJQueryUIThemesHelpers
  def subber( s, opts={} )
    script_name = opts.fetch("SCRIPT_NAME","/")
    fallback_url = ::File.join script_name, "/js/jquery-ui/#{Rack::JQueryUI::JQUERY_UI_VERSION}/themes/:THEME/#{Rack::JQueryUI::Themes::JQUERY_UI_THEME_FILE}"
    theme = opts.fetch :theme, "smoothness"
    cdn = opts[:cdn]
    s = s.gsub(/\:CDNURL/, cdn) if cdn
    s.sub! /\:FALLBACK_URL/, fallback_url
    s.gsub(/\:THEME/, theme)
  end
end

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.include RackJQueryUIThemesHelpers
end

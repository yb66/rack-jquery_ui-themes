require "rubygems"
require "bundler"
Bundler.setup(:examples)

require 'rack/jquery_ui/themes'

require File.expand_path( '../config.rb', __FILE__)

map "/" do
  run App
end

# this is me cheating a bit
Rack::JQueryUI::Themes::STANDARD_THEMES.each do |theme|
  map "/themes/#{theme}" do
    use Rack::JQueryUI::Themes, :theme => theme
    run ThemeApp
  end
end
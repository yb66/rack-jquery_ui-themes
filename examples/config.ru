require "rubygems"
require "bundler"
Bundler.setup(:examples)

require 'rack/jquery_ui/themes'

require File.expand_path( '../config.rb', __FILE__)

map "/" do
  run App
end
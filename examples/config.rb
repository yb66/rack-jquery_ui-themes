require 'sinatra/base'
require 'haml'
require 'rack/jquery'
require 'rack/jquery_ui'
require 'rack/jquery_ui/themes'

class App < Sinatra::Base

  enable :inline_templates
  use Rack::JQuery
  use Rack::JQueryUI
  use Rack::JQueryUI::Themes, :theme => "vader", :themes => Rack::JQueryUI::Themes::STANDARD_THEMES

  get "/" do
    haml :index, :layout => :unspecified
  end

  get "/google-cdn" do
    haml :index, :layout => :google
  end

  get "/media-temple-cdn" do
    haml :index, :layout => :mediatemple
  end

  get "/microsoft-cdn" do
    haml :index, :layout => :microsoft
  end

  get "/themes/?" do
    haml :themes_list, :layout => :unspecified
  end

  get "/fallback/?" do
    haml :themes_list, :layout => :unspecified
  end

  
  get "/themes/" do
    haml :theme, :layout => :layout_theme
  end
  
  get "/themes/:theme" do |theme|
    @theme = theme
    haml :theme, :layout => :layout_theme
  end

  
  get "/fallback/" do
    haml :theme, :layout => :layout_fallback
  end

  get "/fallback/:theme" do |theme|
    @theme = theme
    haml :theme, :layout => :layout_fallback
  end
end
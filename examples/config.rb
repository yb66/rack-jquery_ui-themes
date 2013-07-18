require 'sinatra/base'
require 'haml'
require 'rack/jquery'
require 'rack/jquery_ui'
require 'rack/jquery_ui/themes'

class App < Sinatra::Base

  enable :inline_templates
  use Rack::JQuery
  use Rack::JQueryUI
  use Rack::JQueryUI::Themes, :theme => "vader"

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
end

class ThemeApp < Sinatra::Base
  get "/" do
    haml :theme, :layout => :layout_theme
  end
end
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

  get "/vader" do
    haml :vader, :layout => :layout_vader
  end
end

__END__

@@google
%html
  %head
    = Rack::JQuery.cdn( :google )
    = Rack::JQueryUI.cdn( :google )
    = Rack::JQueryUI::Themes.cdn(:google)
  = yield

@@microsoft
%html
  %head
    = Rack::JQuery.cdn( :microsoft )
    = Rack::JQueryUI.cdn( :microsoft )
    = Rack::JQueryUI::Themes.cdn(:microsoft)
  = yield

@@mediatemple
%html
  %head
    = Rack::JQuery.cdn( :media_temple )
    = Rack::JQueryUI.cdn( :media_temple )
    = Rack::JQueryUI::Themes.cdn(:media_temple)
  = yield

@@unspecified
%html
  %head
    = Rack::JQuery.cdn()
    = Rack::JQueryUI.cdn()
    = Rack::JQueryUI::Themes.cdn()
  = yield

@@index

%p
  %a{ href: "/google-cdn" }
    google-cdn

%p
  %a{ href: "/microsoft-cdn" }
    microsoft-cdn

%p
  %a{ href: "/media-temple-cdn" }
    media-temple-cdn

%p
  %a{ href: "/" }
    unspecified

%p
  %a{ href: "/vader" }
    vader
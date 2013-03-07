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
    "RUNNING"
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

  get "/unspecified-cdn" do
    haml :index, :layout => :unspecified
  end

  get "/example" do
    haml :example, :layout => :layout_example
  end
end

__END__

@@google
%html
  %head
    = Rack::JQuery.cdn( :google )
    = Rack::JQueryUI.cdn( :organisation => :google )
    = Rack::JQueryUI::Themes.cdn(:organisation => :google)
  = yield

@@microsoft
%html
  %head
    = Rack::JQuery.cdn( :microsoft )
    = Rack::JQueryUI.cdn( :organisation => :microsoft )
    = Rack::JQueryUI::Themes.cdn(:organisation => :microsoft)
  = yield

@@mediatemple
%html
  %head
    = Rack::JQuery.cdn( :media_temple )
    = Rack::JQueryUI.cdn( :organisation => :media_temple )
    = Rack::JQueryUI::Themes.cdn(:organisation => :media_temple)
  = yield

@@unspecified
%html
  %head
    = Rack::JQuery.cdn()
    = Rack::JQueryUI.cdn()
    = Rack::JQueryUI::Themes.cdn()
  = yield

@@index

%p.aclass
  "NOTHING TO SEE HERE… "
%p.aclass
  "MOVE ALONG… "
%p.aclass
  "MOVE ALONG… "
#placeholder
:javascript
  all_text = $('.aclass').text();
  $('#placeholder').text(all_text + " (draggable!)").mouseover(function() {
    $(this).css({ 'color': 'red', 'font-size': '150%' });    
  }).mouseout(function() {
    $(this).css({ 'color': 'blue', 'font-size': '100%' });
  }).draggable();
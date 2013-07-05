# encoding: UTF-8

require 'spec_helper'
require_relative "../lib/rack/jquery_ui/themes.rb"

def subber( s, replacement={} )
  replacement[:theme] ||= "base"
  s.sub(/:THEME/,replacement[:theme])
end

shared_examples "Given an organisation and a theme" do
  let(:link) { "<link rel='stylesheet' href='#{cdn}' type='text/css' />" }
  it { should == "#{subber link, theme}\n#{subber Rack::JQueryUI::Themes::FALLBACK, theme}" }
end

shared_context "Calling the CDN" do
  subject { Rack::JQueryUI::Themes.cdn organisation, theme }
end


describe "The class methods" do
  let(:opts) { theme.delete_if{|k,v| v.nil?} }  
  let(:theme) { {:theme => nil} }
  subject { Rack::JQueryUI::Themes.cdn organisation, opts }
  context "Given an organisation" do
    context "of nil (the default)" do
      let(:organisation) { nil }
      let(:theme) { {:theme => nil} }
      let(:cdn) { Rack::JQueryUI::Themes::CDN::GOOGLE }
      include_examples "Given an organisation and a theme"
      context "Given a theme" do
        let(:theme) { { :theme => Rack::JQueryUI::Themes::STANDARD_THEMES.sample } }
        include_context "Calling the CDN"
        include_examples "Given an organisation and a theme"
      end
    end
    context "of :google" do
      let(:organisation) { :google }
      let(:cdn) { Rack::JQueryUI::Themes::CDN::GOOGLE }
      include_examples "Given an organisation and a theme"
    end
    context "of :microsoft" do
      let(:organisation) { :microsoft }
      let(:cdn) { Rack::JQueryUI::Themes::CDN::MICROSOFT }
      include_examples "Given an organisation and a theme"
    end
    context "of :media_temple" do
      let(:organisation) { :media_temple }
      let(:cdn) { Rack::JQueryUI::Themes::CDN::MEDIA_TEMPLE }
      include_examples "Given an organisation and a theme"
    end
  end
end

describe "Inserting the CDN" do
  let(:theme) { {:theme => "vader"} }
  let(:expected) { subber cdn, theme  }
  include_context "All routes"
  context "Check the examples run at all" do
    before do
      get "/"
    end
    it_should_behave_like "Any route"
  end
  context "Google CDN" do
    before do
      get "/google-cdn"
    end
    it_should_behave_like "Any route"
    subject { last_response.body }
    let(:cdn) { Rack::JQueryUI::Themes::CDN::GOOGLE }
    it { should include expected }
  end
  context "Microsoft CDN" do
    before do
      get "/microsoft-cdn"
    end
    it_should_behave_like "Any route"
    subject { last_response.body }
    let(:cdn) { Rack::JQueryUI::Themes::CDN::MICROSOFT }
    it { should include expected }
  end
  context "Media_temple CDN" do
    before do
      get "/media-temple-cdn"
    end
    it_should_behave_like "Any route"
    subject { last_response.body }
    let(:cdn) { Rack::JQueryUI::Themes::CDN::MEDIA_TEMPLE }
    it { should include expected }
  end
  context "Unspecified CDN" do
    before do
      get "/"
    end
    it_should_behave_like "Any route"
    subject { last_response.body }
    let(:cdn) { Rack::JQueryUI::Themes::CDN::GOOGLE }
    it { should include expected }
  end
end


require 'timecop'
require 'time'

describe "Serving the fallback jquery" do
  include_context "All routes"
  let(:theme) { {:theme => "vader"} }
  context "Single request" do
    context "for route that doesn't exist" do
      let(:url) { "/js/jquery-ui/#{Rack::JQueryUI::JQUERY_UI_VERSION}/themes/blah/#{Rack::JQueryUI::Themes::JQUERY_UI_THEME_FILE}"}
      before do
        get url
      end
      subject { last_response.status }
      it { should == 404 }
    end
    context "for CSS" do
      let(:url) { subber "/js/jquery-ui/#{Rack::JQueryUI::JQUERY_UI_VERSION}/themes/:THEME/#{Rack::JQueryUI::Themes::JQUERY_UI_THEME_FILE}", theme }
      before do
        get url
      end
      it_should_behave_like "Any route"
      subject { last_response.body }
      it { should start_with "/*! jQuery UI - v#{Rack::JQueryUI::JQUERY_UI_VERSION}" }
    end
    context "for an image" do
      ex_path = File.expand_path "../../vendor/assets/javascripts/jquery-ui/#{Rack::JQueryUI::JQUERY_UI_VERSION}/themes/base/images", __FILE__
      img = Dir.new( ex_path ).entries.find{|f| f =~ /\.png$/ }
      let(:url) {  "/js/jquery-ui/#{Rack::JQueryUI::JQUERY_UI_VERSION}/themes/base/images/#{img}" }
      before do
        get url
      end
      it_should_behave_like "Any route"
      subject { last_response.body }
      it { should_not be_nil }
    end
  end
  context "Re requests" do
    before do
      at_start = Time.parse(Rack::JQueryUI::JQUERY_UI_VERSION_DATE) + 60 * 60 * 24 * 180
      Timecop.freeze at_start
      get url
      Timecop.travel Time.now + 86400 # add a day
      get url, {}, {"HTTP_IF_MODIFIED_SINCE" => Rack::Utils.rfc2109(at_start) }
    end
    subject { last_response }
    context "for CSS" do
      let(:url) { subber "/js/jquery-ui/#{Rack::JQueryUI::JQUERY_UI_VERSION}/themes/:THEME/#{Rack::JQueryUI::Themes::JQUERY_UI_THEME_FILE}", theme }
      its(:status) { should == 304 }
    end
    context "for an image" do
      ex_path = File.expand_path "../../vendor/assets/javascripts/jquery-ui/#{Rack::JQueryUI::JQUERY_UI_VERSION}/themes/base/images", __FILE__
      img = Dir.new( ex_path ).entries.find{|f| f =~ /\.png$/ }
      let(:url) {  "/js/jquery-ui/#{Rack::JQueryUI::JQUERY_UI_VERSION}/themes/base/images/#{img}" }
      its(:status) { should == 304 }
    end
  end
end
# encoding: UTF-8

require 'spec_helper'
require_relative "../lib/rack/jquery_ui/themes.rb"

shared_examples "Given an organisation and a theme" do
  let(:link) { "<link rel='stylesheet' href='#{cdn}' type='text/css' />" }
  let(:expected) { "#{subber link, opts}\n#{subber Rack::JQueryUI::Themes::FALLBACK, opts}" }
  it { should == expected }
end

shared_context "Calling the CDN" do
  subject { Rack::JQueryUI::Themes.cdn env, opts }
end


describe "The class methods" do
  context "Given an organisation" do
    subject { Rack::JQueryUI::Themes.cdn env, opts }
    let(:theme) { "smoothness" }
    let(:opts) {
      {:theme => theme, :cdn => cdn, :organisation => organisation}
    }
    let(:env) {
      {}
    }
    context "of nil (the default)" do
      let(:organisation) { nil }
      let(:cdn) { Rack::JQueryUI::Themes::CDN::MEDIA_TEMPLE }
      include_examples "Given an organisation and a theme"
      context "and given a theme" do
        context "That is valid" do
          let(:theme) { Rack::JQueryUI::Themes::STANDARD_THEMES.sample}
          include_context "Calling the CDN"
          include_examples "Given an organisation and a theme"
        end
        context "That is not valid" do
          context "Because it's not in the standard themes" do
            let(:theme) { "breakfastsupercharger" }
            it "should fail" do
              expect{ Rack::JQueryUI::Themes.cdn organisation, opts }.to raise_error
            end
          end
          context "Because different themes were chosen at set up" do
            let(:app) {
              Sinatra.new do
                use Rack::JQuery
                use Rack::JQueryUI
                use Rack::JQueryUI::Themes, :themes => %w{pepper-grinder swanky-purse trontastic}
                get('/') { Rack::JQueryUI::Themes.cdn organisation, opts }
              end
            }
            let(:theme) { "overcast" }
            it "should fail" do
              expect{ get "/" }.to raise_error
            end
          end
        end
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

# Bit of internal checking, for sanity.
describe "Path_to_vendor" do
  subject { Rack::JQueryUI::Themes::Path_to_vendor }
  it { should == "../../../vendor/assets/javascripts/jquery-ui" }
end

describe "Inserting the CDN" do
  include_context "All routes"
  let(:opts) {
    {:theme => theme, :url => cdn}.delete_if{|k,v| v.nil?}
  }
  let(:expected) { subber cdn, opts  }
  context "Check the examples run at all" do
    before do
      get "/"
    end
    it_should_behave_like "Any route"
  end
  context "Given a theme" do
    context "That is valid" do
      let(:theme) { "vader" }
      context "Google CDN" do
        let(:cdn) { Rack::JQueryUI::Themes::CDN::GOOGLE }
        before do
          get "/google-cdn"
        end
        it_should_behave_like "Any route"
        subject { last_response.body }
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
        let(:cdn) { Rack::JQueryUI::Themes::CDN::MEDIA_TEMPLE }
        it { should include expected }
      end
    end
    context "that is not valid" do
      let(:app) {
        Sinatra.new do
          use Rack::JQuery
          use Rack::JQueryUI
          use Rack::JQueryUI::Themes, :theme => "breakfastsupercharger"
          get('/') { "Shouldn't reach this" }
        end
      }
      it "should fail" do
        expect{ get "/" }.to raise_error
      end
    end
  end
end


require 'timecop'
require 'time'

describe "Serving the fallback jquery" do
  include_context "All routes"
  let(:theme) { {:theme => "vader"} }
  let(:cdn) { Rack::JQueryUI::Themes::CDN::MEDIA_TEMPLE }
  let(:opts) { theme.merge( :cdn => cdn ) }
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
      let(:url) { subber "/js/jquery-ui/#{Rack::JQueryUI::JQUERY_UI_VERSION}/themes/:THEME/#{Rack::JQueryUI::Themes::JQUERY_UI_THEME_FILE}", opts }
      before do
        get url
      end
      it_should_behave_like "Any route"
      subject { last_response.body }
      it { should start_with "/*! jQuery UI - v#{Rack::JQueryUI::JQUERY_UI_VERSION}" }
    end
    context "for an image" do
      ex_path = File.expand_path "../../vendor/assets/javascripts/jquery-ui/#{Rack::JQueryUI::JQUERY_UI_VERSION}/themes/vader/images", __FILE__
      img = Dir.new( ex_path ).entries.find{|f| f =~ /\.png$/ }
      let(:url) {  "/js/jquery-ui/#{Rack::JQueryUI::JQUERY_UI_VERSION}/themes/vader/images/#{img}" }
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
      let(:url) { subber "/js/jquery-ui/#{Rack::JQueryUI::JQUERY_UI_VERSION}/themes/:THEME/#{Rack::JQueryUI::Themes::JQUERY_UI_THEME_FILE}", opts }
      its(:status) { should == 304 }
    end
    context "for an image" do
      ex_path = File.expand_path "../../vendor/assets/javascripts/jquery-ui/#{Rack::JQueryUI::JQUERY_UI_VERSION}/themes/vader/images", __FILE__
      img = Dir.new( ex_path ).entries.find{|f| f =~ /\.png$/ }
      let(:url) {  "/js/jquery-ui/#{Rack::JQueryUI::JQUERY_UI_VERSION}/themes/vader/images/#{img}" }
      its(:status) { should == 304 }
    end
  end
end
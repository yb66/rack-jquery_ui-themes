# encoding: UTF-8

require 'spec_helper'
require_relative "../lib/rack/jquery_ui.rb"

describe "The class methods" do
  subject { Rack::JQueryUI.cdn :organisation => organisation }
  context "Given an argument" do
    context "of nil (the default)" do
      let(:organisation) { nil }
      it { should == "#{Rack::JQueryUI::GOOGLE}\n#{Rack::JQueryUI::FALLBACK}" }
    end
    context "of :google" do
      let(:organisation) { :google }
      it { should == "#{Rack::JQueryUI::GOOGLE}\n#{Rack::JQueryUI::FALLBACK}" }
    end
    context "of :microsoft" do
      let(:organisation) { :microsoft }
      it { should == "#{Rack::JQueryUI::MICROSOFT}\n#{Rack::JQueryUI::FALLBACK}" }
    end
    context "of :media_temple" do
      let(:organisation) { :media_temple }
      it { should == "#{Rack::JQueryUI::MEDIA_TEMPLE}\n#{Rack::JQueryUI::FALLBACK}" }
    end
  end
end

describe "Inserting the CDN" do
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
    let(:expected) { Rack::JQueryUI::GOOGLE }
    it { should include expected }
  end
  context "Microsoft CDN" do
    before do
      get "/microsoft-cdn"
    end
    it_should_behave_like "Any route"
    subject { last_response.body }
    let(:expected) { Rack::JQueryUI::MICROSOFT }
    it { should include expected }
  end
  context "Media_temple CDN" do
    before do
      get "/media-temple-cdn"
    end
    it_should_behave_like "Any route"
    subject { last_response.body }
    let(:expected) { Rack::JQueryUI::MEDIA_TEMPLE }
    it { should include expected }
  end
  context "Unspecified CDN" do
    before do
      get "/unspecified-cdn"
    end
    it_should_behave_like "Any route"
    subject { last_response.body }
    let(:expected) { Rack::JQueryUI::GOOGLE }
    it { should include expected }
  end
end


require 'timecop'
require 'time'

describe "Serving the fallback jquery" do
  include_context "All routes"
  before do
    get "/js/jquery-ui/#{Rack::JQueryUI::JQUERY_UI_VERSION}/#{Rack::JQueryUI::JQUERY_UI_FILE_NAME}"
  end
  it_should_behave_like "Any route"
  subject { last_response.body }
  it { should start_with "/*! jQuery UI - v#{Rack::JQueryUI::JQUERY_UI_VERSION}" }

  context "Re requests" do
    before do
      at_start = Time.parse(Rack::JQueryUI::JQUERY_UI_VERSION_DATE) + 60 * 60 * 24 * 180
      Timecop.freeze at_start
      get "/js/jquery-ui/#{Rack::JQueryUI::JQUERY_UI_VERSION}/#{Rack::JQueryUI::JQUERY_UI_FILE_NAME}"
      Timecop.travel Time.now + 86400 # add a day
      get "/js/jquery-ui/#{Rack::JQueryUI::JQUERY_UI_VERSION}/#{Rack::JQueryUI::JQUERY_UI_FILE_NAME}", {}, {"HTTP_IF_MODIFIED_SINCE" => Rack::Utils.rfc2109(at_start) }
    end
    subject { last_response }
    its(:status) { should == 304 }
    
  end
end
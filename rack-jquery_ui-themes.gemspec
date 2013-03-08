# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rack/jquery_ui/themes/version'

Gem::Specification.new do |spec|
  spec.name          = "rack-jquery_ui-themes"
  spec.version       = Rack::JQueryUI::Themes::VERSION
  spec.authors       = ["Iain Barnett"]
  spec.email         = ["iainspeed@gmail.com"]
  spec.description   = %q{jQuery-UI themes CDN script tags and fallback in one neat package. Current version is for jQuery-UI v#{Rack::JQueryUI::Themes::JQUERY_UI_VERSION}}
  spec.summary       = %q{The description says it all.}
  spec.homepage      = "https://github.com/yb66/rack-jquery_ui-themes"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.2"
  spec.add_development_dependency "rake"
  spec.add_dependency("rack")
  spec.add_dependency("rack-jquery-helpers")
end

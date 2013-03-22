# Rack::JQueryUI::Themes #

[jQuery-UI](http://jqueryui.com/) ***themes*** CDN script tags and fallback in one neat package.

### Build status ###

Master branch:
[![Build Status](https://travis-ci.org/yb66/rack-jquery_ui-themes.png?branch=master)](https://travis-ci.org/yb66/rack-jquery_ui-themes)

### Why? ###

I get tired of copy and pasting and downloading and moving… jQuery files and script tags etc. This does it for me (along with https://github.com/yb66/rack-jquery), and keeps version management nice 'n' easy.

### See also ###

[Rack::JQuery](https://github.com/yb66/rack-jquery)  
[Rack::JQueryUI](https://github.com/yb66/rack-jquery_ui)

They're not dependencies, but if you're going to use this then I bet you'll be interested in using them.

### What's with the plural ###

Rack::JQueryUI::Theme doesn't sound right to me, as it's accessing the _Themes_ service/files. I doubt you'll ever instantiate a instance of the class yourself, and the computer doesn't mind, so let it go.

### Usage ###

Have a look in the examples directory, but here's a snippet.

* Install it (see below)
* `require 'rack/jquery_ui/themes'`.
* Put this in your middleware stack: `use Rack::JQuery::Themes, :theme => "vader"`
* Put this in the head of your layout (the example is Haml but you can use whatever you like)

    <pre><code>
    %head
      = Rack::JQueryUI::Themes.cdn :microsoft
    </code></pre>

Now you have the script tags to Google's CDN in the head (you can also use Media Temple or Microsoft, see the docs).

It also adds in a bit of javascript that will load in a locally kept version of jQuery, just incase the CDN is unreachable. The script will use the "/js/jquery-ui/1.10.1/themes/:THEME/jquery-ui.min.css" path (or, instead of 1.10.1, whatever is in {Rack::JQueryUI::JQUERY_UI_VERSION}), where `:THEME` is the name of the theme you specified, the default being `base`.

That was easy.

### Note ###

You have to have loaded jQuery _before_ using the CDN helper, as Rack::jQueryUI::Themes relies on it. I've already mentioned [Rack::JQuery](https://github.com/yb66/rack-jquery) which you can use to do this, or load the script however you like. Just remember that it needs to be there.

### Version numbers ###

This library uses [semver](http://semver.org/) to version the **library**. That means the library version is ***not*** an indicator of quality but a way to manage changes. The version of jQuery-UI can be found in the lib/rack/jquery_ui/themes/version.rb file, or via the {Rack::JQueryUI::JQUERY_UI_VERSION} constant.

### Installation ###

Add this line to your application's Gemfile:

    gem 'rack-jquery_ui-themes'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rack-jquery_ui-themes

### Contributing ###

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

### Licence ###

See the LICENCE.txt file.
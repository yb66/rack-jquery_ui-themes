# CH CH CH CHANGES #

## Tuesday the 6th of August 2013, v3.0.0 ##

* Removed class methods for theme and themes, they just don't work with the Rack architecture, at least not the way I'm using them.
* Found a way to check if the external CDN has loaded, by adding a meta tag and then one of the jQuery UI classes to it, and seeing if it changes.
* Added some extra keys the internal paths hash to help ascertain which theme is being called.
* Added a fallback option to the cdn method, mainly to help with testing but also because it might be wanted.

----


## Friday the 19th of July 2013, v2.1.1 ##

* Removed rogue console logging statement in the fallback javascript.

----


## Thursday the 18th of July 2013, v2.1.0 ##

* Bumped version of jQuery UI back up to 1.10.3.

----


## Thursday the 18th of July 2013, v2.0.0 ##

* The fallback wasn't working properly, fixed.
* Got one of the jQuery team to clarify which parts of the themes download was needed, so updated that.
* Added new option for selecting several themes.
* Fixed some bad architectural choices with the code.
* Downgraded to version 1.10.1 of jQuery UI to get this fixed, and the next release will bump it back up to 1.10.3.
* Made Media Temple the default CDN, because Google and Microsoft have sided with Satan over all this PRISM/TEMPURA nonsense, and I don't feel like making it easier for them to track people around the web.
* This is all breaking!!! so the major version has been bumped.

----


## v1.0.0 ##

* Bumped to 1.1.0 for semver.
* Updated to version 1.10.3 of jQuery UI.
* 100% documentation coverage.
* 100% code coverage.

----


## v0.1.1 ##

Wednesday the 24th of April 2013

* Fixed clobbering of extra call method.

____


## v0.1.0 ##

Friday the 22nd of March 2013

* Made call thread safe by duplicating `call` method.

----

## v0.0.3 ##

Friday the 8th of March 2013

* Updated docs again.

----

## v0.0.2 ##

Friday the 8th of March 2013

* Updated docs.

----

## v0.0.1 ##

Friday the 8th of March 2013

* First release. Handles CDN for jQuery-UI themes, and provides a fallback to local CSS and image files.

----

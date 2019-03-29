Vibes Api Gem
====================
Ruby gem for the Vibes Api, providing utility classes for accessing various Vibes API endpoints. 
For more information: https://developer.vibes.com/display/APIs/Platform+Docs


Using the gem
--------------------

### Using via Gem Respository

To use the gem via github, add the following line to your Gemfile

```ruby
gem 'vibes_api', git: 'https://github.com/vibes/vibes_api_ruby'
```

Then run:

```
bundle install
```


### Configuration

Most of the calls within the Vibes Api code rely on certain Environment Variables to be set.

These include (but are not limited to):

Public API:

* VIBES_PUBLIC_API_URL=https://public-api.vibescm.com

* VIBES_PUBLIC_API_USERNAME=xxx

* VIBES_PUBLIC_API_PASSWORD=xxx

Message API (Vibes Connect):

* VIBES_MESSAGE_API_URL=https://messageapi.vibesapps.com

* VIBES_MESSAGE_API_USERNAME=xxx

* VIBES_MESSAGE_API_PASSWORD=xxx


Interactive Console
--------------------

It can be helpful to test/use the Vibes Api gem on it's own within a REPL.

To do so, you can run the following rake command:

```
rake console
```

This will open up an IRB session with the current Vibes Api gem and ENV vars in .env.


Generating Documentation
--------------------

The project utilizes the [YARD](http://yardoc.org/) documentation tool and conventions.

To generate the documentation for the project run:

```
yard
```

To view the documentation after it is generated, run:

```
open doc/index.html
```

All generated documentation should be checked in to the project's git repository.


Testing
--------------------
To run the test-suite for the gem, you can invoke [rspec](http://rspec.info/) like so:

```
rspec
```

Note that a code-coverage report is automatically generated with each run and saved to `coverage\index.html`


Building the gem
--------------------
To build the Ruby gem you can either use the `gem` utility like so:

```
gem build vibes_api.gemspec
```

Or you can use the custom Rake task that is included in the project's Rakefile:

```
rake gem:build
```

require File.expand_path("../lib/version", __FILE__)

Gem::Specification.new do |s|
  s.name        = 'vibes_api'
  s.version     = VibesApi::VERSION

  s.summary     = 'Ruby library to interface with various Vibes APIs'
  s.description = 'Generally used by the Professional Services team, this library is available to interact with the Vibes Platform and other APIs'

  s.authors     = ['Vibes Professional Services']
  s.email       = 'msg-tech@vibes.com'
  s.homepage    = 'http://msg-vibes.com'
  s.license     = 'MIT'

  s.files       = `git ls-files lib`.split("\n")

  s.add_dependency 'faraday',     '~> 0.10'
  s.add_dependency 'json',        '~> 2.0'
  s.add_dependency 'nokogiri',    '~> 1.7'
  s.add_dependency 'xml-simple',  '~> 1.1'
  s.add_dependency 'sax-machine', '~> 1.3'
  s.add_dependency 'jwt',         '~> 2.1'
end

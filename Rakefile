require 'colorize'
require 'rspec/core/rake_task'
require 'require_all'

RSpec::Core::RakeTask.new(:spec)

desc "Run specs"
task :default => :spec

desc "Open an irb session preloaded with this library"
task :console do
  require 'pry'
  require 'pp'
  require 'dotenv'
  require './lib/vibes_api'
  Dotenv.load
  ARGV.clear
  pry
end

task :lookup, [:company_key,:filename] do |t, args|
  require 'dotenv'
  require './lib/vibes_api'
  Dotenv.load
  filename = args[:filename]
  File.open(filename) do |file|
    file.each do |mdn|
      persons = MobileDb.find_person(args[:company_key], mdn)
      sywid = ''
      if persons.any?
        person = persons[0]
        sywid = person["external_person_id"]
      end
      puts "#{mdn.chomp},#{sywid}"
    end
  end
end

namespace :gem do

  desc "Build gem from .gemspec"
  task :build do
    puts "\nBuilding Vibes Api gem\n".cyan
    ret = `gem build vibes_api.gemspec`
    puts "#{ret}\n"
  end

end

namespace :update do
  desc "Update Carrier codes from Vibes Wiki page"
  task :carrier_codes do
    require 'yaml'
    require 'nokogiri'
    require 'open-uri'

    carrier_codes = {}

    Nokogiri::HTML(open('https://developer.vibes.com/display/CONNECTV3/Appendix+-+Carrier+Codes')).xpath('//tbody/tr').each_with_index do |row, i|
      next if i == 0 # Xpath pulls in table header (thead) for some reason

      code = row.css("td")[0].text.to_i
      carrier_name = row.css("td")[1].text
      carrier_codes[code] = carrier_name
    end

    IO.write(File.expand_path("../lib/vibes/yaml/carrier_codes.yml", __FILE__), carrier_codes.to_yaml, mode: "w+")
    puts "#{carrier_codes.count} Carrier codes written"
  end
end

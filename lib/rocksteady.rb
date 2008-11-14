Dir[File.dirname(__FILE__) << "/rocksteady/**/*.rb"].each do |file|
  require file
end

include Rocksteady::Helpers

puts "You are using a Rawesome Rocksteady."
require 'rubygems'
require 'ruport'

# FIXME: This is a total hackjob.
# TODO: Support other output types
at_exit do
  corpus.session.run! do |scenarios|
    table = Ruport::Data::Table.new :column_names => ['Scenario', corpus.session.title] do |t|
      scenarios.sort_by { |s| s.title }.each do |scenario|
        t << [scenario.title, scenario.result.is_a?(Exception) ? "FAIL" : 'PASS'] 
      end
    end
    puts table
    puts "Skipped scenarios: "
    corpus.skipped_scenarios.each { |name| puts "* #{name}" }
  end
end
require 'rubygems'
require 'echoe'

require File.dirname(__FILE__) << "/lib/rocksteady/version"

Echoe.new 'rocksteady' do |p|
  p.version = Rocksteady::Version::STRING
  p.author = "Bruce Williams"
  p.email  = 'bruce@codefluency.com'
  p.project = 'codefluency'
  p.summary = "Run arbitrary scenarios across disparate sets of git repo revisions"
  p.url = "http://github.com/bruce/rocksteady"
  p.dependencies = %w(mojombo-grit)
  p.include_rakefile = true
end


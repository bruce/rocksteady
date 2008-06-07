require 'test/unit'
require 'rubygems'
require 'Shoulda'

$:.unshift(File.dirname(__FILE__) << "/../lib")
require 'rocksteady/core'
require 'rocksteady/helpers'

class HelperClass
  include RockSteady::Helpers
  attr_reader :rocksteady
  def initialize
    @rocksteady = RockSteady.new
  end
end

class RockSteadyTest < Test::Unit::TestCase
  
  context "Core" do
    
    tmp_dir = File.dirname(__FILE__) << "/tmp"

    repo_dirs = (1..10).to_a.map do |n|
      "#{tmp_dir}/repo#{n}"
    end
    
    setup do
      @r = HelperClass.new
      repo_dirs.each do |dir|
        FileUtils.mkdir_p dir
        Dir.chdir(dir) do
          system "git init > /dev/null 2>&1"
          File.open('stub', 'w') { |f| f.puts 'nothing' }
          system 'git add . > /dev/null 2>&1'
          system 'git commit -m "stub" > /dev/null 2>&1'
        end
      end
    end

    teardown do
      FileUtils.rm_rf tmp_dir
    end
    
    populate = lambda { @r.rocksteady.add_repos(*Dir["#{tmp_dir}/*"]) }
    
    should "start without repos" do
      assert @r.rocksteady.repos.empty?    
    end

    should "start without refs" do
      assert @r.rocksteady.refs.empty?    
    end
    
    should "add repos by paths" do
      instance_eval(&populate)
      assert @r.rocksteady.repos.size == repo_dirs.size
      assert @r.rocksteady.repos.keys.all? { |r| r =~ /^repo\d+$/ }
      assert @r.rocksteady.repos.values.all? { |r| r.is_a?(Grit::Repo) }
      assert @r.rocksteady.refs.empty?
    end
    
    should "default refs for existing repos without explicit ref" do
      instance_eval(&populate)
      assert @r.rocksteady.refs.empty?
      @r.rocksteady.refs['repo1'] = explicit = 'explicit-ref-for-this-repo'
      @r.rocksteady.default_refs!
      masters, explicits = @r.rocksteady.refs.partition { |k, v| v == 'master' }
      assert_equal 9, masters.size
      assert_equal 1, explicits.size
    end
    
    should "allow verification of refs" do
      instance_eval(&populate)
      assert @r.rocksteady.refs.empty?
      @r.rocksteady.default_refs!    
      assert_nothing_raised do
        @r.rocksteady.verify_refs!
      end
      @r.rocksteady.refs.clear    
      @r.rocksteady.refs['repo1'] = 'this-does-not-exist'
      @r.rocksteady.default_refs!
      assert_raises ArgumentError do
        @r.rocksteady.verify_refs!
      end
    end
    
  end
    
end
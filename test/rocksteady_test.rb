require 'test/unit'
require 'rubygems'
require 'Shoulda'

$:.unshift(File.dirname(__FILE__) << "/../lib")
require 'rocksteady/corpus'
require 'rocksteady/helpers'

class RSTarget
  include Rocksteady::Helpers
end

class RocksteadyTest < Test::Unit::TestCase
  
  context "Rocksteady" do
    
    tmp_dir = File.dirname(__FILE__) << "/tmp"

    repo_dirs = (1..3).to_a.map do |n|
      "#{tmp_dir}/repo#{n}"
    end
    
    setup do
      @r = RSTarget.new
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
    
    populate = lambda { @r.corpus.add_repos(*Dir["#{tmp_dir}/*"]) }
    
    context "Helpers" do
      should "have corpus accessor added as a helper" do
        assert @r.respond_to?(:corpus)
      end
    end
    
    context "Core" do
    
      should "start without repos" do
        assert @r.corpus.repos.empty?    
      end

      should "start without refs" do
        assert @r.corpus.refs.empty?    
      end
    
      should "add repos by paths" do
        instance_eval(&populate)
        assert @r.corpus.repos.size == repo_dirs.size
        assert @r.corpus.repos.keys.all? { |r| r =~ /^repo\d+$/ }
        assert @r.corpus.repos.values.all? { |r| r.is_a?(Grit::Repo) }
        assert @r.corpus.refs.empty?
      end
    
      should "default refs for existing repos without explicit ref" do
        instance_eval(&populate)
        assert @r.corpus.refs.empty?
        @r.corpus.refs['repo1'] = explicit = 'explicit-ref-for-this-repo'
        @r.corpus.default_refs!
        masters, explicits = @r.corpus.refs.partition { |k, v| v == 'master' }
        assert_equal 2, masters.size
        assert_equal 1, explicits.size
      end
    
      should "allow verification of refs" do
        instance_eval(&populate)
        assert @r.corpus.refs.empty?
        @r.corpus.default_refs!    
        assert_nothing_raised do
          @r.corpus.verify_refs!
        end
        @r.corpus.refs.clear    
        @r.corpus.refs['repo1'] = 'this-does-not-exist'
        @r.corpus.default_refs!
        assert_raises ArgumentError do
          @r.corpus.verify_refs!
        end
      end
    
    end
    
  end
    
end
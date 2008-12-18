require 'rubygems'
gem 'mojombo-grit'
require 'grit'

module Rocksteady
  
  class Corpus
        
    attr_reader :app
    def initialize(app)
      @app = app
    end
    
    # SCENARIOS
      
    def scenarios
      @scenarios ||= []
    end
    
    def add_scenario(*args, &block)
      scenario = Scenario.new(self, *args, &block)
      scenarios << scenario
      scenario
    end
    
    # SKIPPED SCENARIOS
    
    def skipped_scenarios
      @skipped_scenarios ||= []
    end
    
    def add_skipped_scenario(name)
      skipped_scenarios << name
    end
    
    # REPOS
  
    def repos
      @repos ||= {}
    end
    
    def add_repos(*paths)
      paths.each do |path|
        repo = Grit::Repo.new(path)
        repos[name_of(repo)] = repo
      end
    end
    
    # REMOTE REPOS
    
    def remote_repos
      @remote_repos ||= {}
    end
    
    def add_remote_repo(name, url)
      remote_repos[name] = url
    end
    
    # REFS
    
    def refs
      @refs ||= {}
    end
  
    def default_refs!
      repos.each_key do |repo_name|
        refs[repo_name] ||= 'master'
      end
    end
  
    def verify_refs!
      refs.each do |repo_name, ref|
        repo = repos[repo_name]
        unless repo.log(ref).any?
          raise ArgumentError, "Could not find #{repo_name} ref `#{ref}'"
        end
      end
    rescue Grit::Git::GitTimeout => e
      puts 'Grit error'
      puts "  Command: #{e.command}"
      puts "  Bytes: #{e.bytes_read}"
      raise e
    end
  
    def session
      @session ||= Session.new(self)
    end
    
    def schedule
      @schedule ||= []
    end
    
    #######
    private
    #######
  
    # Extract the canonical name of the git repository
    def name_of(repo)
      case repo.path
      when /#{File::SEPARATOR}\.git$/
        File.basename(File.dirname(repo.path))
      else
        File.basename(repo.path, '.git')
      end
    end
    
  end
  
end
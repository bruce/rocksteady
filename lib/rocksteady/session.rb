module Rocksteady
  
  class Session
    
    attr_reader :corpus
    def initialize(corpus)
      @corpus = corpus
    end
    
    def title
      @title ||= corpus.refs.map { |k, v| "#{k} `#{v}'" }.join(' vs ')
    end
    
    def timestamp
      @timestamp ||= Time.now.to_i
    end
    
    def run!
      return if corpus.schedule.empty?
      create_timestamp_directory
      clone_repos
      corpus.schedule.each do |scenario|
        focus_on scenario do
          scenario.run!
        end
      end
      yield corpus.schedule
    end
    
    #######
    private
    #######
    
    def timestamp_directory
      File.expand_path("build/#{timestamp}")
    end
        
    def create_timestamp_directory
      mkdir_p timestamp_directory
    end
    
    # FIXME: Cleanup
    def clone_repos
      Dir.chdir timestamp_directory do
        mkdir_p 'repos'
        corpus.refs.each do |repo_name, ref|
          repo = corpus.repos[repo_name]
          path = File.expand_path("repos/#{repo_name}")
          (class << corpus.app; self; end).send(:define_method, "#{repo_name}_path") { path }
          sh "git clone -q '#{repo.path}' '#{path}'"
          Dir.chdir path do
            sh "git checkout -q '#{ref}'"
          end
        end
      end
    end
    
    def focus_on(scenario, &block)
      directory = directory_for(scenario)
      (class << corpus.app; self; end).send(:define_method, "scenario_log") { logfile_for(scenario) }
      mkdir_p directory
      Dir.chdir(directory, &block)
    end
    
    #######
    private
    #######
    
    def logfile_for(scenario)
      File.join(directory_for(scenario), 'scenario.log')
    end
    
    def directory_for(scenario)
      File.join("#{timestamp_directory}/scenarios/#{scenario.name}")
    end
    
  end
  
end
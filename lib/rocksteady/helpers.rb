module Rocksteady
  
  module Helpers
          
    def corpus
      @corpus ||= Rocksteady::Corpus.new(self)
    end

    def repos(*paths)
      corpus.add_repos(*paths.flatten)
    end
    
    def remote_repos(repos)
      repos.each do |name, url|
        corpus.add_remote_repo(name, url)
      end
    end

    def scenario(opts, &block)
      title, deps = if opts.is_a?(Hash)
        [opts.keys.first, Array(opts.values.first)]
      else
        [opts, []]
      end
      scenario = corpus.add_scenario(title, &block)
      generate_scenario_task scenario, deps
    end
    
    #######
    private
    #######

    # Create the scenario task
    def generate_scenario_task(scenario, deps)
      deps.unshift 'rocksteady:refs:check'
      desc scenario.title
      task "rocksteady:scenario:#{corpus.scenarios.size}" => deps do |t|
        scenario.schedule!
      end
    end
      
  end
    
end

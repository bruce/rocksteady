class RockSteady
  
  module Helpers
    
    def rocksteady
      @rocksteady ||= RockSteady.new
    end

    def set_repos(*paths)
      rocksteady.add_repos(*paths.flatten)
    end

    def repo(repo_name)
      rocksteady.repos[repo_name.to_s]
    end

    def scenario(opts, &block)
      title, deps = if opts.is_a?(Hash)
        [opts.keys.first, Array(opts.values.first)]
      else
        [opts, []]
      end
      rocksteady.scenarios << __create_scenario(title, deps, &block)
    end
    
    #######
    private
    #######

    def __create_scenario(title, deps, &block)
      name = title.gsub(/[^[:alnum:]]+/, '_').downcase
      task_name = "rocksteady:scenario:#{name}"
      task "#{task_name}:prepare" => 'rocksteady:run' do
        @scenario_dir = File.expand_path("build/#{@timestamp}/scenarios/#{name}")
        rm_rf @scenario_dir rescue nil
        mkdir_p @scenario_dir
      end
      desc %(Run scenario: "#{title}")
      task(task_name => deps.unshift("#{task_name}:prepare", "rocksteady:scenario_chdir"), &block)
      name
    end
    
  end
end
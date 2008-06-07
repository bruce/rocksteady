require 'rubygems'
require 'rake'

namespace :rocksteady do
  
  desc "Remove build files"
  task :clean do
    rm_rf 'build' rescue nil
  end
  
  task :run => 'rocksteady:refs:check' do
    @timestamp = Time.now.to_i
  end
  
  task :scenario_chdir do
    Dir.chdir @scenario_dir
  end
  
  namespace :refs do
    
    task :check => :default do
      begin
        @rocksteady.verify_refs!
      rescue ArgumentError => e
        abort e.message
      end
    end
    
    task :default => :add_from_env do
      @rocksteady.default_refs!
    end
    
    task :add_from_env => 'rocksteady:repos:check' do
      if ENV['REFS']
        pairs = ENV['REFS'].split(',').map
        pairs.each do |pair|
          repo_name, ref = pair.split(':')
          ref ||= 'master'
          if (repo = @rocksteady.repos[repo_name])
            @rocksteady.refs[repo_name] = ref
          end
        end
      end
    end
    
  end
  
  namespace :repos do
    
    desc "Show configured source repositories"
    task :show => :check do
      @rocksteady.repos.sort_by { |k, v| k }.each do |name, repo|
        puts "#{name}: #{repo.path}"
      end
    end
    
    task :check => :add_from_env do
      unless @rocksteady.repos.any?
        abort "Could not find repositories.\nSet ENV['REPOS'] or use `repo' method in Rakefile to set repo paths."
      end
    end
    
    task :add_from_env do
      if ENV['REPOS']
        paths = ENV['REPOS'].split(',')
        @rocksteady.add_repos(*paths)
      end
    end

  end
  
end

desc "Run all scenarios"
task :rocksteady => 'rocksteady:run' do
  @rocksteady.scenario_tasks.each do |t|
    Rake::Task[t].invoke
  end
end


include RockSteady::Helpers
@rocksteady = RockSteady.new
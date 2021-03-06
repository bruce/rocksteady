require 'rubygems'
require 'rake'

namespace :rocksteady do
  
  desc "Remove build files"
  task :clean do
    rm_rf 'build' rescue nil
  end
  
  namespace :refs do
    
    task :check => :default do
      begin
        corpus.verify_refs!
      rescue ArgumentError => e
        abort e.message
      end
    end
    
    task :default => :add_from_env do
      corpus.default_refs!
    end
    
    task :add_from_env => 'rocksteady:repos:check' do
      if ENV['REFS']
        pairs = ENV['REFS'].split(',').map
        pairs.each do |pair|
          repo_name, ref = pair.split(':')
          ref ||= 'master'
          if (repo = corpus.repos[repo_name])
            corpus.refs[repo_name] = ref
          end
        end
      end
    end
    
  end
  
  namespace :repos do
    
    desc "Show configured source repositories"
    task :show => :check do
      corpus.repos.sort_by { |k, v| k }.each do |name, repo|
        puts "#{name}: #{repo.path}"
      end
    end
    
    desc "Fetch remote repositories"
    task :fetch do
      root = File.join('build', 'clones')
      mkdir_p root
      corpus.remote_repos.each do |name, url|
        # Move to corpus?
        path = File.join(root, name.to_s)
        if File.directory?(path)
          puts "#{path} already cloned, pulling"
          Dir.chdir(path) do
            sh "git fetch"
          end
        else
          puts "#{path} does not exist, cloning"
          sh "git clone #{url} #{path}" 
        end
        
        corpus.add_repos(path)
      end
    end
    
    task :check => :add_from_env do
      unless corpus.repos.any?
        abort "Could not find repositories.\nSet ENV['REPOS'] or use `repos' method in Rakefile to set repo paths."
      end
    end
    
    task :add_from_env do
      if ENV['REPOS']
        paths = ENV['REPOS'].split(',')
        corpus.add_repos(*paths)
      end
    end

  end
  
end

desc "Run all corpus scenarios"
task :rocksteady => ['rocksteady:repos:fetch', 'rocksteady:refs:check'] do
  corpus.scenarios.each do |scenario|
    scenario.schedule!
  end
end
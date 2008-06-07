require 'rubygems'
require 'mojombo-grit'
require 'rake'

$:.unshift(File.dirname(__FILE__))
require 'rocksteady/tasks'
require 'rocksteady/helpers'

class RockSteady
    
  def scenario_tasks
    @scenario_tasks ||= []
  end
  def repos
    @repos ||= {}
  end
  def add_repos(*paths)
    paths.each do |path|
      repo = Grit::Repo.new(path)
      repos[name_of(repo)] = repo
    end
  end
  def refs
    @refs ||= {}
  end
  # Extract the canonical name of the git repository
  def name_of(repo)
    case repo.path
    when /#{File::SEPARATOR}\.git$/
      File.basename(File.dirname(repo.path))
    else
      File.basename(repo.path)
    end
  end
end

@rocksteady = RockSteady.new
module Rocksteady
  
  class Scenario
    
    attr_reader :corpus, :title, :operation
    def initialize(corpus, title, &operation)
      @corpus = corpus
      @title = title
      @operation = operation
    end
    
    def schedule!
      corpus.schedule << self
    end
    
    def name
      @name ||= title.gsub(/[^[:alnum:]]+/, '_').downcase
    end
    
    def result
      @result ||= begin
        operation.call
      rescue Exception => e
        e
      end
    end
    alias :run! :result
    
  end
  
end
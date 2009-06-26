module OrderedSubscribersExperiment
  include ::MPT
  
  experiment "Ordered filter chain with event object" do
    input_object = { :content => "One one white rabbit that can do anything in one white summer" }
    
    Event.subscribe '/filters/count-words', :as => :result_word_uppercaser, :after => :word_counter do
      cnts = event_object[:counts]
      cnts.each do |word, count|
        cnts.delete word
        cnts[word.upcase] = count
      end
    end
    
    Event.subscribe '/filters/count-words' do
      # empty filter handler
    end
    
    Event.subscribe '/filters/count-words', :as => :word_counter, :after => :normalizer do
      word_counts = {}
      words = event_object[:content].split
      words.each do |word|
        word_counts[word] ||= 0
        word_counts[word] += 1
      end
      
      event_object[:counts] = word_counts
    end
    
    Event.subscribe '/filters/count-words', :as => :normalizer do
      event_object[:content].downcase!
    end
    
    result_object = Event.trigger_with_object '/filters/count-words', input_object
    
    puts "Result is:\n#{result_object[:counts].inspect}"
  end
end
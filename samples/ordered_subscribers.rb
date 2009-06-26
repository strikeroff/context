module OrderedSubscribersExperiment
  include ::MPT
  
  experiment "Ordered filter chain with event object" do
    input_object = { :content => "This scintillating new production of Shakespeare's romantic comedy is one of the most accomplished Shakespeare in the Park productions in some time." }
    
    Event.subscribe '/filters/count-words', :as => :remove_unimportant_characters do
      event_object[:content].gsub!( /[\!\.\,\?\:\=\-]|('s)/, '' )
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
    
    Event.subscribe '/filters/count-words', :as => :normalizer, :after => :remove_unimportant_characters do
      event_object[:content].downcase!
    end
    
    result_object = Event.trigger_with_object '/filters/count-words', input_object
    
    puts "Result is:\n#{result_object[:counts].inspect}"
  end
end
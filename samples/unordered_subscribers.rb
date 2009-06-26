module UnorderedSubscribersExperiment
  include ::MPT
  
  experiment "Unordered subscribers with void event object" do
    Event.subscribe '/system/special-channel' do |parameter|
      self.event_object = parameter
    end

    Event.subscribe '/system/special-channel' do |parameter|
      self.event_object = "#{event_object} AND same shit"
    end

    result = Event.trigger '/system/special-channel', "XXX"
    puts "Result is: #{result}"
  end
end

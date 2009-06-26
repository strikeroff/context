
experiment "Unordered subscribers with void event object" do
	subscribe '/system/special-channel' do |parameter|
		self.event_object = parameter
	end

	subscribe '/system/special-channel' do |parameter|
		self.event_object = "#{event_object} AND same shit"
	end

	result = event '/system/special-channel', "XXX"
	puts "Result is: #{result}"
end

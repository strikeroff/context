require "rubygems"

gem "activesupport"
require "activesupport"

require "implementation.rb"

class GeneralService
	def calculate(input)
		input * input
	end
end

class CustomService < GeneralService
	def initialize(rate = 48)
		@rate = rate
	end
	
	def calculate(input)
		input * @rate
	end
end

class Controller
	def service
		@service ||= GeneralService.new
	end
	
	def logic
		puts "Logic result is: #{service.calculate(2)}"
	end
	
	wrappable :service, '/system/services/logic-service'
end

controller = Controller.new

controller.logic

wrap '/system/services/logic-service' =>  CustomService.new do
	controller.logic
	wrap '/system/services/logic-service' =>  CustomService.new(999) do
		controller.logic
	end
	controller.logic
end
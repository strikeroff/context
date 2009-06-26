module Kernel  
  
  def experiment(title)
    en = @@experiment_number ||= 1
    puts "Experiment ##{en}. #{title}\n\n"

    yield

    puts "\nExperiment ##{en} FINISHED!\n\n\n\n"
    @@experiment_number += 1
  end
  
end

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

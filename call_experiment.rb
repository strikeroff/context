require "requires.rb"

controller = Controller.new
controller.logic

wrap '/system/services/logic-service' => CustomService.new do
	controller.logic # must be 96
	wrap '/system/services/logic-service' => CustomService.new(999) do
		controller.logic # must be 1998
	end
	controller.logic # must be 96 again
end

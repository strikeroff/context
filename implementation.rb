module Kernel  
  @@wrap_variables = {}

  def wrap(var ={}, &block)
    thread_id = Thread.current.object_id
    @@wrap_variables[thread_id]||={}
    temp = @@wrap_variables[thread_id].dup
    @@wrap_variables[thread_id].merge!(var)
    yield
    @@wrap_variables[thread_id] = temp
  end

  def wrap_get(wrap_name, default = nil)
    temp = @@wrap_variables[Thread.current.object_id]
    res = nil


    if !temp.blank?
      res = temp[wrap_name] unless temp[wrap_name].blank?
	end
	
	if res.nil? && !default.nil?
		res = default
		if default.instance_of?( Proc )
			res = default.call 
		end
	end

    res
  end
end

class Class
	def wrappable(accessor_name, wrap_name)
		code = <<-EOS
		  def #{accessor_name.to_s}_with_wrap_support
			wrap_get("#{wrap_name}", Proc.new { self.send :"#{accessor_name.to_s}_without_wrap_support" })
		  end

		  alias_method_chain :#{accessor_name.to_s}, :wrap_support
		EOS
		
		class_eval(code, __FILE__, __LINE__)
	end
end

class Class
	def wrappable(accessor_name, wrap_name)
		code = <<-EOS
		  def #{accessor_name.to_s}_with_wrap_support
        MPT::Wrap.get("#{wrap_name}", Proc.new { self.send :"#{accessor_name.to_s}_without_wrap_support" })
		  end

		  alias_method_chain :#{accessor_name.to_s}, :wrap_support
		EOS
		
		class_eval(code, __FILE__, __LINE__)
	end
end

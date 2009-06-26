
module MPT
  class Wrap
    @@wrap_variables = {}
    class << self
      def it(var ={}, &block)
        thread_id = Thread.current.object_id
        @@wrap_variables[thread_id]||={}
        temp = @@wrap_variables[thread_id].dup
        @@wrap_variables[thread_id].merge!(var)
        yield
        @@wrap_variables[thread_id] = temp
      end

      def get(wrap_name, default = nil)
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
  end
end

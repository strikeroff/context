
module MPT
  class EventContainer
    attr_accessor :event_object

    def initialize( val = nil )
      self.event_object = val.dup unless val.nil?
    end
    
  end

  class FilterChain < Array
    def reorganize
      index = 0
      while index < self.size
        filter = self[index]
        filter_opts = filter[:options]
        unless filter_opts[:after].nil?
          for i in index..self.size-1
            fo = self[i][:options]
            unless fo[:as].nil?
              if fo[:as] == filter_opts[:after]
                new_chain = []
                new_chain += self[0..index-1] if index > 0
                new_chain += [self[i]]
                new_chain += self[index..i-1]
                new_chain += self[i+1..self.size-1]
                self.replace new_chain 
                index = 0
                break
              end # if :as matched with :after
            end	# unless :as is nil				
          end # for next items
        end # unless :after is nil
        index += 1
      end # while index < list size
    end # def reorganize
  end # filter chain class

  class Event
    @@mpt_subscribers = {}
    
    class << self
      def subscribe(event_name, options = {}, &block)
        channel = @@mpt_subscribers[event_name] ||= MPT::FilterChain.new
        channel << { :options => options, :proc => block }
        channel.reorganize
      end

      def trigger_with_object(event_name, object, *args)
        container = MPT::EventContainer.new(object)
        channel = @@mpt_subscribers[event_name]
        if channel.size > 0

          mod = Module.new
          container.extend mod

          channel.each do |subscriber|
            mod.send :define_method, :handler, subscriber[:proc]
            container.handler *args
          end
        end

        container.event_object
      end

      def trigger(event_name, *args)
        trigger_with_object(event_name, nil, *args)
      end
    end # end of static section
  end # end of class Event
  
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

module Kernel  
  
  def experiment(title)
    en = @@experiment_number ||= 1
    puts "Experiment ##{en}. #{title}\n\n"

    yield

    puts "\nExperiment ##{en} FINISHED!\n\n\n\n"
    @@experiment_number += 1
  end
  
end


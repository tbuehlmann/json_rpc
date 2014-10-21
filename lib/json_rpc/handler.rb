require 'set'

module JsonRpc
  module Handler
    module ClassMethods
      def expose(*methods)
        methods.flatten.each do |method|
          if public_instance_methods.include?(method)
            manually_exposed_methods << method
          else
            raise NoMethodError.new("Could not find public instance method '%s'" % method)
          end
        end
      end

      def expose_all
        @exposes_all = true
      end

      def exposes_all?
        defined?(@exposes_all) && @exposes_all == true
      end

      def exposes?(method)
        method = method.to_s
        exposed_methods.any? { |exposed_method| exposed_method.to_s == method }
      end

      def exposed_methods
        if exposes_all?
          public_instance_methods - Object.public_instance_methods
        else
          manually_exposed_methods
        end
      end

      def manually_exposed_methods
        @manually_exposed_methods ||= Set.new
      end
    end

    def self.included(klass)
      klass.extend(ClassMethods)
    end

    attr_accessor :json_rpc_request

    def invoke_method(method_name, params)
      case params
      when Hash
        public_send(method_name, params)
      when Array
        public_send(method_name, *params)
      when NilClass
        public_send(method_name)
      end
    end
  end
end

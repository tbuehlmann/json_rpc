require 'multi_json'
require 'rack/request'
require 'rack/response'

module JsonRpc
  class Application
    class << self
      def route(path, &block)
        router.route(path, &block)
      end

      def namespace(namespace, &block)
        router.namespace(namespace, &block)
      end

      def expose(handler, **args)
        router.expose(handler, **args)
      end

      def namespace_separator(separator)
        router.namespace_separator = separator.to_s
      end

      def router
        @router ||= Router.new
      end
    end

    def call(env)
      @request = Rack::Request.new(env)
      @response = Rack::Response.new([], 200, {'Content-Type' => 'application/json'})

      if @request.post?
        handle_request
      else
        raise RequestError.new(code: -1, message: 'Invalid HTTP verb', id: nil)
      end
    rescue JsonRpc::RequestError => error
      json = MultiJson.encode(error.as_json)
      @response.write(json)
    ensure
      return @response.finish
    end

    private

    def handle_request
      json_rpc_request = MultiJson.decode(@request.body)

      response = case json_rpc_request
      when Array
        process_requests(json_rpc_request) # returns array of response hashes or nils if notification
      else
        process_request(json_rpc_request) # returns response hash {} or nil if notification
      end

      @response.write(response.to_json) if response && !response.empty?
    rescue MultiJson::ParseError
      raise RequestError.new(code: -32700, message: 'Parse error', id: nil)
    end

    def process_request(json_rpc_request)
      if json_rpc_request.kind_of?(Hash)
        begin
          request = Request.from_json(json_rpc_request)
          request.validate!
          handler, method = handler_and_method_for_path_and_namespaced_method(@request.path, request.method)

          if handler
            invoke_handler(handler, method, request)
          else
            raise RequestError.new(code: -32601, message: 'Method not found', id: nil)
          end
        rescue RequestError => error
          request.notification? ? nil : error.as_json
        rescue StandardError => error
          $stderr.puts(error.message, error.backtrace.join("\n"))
          RequestError.new(code: -32603, message: 'Internal error', id: nil).as_json
        end
      else
        RequestError.new(code: -32600, message: 'Invalid Request').as_json
      end
    end

    def process_requests(json_rpc_requests)
      responses = json_rpc_requests.map { |json_rpc_request| process_request(json_rpc_request) }
      responses.compact
    end

    def invoke_handler(handler, method, request)
      handler = handler.new
      handler.json_rpc_request = request

      result = case request.params
      when Hash
        handler.public_send(method, request.params)
      when Array
        handler.public_send(method, *request.params)
      when NilClass
        handler.public_send(method)
      end

      request.notification? ? nil : {jsonrpc: JSON_RPC_VERSION, result: result, id: request.id}
    rescue StandardError => error
      if error.kind_of?(RequestError) || ['development', 'test'].include?(ENV['RACK_ENV'])
        raise error
      else
        raise RequestError.new(code: -32603, message: 'Internal error', id: nil)
      end
    end

    def handler_and_method_for_path_and_namespaced_method(path, namespaced_method)
      self.class.router.handler_and_method_for_path_and_namespaced_method(path, namespaced_method)
    end
  end
end

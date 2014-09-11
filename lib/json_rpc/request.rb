module JsonRpc
  class Request
    def self.from_json(json)
      new.tap do |request|
        ['jsonrpc', 'method', 'params', 'id'].each do |attribute|
          request.public_send("#{attribute}=", json[attribute]) if json.has_key?(attribute)
        end
      end
    end

    attr_accessor :jsonrpc, :method, :params, :id, :error

    def initialize(options = {})
      options.each do |key, value|
        public_send("#{key}=", value)
      end

      yield(self) if block_given?
      @errors = {}
    end

    def valid?
      validate_jsonrpc && validate_method && validate_params && validate_id
    end

    def validate!
      unless valid?
        error = @errors.first.last.tap do |error_hash|
          error_hash[:id] = @errors[:id] ? nil : @id
        end

        raise RequestError.new(**error)
      end
    end

    def notification?
      !defined?(@id)
    end

    private

    def validate_jsonrpc
      if jsonrpc == JSON_RPC_VERSION
        true
      else
        @errors[:jsonrpc] = {code: -32600, message: 'Invalid jsonrpc version'}
        false
      end
    end

    def validate_method
      if method.kind_of?(String) && !method.empty?
        true
      else
        @errors[:method] = {code: -32601, message: 'Method not found'}
        false
      end
    end

    def validate_params
      if defined?(@params)
        case params
        when Hash, Array, NilClass
          true
        else
          @errors[:params] = {code: -32602, message: 'Invalid params'}
          false
        end
      else
        true
      end
    end

    def validate_id
      if notification?
        true
      else
        case @id
        when String, Numeric, NilClass
          true
        else
          @errors[:id] = {code: -32600, message: 'Invalid Request', data: 'Invalid id'}
          false
        end
      end
    end
  end
end

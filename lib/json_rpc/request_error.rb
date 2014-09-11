module JsonRpc
  class RequestError < StandardError
    def initialize(code: -32600, message: 'Invalid Request', data: nil, id: nil)
      @code = code
      @message = message
      @data = data
      @id = id
    end

    def as_json
      {jsonrcp: JSON_RPC_VERSION, error: {code: @code, message: @message}, id: @id}.tap do |error|
        error[:error][:data] = @data if @data
      end
    end

    def to_json
      as_json.to_json
    end
  end
end

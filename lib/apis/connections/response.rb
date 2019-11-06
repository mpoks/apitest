# frozen_string_literal: true

module Apis
  module Connections
    # Response parses the faraday response object
    class Response
      # @return [Integer] the HTTP status code.
      attr_accessor :status, :body, :error

      SUCCESS_STATUSES = (200..299).freeze

      # @param response [#status, #body] The response to deserialize.
      def initialize(response)
        @error = nil
        parsed_response(response)
        @error = body[:error][:message] unless response.success?
      end

      def success?
        SUCCESS_STATUSES.include?(status)
      end

      private

      # Deserialize a response
      # @param response [#status, #body] the response to deserialize
      def parsed_response(response)
        @status = response.status

        begin
          @body = JSON.parse(response.body, symbolize_names: true)
        rescue JSON::ParserError
          @body = {}
        end
      end
    end
  end
end

# frozen_string_literal: true

require 'faraday'
require 'json'
require 'apis/connections/response'
require 'net/http'

module Apis
  module Connections
    # Client creates a connection to service and executes https requests
    module Client
      MAX_RETRY = 5

      RETRY_EXCEPTIONS = [Faraday::Error::ConnectionFailed, Net::HTTPServerError].freeze

      attr_accessor :api_key, :status, :response_body

      # initialises connection to service
      # @param url [String] host url
      def connection(url)
        @client = Faraday.new(url: url) do |faraday|
          faraday.request  :retry, max: MAX_RETRY,
                                   exceptions: RETRY_EXCEPTIONS
          faraday.response :logger if ENV['DEBUG'] == 'true'
          faraday.adapter  Faraday.default_adapter
          faraday.options[:open_timeout] = 10
          faraday.headers['Authorization'] = authorization
          faraday.headers['Content-Type'] = content_type
        end
      end

      # Executes http request
      # @param http_method [String] http method
      # @param path [String] api endpoint
      # @param params [Hash] parameters for making request
      def execute_request(http_method, path, params: nil)
        params = URI.encode_www_form(params) if !params.nil? && http_method == 'post'
        res = @client.public_send(http_method, path, params)
        Response.new(res)
      end

      def content_type
        'application/x-www-form-urlencoded'
      end

      def authorization
        "Bearer #{@api_key}"
      end

      private

      attr_accessor :client
    end
  end
end

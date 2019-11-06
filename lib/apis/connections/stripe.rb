# frozen_string_literal: true

require 'faraday'
require 'apis/connections/client'

module Apis
  module Connections
    # Stripe contains connection to stripe apis
    class Stripe
      include ::Apis::Connections::Client

      attr_accessor :con

      def initialize
        @base_url = ENV['STRIPE_URL'] || missing_env_stripe_url
        @api_key = ENV['STRIPE_API_KEY'] || missing_env_api_key
        connection(@base_url)
      end

      def missing_env_stripe_url
        raise Exception('Missing environment variable: STRIPE_URL')
      end

      def missing_env_api_key
        raise Exception('Missing environment variable: STRIPE_API_KEY')
      end
    end
  end
end

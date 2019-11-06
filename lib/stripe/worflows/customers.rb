# frozen_string_literal: true

require 'apis/connections/stripe'

module Stripe
  module Workflows
    class ApiError < RuntimeError; end

    # Customers contains workflows related to customer api
    class Customers
      # Creates new customer
      # @param customer_info [Hash] customer information
      # @return [Hash] response body
      def self.create_customer(customer_info)
        res = client.execute_request('post', '/v1/customers', params: customer_info)
        raise ApiError, "Code:#{res.status} Message #{res.error}" unless res.success?

        res.body
      end

      # Gets customer
      # @param id [String] customer id
      # # @return [Hash] response body
      def self.retrieve_customer(id)
        res = client.execute_request('get', "/v1/customers/#{id}")
        raise ApiError, "Code:#{res.status} Message #{res.error}" unless res.success?

        res.body
      end

      # Deletes customer
      # @param id [String] customer id
      # # @return [Hash] response body
      def self.delete_customer(id)
        res = client.execute_request('delete', "/v1/customers/#{id}")
        raise ApiError, "Code:#{res.status} Message #{res.error}" unless res.success?

        res.body
      end

      # Updates customer
      # @param id [String] customer id
      # @param customer_info [Hash] customer information
      # # @return [Hash] response body
      def self.update_customer(id, customer_info)
        res = client.execute_request('post', "/v1/customers/#{id}", params: customer_info)
        raise ApiError, "Code:#{res.status} Message #{res.error}" unless res.success?

        res.body
      end

      # lists all customers
      # @param params [Hash] filter list of customers
      # # @return [Hash] response body
      def self.list_all(params: nil)
        res = client.execute_request('get', 'v1/customers', params: params)
        raise ApiError, "Code:#{res.status} Message #{res.error}" unless res.success?

        res.body[:data]
      end

      def self.client
        @client ||= Apis::Connections::Stripe.new
      end

      private_class_method :client

      private

      attr_accessor :client
    end
  end
end

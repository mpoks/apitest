# frozen_string_literal: true

require 'json'
require 'rspec'
require 'apis/connections/stripe'
require 'stripe/worflows/customers'

require 'dotenv'

Dotenv.load('.env')

describe 'Stripe customers' do
  let!(:client) { Apis::Connections::Stripe.new }
  let!(:customer_info1) { FactoryBot.build(:customer_info).to_hash }
  let!(:customer1) { Stripe::Workflows::Customers.create_customer(customer_info1) }
  let!(:customer_info2) { FactoryBot.build(:customer_info).to_hash }
  let!(:customer2) { Stripe::Workflows::Customers.create_customer(customer_info2) }

  describe 'Create a customer' do
    context 'when create parameters are valid' do
      it 'creates new customer with given parameters' do
        customer_info = FactoryBot.build(:customer_info)
        res = client.execute_request('post', '/v1/customers', params: customer_info.to_hash)
        expect(res.status).to eq(200)
        body = res.body
        expect(body[:id].nil?).to be_falsey
        expect(body[:description]).to eq(customer_info.description)
        expect(body[:email]).to eq(customer_info.email)
        expect(body[:name]).to eq(customer_info.name)
      end
    end

    context 'when create parameters are invalid' do
      it 'returns error for invalid coupon' do
        body = { coupon: 'Invalid coupon' }
        res = client.execute_request('post', '/v1/customers', params: body)

        expect(res.status).to eq(400)
        expect(res.error).to eq("No such coupon: #{body[:coupon]}")
      end

      it 'returns error for invalid source' do
        body = { source: 'Invalid source' }
        res = client.execute_request('post', '/v1/customers', params: body)

        expect(res.status).to eq(400)
        expect(res.error).to eq("No such token: #{body[:source]}")
      end
    end
  end

  describe 'Retrieve a customer' do
    context 'with valid identifier' do
      it 'returns customer information' do
        res = Stripe::Workflows::Customers.retrieve_customer(customer1[:id])

        expect(res[:description]).to eq(customer_info1[:description])
        expect(res[:email]).to eq(customer_info1[:email])
        expect(res[:name]).to eq(customer_info1[:name])
      end
      it('sets deleted property') do
        info = FactoryBot.build(:customer_info)
        customer = Stripe::Workflows::Customers.create_customer(info.to_hash)
        Stripe::Workflows::Customers.delete_customer(customer[:id])
        res = Stripe::Workflows::Customers.retrieve_customer(customer[:id])

        expect(res[:deleted]).to eq(true)
      end
    end
    context 'with invalid identifier' do
      it 'returns error' do
        invalid_id = 'invalid'
        res = client.execute_request('post', "/v1/customers/#{invalid_id}")

        expect(res.status).to eq(404)
        expect(res.error).to eq("No such customer: #{invalid_id}")
      end
    end
  end

  describe 'Update a customer' do
    context 'when update parameters are valid' do
      it 'updates customer with given parameters without changing unprovided parameters' do
        update_info = { name: 'Jane Doe' }
        res = Stripe::Workflows::Customers.update_customer(customer1[:id], update_info)

        expect(res[:id]).to eq(customer1[:id])
        expect(res[:name]).to eq(update_info[:name])
      end
    end

    context 'when update parameters are invalid' do
      it 'returns error for invalid coupon' do
        update_info = { coupon: 'Invalid coupon' }
        res = client.execute_request('post',
                                     "/v1/customers/#{customer1[:id]}",
                                     params: update_info)

        expect(res.status).to eq(400)
        expect(res.error).to eq("No such coupon: #{update_info[:coupon]}")
      end

      it 'returns error for invalid source' do
        update_info = { source: 'Invalid source' }
        res = client.execute_request('post',
                                     "/v1/customers/#{customer1[:id]}",
                                     params: update_info)

        expect(res.status).to eq(400)
        expect(res.error).to eq("No such token: #{update_info[:source]}")
      end
    end
  end

  describe 'Delete a customer' do
    context 'with valid id' do
      it 'returns subset of customer info' do
        info = FactoryBot.build(:customer_info)
        customer = Stripe::Workflows::Customers.create_customer(info.to_hash)
        res = Stripe::Workflows::Customers.delete_customer(customer[:id])
        expect(res[:id]).to eq(customer[:id])
        expect(res[:object]).to eq('customer')
        expect(res[:deleted]).to be_truthy
        expect(res[:name].nil?).to be_truthy
      end
    end
    context 'with invalid id' do
      it 'returns error' do
        invalid_id = 'invalid'
        res = client.execute_request('delete', "/v1/customers/#{invalid_id}")

        expect(res.status).to eq(404)
        expect(res.error).to eq("No such customer: #{invalid_id}")
      end
    end
  end

  describe 'List all customers' do
    it 'retrieves all customers sorted by creation date' do
      data = Stripe::Workflows::Customers.list_all
      expect(data.count >= 2).to be_truthy

      index1 = data.index { |c| c[:id] == customer1[:id] }
      index2 = data.index { |c| c[:id] == customer2[:id] }
      expect(index1 > index2).to be_truthy
    end

    it 'returns number of customers as per set limit' do
      data = Stripe::Workflows::Customers.list_all(params: { limit: 1 })
      expect(data.count).to eq(1)
    end

    it 'filters customers as per email' do
      data = Stripe::Workflows::Customers.list_all(params: { email: customer1[:email] })
      expect(data[0][:email]).to eq(customer1[:email])
    end

    it 'returns empty array if no more customers available' do
      data = Stripe::Workflows::Customers.list_all(params: { email: 'invalid@example.com' })
      expect(data.count).to eq(0)
    end
  end
end

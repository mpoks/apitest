# frozen_string_literal: true

require 'faker'

FactoryBot.define do
  factory :customer_info do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    name { "#{first_name} #{last_name}" }
    email { "#{first_name}.#{last_name}@example.com" }
    description { Faker::Lorem.sentence }
  end
end

class CustomerInfo
  attr_accessor :name, :email, :description, :first_name, :last_name

  def to_hash
    {
      name: name,
      email: email,
      description: description
    }
  end
end

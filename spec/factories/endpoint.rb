# frozen_string_literal: true
FactoryBot.define do
  factory :endpoint do
    sequence(:id) { |n| }
    path { '/hello/world' }
    code { 200 }
    body { '"{ "message": "Hello world" }"' }
    verb { 'get' }
    headers { { "Content-Type": 'application/json' } }
  end
end

FactoryBot.define do
  factory :todo do
    title { "Test Todo #{rand(1000)}" } # Unique titles
    description { "A test todo" }
    completed { false }
  end
end
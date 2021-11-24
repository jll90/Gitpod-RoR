# This will guess the User class
FactoryBot.define do
  factory :user do
    phone { User.generate_phone }
    password { 'foobar' }
    password_confirmation { 'foobar' }
  end

  factory :product do
    address { 'fake address' }
    description { Faker::Commerce.product_name * 15 }
    latitude { Faker::Address.latitude }
    longitude { Faker::Address.longitude }
    name { Faker::Commerce.product_name }
    price { Faker::Commerce.price.to_i }
    region_id { 1 }
    user
    after(:build) do |product| 
      product.attach_test_image 
      product.categorizations << FactoryBot.build(:categorization, product: product, category: create(:category))
    end
    # trait :with_categorizations do
    # create(:product, :with_categorizations)
  end

  factory :categorization do
    category
    product
  end

  factory :token do
    key { TokenGenerator.generate(12) }
    user
  end

  factory :category do
    name { 'test-cat' }
  end

  factory :swipe do
    product
    user
    liked { rand(0..1) == 1 }

    trait :liked do
      liked { true }
    end

    trait :disliked do
      liked { false }
    end

  end

  factory :question do
    product
    user
    addressee { product.owner }
    content { 'I sling dick' }
  end

  factory :reply do
    question
    user
    content { 'my reply' }
  end

  factory :match do
    product
    user { product.owner }
    buyer { association :user }

    after(:create) do |match, evaluator|
      create_list(:product, rand(1..3), user: match.buyer)
    end
  end

  factory :app_experience do
    user
    name { AppExperience.sample_name }
  end

  factory :update_request do
    user
    type { UpdateRequest.sample_type  }
    old_value { User.generate_phone }
  end
end

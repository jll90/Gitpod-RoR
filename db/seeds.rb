# frozen_string_literal: true

require 'open-uri'

Notification.destroy_all
Log.destroy_all
Match.destroy_all
ReplyReceipt.destroy_all
Reply.destroy_all
Question.destroy_all
Match.destroy_all
Swipe.destroy_all
Categorization.destroy_all
Category.destroy_all
Product.destroy_all
User.destroy_all

admin_users = AdminUser.all

if admin_users.empty?
  AdminUser.create!(email: 'admin@truekaso.cl', password: 'truekes123', password_confirmation: 'truekes123')
end

users = User.all

if users.empty?
  %w[
    56992131189
    56969010063
    56971303317
    56940234906
  ].each do |phone_number|
    User.create!(phone: phone_number, password: SecureRandom.hex)
  end
end

categories = Category.all

if categories.empty?
  Category.seed!
end

all_users = User.all
all_categories = Category.all

if Product.all.empty?
  (1..60).each do |_n|
    user = all_users.sample

    new_product = user.products.new(
      name: Faker::Commerce.product_name,
      description: Faker::Commerce.product_name * 15,
      region_id: 1,
      address: 'Dirección falsa',
      latitude: Faker::Address.latitude,
      longitude: Faker::Address.longitude,
      price: Faker::Commerce.price.to_i,
      categorizations_attributes: [{ category_id: all_categories.sample.id }]
    )

    new_product.attach_test_image
    new_product.save!
  end
end

if Swipe.all.empty?
  Swipe.seed!
end

# if Match.all.empty?
#   Match.seed!
# end

if Question.all.empty?
  Question.seed!
end

if Reply.all.empty?
  Reply.seed!
end

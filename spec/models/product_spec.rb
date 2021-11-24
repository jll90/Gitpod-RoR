
require 'rails_helper'

RSpec.describe Question, type: :model do
  describe 'Product' do
    it 'will_delete_images works' do
      product = create(:product)
      product.will_delete_image_ids = product.images.map { |i| i.id }

      expect(product.will_delete_image_ids.size).to be_truthy
    end
  end

  describe "Product creation" do
    it "Valid product can be created" do
      user = create(:user)
      category = create(:category)
      
      new_product = user.products.new(
        name: Faker::Commerce.product_name,
        description: Faker::Commerce.product_name * 15,
        region_id: 1,
        address: 'Dirección falsa',
        latitude: Faker::Address.latitude,
        longitude: Faker::Address.longitude,
        price: Faker::Commerce.price.to_i,
        categorizations_attributes: [{ category_id: category.id }]
      )

      new_product.attach_test_image
      expect(new_product.valid?).to eq true

      expect{new_product.save}.to change(Product, :count).by(1)
    end
  end

  describe 'Product updating' do
    it 'can correctly update categorization attributes' do
      product = create(:product)
      category = create(:category)

      product.run_update(categorizations_attributes: [{ category_id: category.id }])
      expect(product.categorizations.size).to eq(1)
    end

    it 'can correctly update images' do
      product = create(:product)
      expect(product.images.size).to eq(1)

      product.attach_test_image
      product.save
      expect(product.images.size).to eq(2)
    end
  end
end

require 'rails_helper'

RSpec.describe "Product Requests", :type => :request do
  def build_image
    fixture_file_upload('spec/assets/test-product.webp')
  end

  def product_params
    category = create(:category)

    {
      name: Faker::Commerce.product_name,
      description: Faker::Commerce.product_name * 15,
      region_id: 1,
      address: 'Dirección falsa',
      latitude: Faker::Address.latitude,
      longitude: Faker::Address.longitude,
      price: Faker::Commerce.price.to_i,
      categorizations_attributes: [{ category_id: category.id }],
      images: [build_image]
    }
  end

  describe "Product creation" do
    it "works" do
      token = create(:token)

      params = { 
        body: product_params
      }

      url = "/api/products.json"
      post url, params: params, headers: RequestsHelpers.build_headers(token.key, { 'Content-Type' => 'multipart/form-data'})
      expect(response.status).to eq 200
    end
  end

  describe 'Product show' do
    it 'returns a product belonging to the user' do
      token = create(:token)
      product = create(:product, user: token.user)

      url = "/api/products/#{product.id}/self.json"
      get url, headers: RequestsHelpers.build_headers(token.key)
      expect(response.status).to eq 200
    end
  end

  describe 'Product indexing' do
    it 'user can index his own products' do
      token = create(:token)
      create_list(:product, 5, user: token.user)

      url = '/api/products/self.json'
      get url, headers: RequestsHelpers.build_headers(token.key)
      expect(response.status).to eq 200
    end

    it 'can read the random stack anonymously' do
      create_list(:product, 5)

      url = '/api/products/discover.json'
      get url, headers: RequestsHelpers.build_headers
      expect(response.status).to eq 200
    end

    it 'can read the random stack loggedin' do
      token = create(:token)
      create_list(:product, 5)

      url = '/api/products/discover.json'
      get url, headers: RequestsHelpers.build_headers(token.key)
      expect(response.status).to eq 200
    end
  end

  describe 'Product updating' do
    it "works and it updates images accordingly" do
      product = create(:product)
      images_count = product.images.size
      token = create(:token, user: product.owner)

      params = {
        body: product_params
      }

      url = "/api/products/#{product.id}.json"
      patch url, params: params, headers: RequestsHelpers.build_headers(token.key, { 'Content-Type' => 'multipart/form-data'})
      expect(response.status).to eq 200
      expect(product.reload.images.size).to eq(images_count + 1)
    end

    it "works and it removes images" do
      product = create(:product)
      token = create(:token, user: product.owner)

      params = {
        body: product_params.merge(
          { 
            images: nil,
            to_delete_images: [{ id: product.images.first.id }]
          }
        )
      }

      url = "/api/products/#{product.id}.json"
      patch url, params: params, headers: RequestsHelpers.build_headers(token.key, { 'Content-Type' => 'multipart/form-data'})
      expect(response.status).to eq 200
      expect(product.reload.images.size).to eq(0)
    end
  end
end

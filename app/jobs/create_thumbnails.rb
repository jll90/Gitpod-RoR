# frozen_string_literal: true

class CreateThumbnailsJob < ApplicationJob
  queue_as :default

  def perform(product_id)
    ActiveStorage::Current.host = build_host_url
    record = Product.find(product_id)
    # record.images.each do |i|
    #   i.variant(resize_and_pad: [200, 200, gravity: 'north', background: '#000']).processed.url
    #   i.variant(resize_and_pad: [500, 500, gravity: 'north', background: '#000']).processed.url
    #   i.variant(resize_and_pad: [1000, 1000, gravity: 'north', background: '#000']).processed.url
    # end

    # Product.all.each { |p| p.images.each { |i| i.variant(resize: '50x50>').processed.url } }

    record.images.each do |i|
      i.variant(resize: '50x50>').processed.url
      i.variant(resize: '100x100>').processed.url
      i.variant(resize: '200x200>').processed.url
      i.variant(resize: '500x500>').processed.url
      i.variant(resize: '1000x1000>').processed.url
    end
  end

  def build_host_url
    Product.thumbnail_host_url
  end
end

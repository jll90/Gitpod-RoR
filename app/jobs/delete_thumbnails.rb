# frozen_string_literal: true

class DeleteThumnbnailsJob < ApplicationJob
  queue_as :default

  # TODO: destroy record from active_storage_attachments
  def perform(product_id)
    record = Product.find(product_id)
    record.images.each do |i|
      variant = i.variant(resize: '50x50>')
      i.service.delete(variant.key)
      variant = i.variant(resize: '100x100>')
      i.service.delete(variant.key)
      variant = i.variant(resize: '200x200>')
      i.service.delete(variant.key)
      variant = i.variant(resize: '500x500>')
      i.service.delete(variant.key)
      variant = i.variant(resize: '1000x1000>')
      i.service.delete(variant.key)
    end
  end
end

# frozen_string_literal: true

class ProductDeleteJob < ApplicationJob
  queue_as :default

  def perform(product_id)
    record = Product.find(product_id)
    return unless record.present?

    # matches = Match.where_product_is_member(record.id)
    # matches.map(&:delete_dependency!)
    # this will delete record in active_storage_attachments and also destroy the file
    # record.images.map(&:destroy!)

    # record.categorizations.map(&:delete!)
  end
end

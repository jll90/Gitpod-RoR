require 'will_paginate/array'

class RecordsPagination
  prepend SimpleCommand

  def initialize(records, page, per_page, as_json_opts)
    @records = records || []
    @page = page
    @per_page = per_page
    @as_json_opts = as_json_opts
  end

  def call
    perform
  end

  private

  attr_reader :records, :page, :as_json_opts, :per_page

  def perform
    if page.present?
      object = records.paginate(page: page, per_page: per_page)
      {
        meta: {
          total_pages: object.total_pages,
          next_page: object.next_page,
          prev_page: object.previous_page,
          total_entries: object.total_entries
        },
        records: object.as_json(as_json_opts)
      }
    else
      {
        meta: {
          total_pages: nil,
          next_page: nil,
          prev_page: nil,
          total_entries: records.count
        },
        records: records.as_json(as_json_opts)
      }
    end
  end
end

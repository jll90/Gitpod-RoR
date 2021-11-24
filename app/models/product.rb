# frozen_string_literal: true

class Product < ApplicationRecord
  # include Loggable
  include AASM
  include Truekaso::Thumbnail
  reverse_geocoded_by :latitude, :longitude
  # HOST = 'digitaloceanspaces.com'
  # CDN_HOST = 'cdn.digitaloceanspaces.com'

  belongs_to :user
  # has_many :product_comments
  has_many :swipes
  has_many_attached :images do |attachable|
    attachable.variant :thumb, resize: '100x100'
  end
  has_many :matches
  has_many :questions, dependent: :delete_all
  has_many :categorizations
  has_many :categories, through: :categorizations

  before_create :setup_geopoint
  after_create :handle_creation

  attr_accessor :will_delete_image_ids

  accepts_nested_attributes_for :categorizations, allow_destroy: true

  scope :active, -> { where(state: 'active') }
  # scope :near_school,
  #       lambda {
  #         select('DISTINCT ON (homes.id) homes.*').joins(
  #           'INNER JOIN schools ON ST_DWithin (homes.coords, schools.coords, 1000)'
  #         )
  #       }

  validates :categorizations, presence: true
  validates :address, :name, :price, :latitude, :longitude, :region_id, :images, :description, presence: true
  validates :images, attached: true,
                     content_type: ['image/png', 'image/jpg', 'image/jpeg', 'image/webp'],
                     limit: { min: 1, max: 20 },
                     size: { less_than: 10.megabytes, message: 'must be less than 10MB in size' },
                     dimension: { width: { min: 100, max: 10_000 }, # max was 2400 and 1800
                                  height: { min: 100, max: 10_000 }, message: 'is not given between dimension' }

  aasm column: :state do
    state :pending, initial: true
    state :active
    state :disabled
    state :deleted
    state :traded

    event :activate do
      transitions from: :pending, to: :active
    end

    event :disable do
      transitions from: :active, to: :disabled
    end

    event :reactivate do
      transitions from: :disabled, to: :active
    end

    event :delete, after: :handle_deletion do
      transitions from: %i[pending active disabled], to: :deleted
    end

    event :trade do
      transitions to: :traded #, from: :active
    end

    event :reset do
      transitions to: :active, after: :reset_model_relations
    end
  end

  def archived?
    archived
  end

  def active?
    state == 'active'
  end

  def traded?
    state == 'traded'
  end

  def tradeable? 
    active?
  end

  # def comments
  #   product_comments.as_json(only: %i[comment created_at])
  # end
  #
  def active_categories
    self.categories
  end

  def attachments
    images.map do |url|
      {
        id: url.id,
        url: setup_url(url),
        thumbnails: [
          {size: '50x50', url: prepare_thumbnail(url, 50)},
          {size: '100x100', url: prepare_thumbnail(url, 100)},
          {size: '200x200', url: prepare_thumbnail(url, 200)},
          {size: '500x500', url: prepare_thumbnail(url, 500)},
          {size: '1000x1000', url: prepare_thumbnail(url, 1000)}
        ]
      }
    end
  end

  def run_update(params)
    ActiveRecord::Base.transaction do
      self.categorizations.destroy_all

      to_delete_image_ids = self.will_delete_image_ids&.map || []
      if to_delete_image_ids.any?
        self.images.select { |image| to_delete_image_ids.include? image.id }.map(&:purge)
      end

      params.delete(:to_delete_images) if params.has_key? :to_delete_images

      self.update(params)
    end
  end

  def can_swipe_from?(user_id)
    self.user_id != user_id
  end

  def owner
    user
  end

  def owned_by?(user_like)
    return false if user_like.nil? 
    return user_like.id == self.user_id if user_like.is_a? User
    self.user_id == user_id
  end

  def archive
    update(archived: true)
  end

  def attach_test_image
    images.attach(
      io: File.open(Rails.root.join('spec', 'assets', 'test-product.webp')),
      filename: 'test-product.webp',
      content_type: 'image/webp'
    )
  end

  def self.thumbnail_host_url
    options = Rails.application.routes.default_url_options
    "#{options[:protocol]}://#{options[:host]}"
  end

  private

  def handle_creation
    activate!
    ActiveStorage::Current.host = Product.thumbnail_host_url
    CreateThumbnailsJob.perform_later(self.id) if Rails.env.production?
  end

  def reset_model_relations
    ProductResetJob.perform_later(id)
  end

  def handle_deletion
    ProductDeleteJob.perform_later(id)
  end

  def setup_geopoint
    self[:coords] = Geo.point(longitude, latitude)
  end


  class << self
    def g_near(point, distance)
      where(
        'ST_DWithin(coords, :point, :distance)',
        { point: Geo.to_wkt(point), distance: distance * 1000 }
      )
    end

    def g_within_box(sw_point, ne_point)
      where(
        "coords && ST_MakeEnvelope(:sw_lon, :sw_lat, :ne_lon, :ne_lat, #{
          Geo::SRID
        })",
        {
          sw_lon: sw_point.longitude,
          sw_lat: sw_point.latitude,
          ne_lon: ne_point.longitude,
          ne_lat: ne_point.latitude
        }
      )
    end

    def g_within_polygon(points)
      polygon = Geo.polygon(points)
      where('ST_Covers(:polygon,coords)', polygon: Geo.to_wkt(polygon))
    end
  end
end

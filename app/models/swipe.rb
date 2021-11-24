class Swipe < ApplicationRecord
  belongs_to :user
  belongs_to :product

  validates :user_id, uniqueness: { scope: :product_id }
  validates :liked, inclusion: [true, false]

  after_save :after_save

  def self.upsert(user_id, product, liked)
    raise ArgumentError.new("Cannot swipe one's own product. Product ID: #{product.id} - User ID: #{product.user.id}") unless product.can_swipe_from?(user_id)

    existing_swipe = Swipe.find_by(user_id: user_id, product_id: product.id)
    if existing_swipe
      existing_swipe.update(liked: liked)
      swipe = existing_swipe.reload
    else
      swipe = Swipe.new(user_id: user_id, product_id: product.id,
                        liked: liked)
                      
      return swipe if swipe.save
    end
  end

  def find_match
    return unless self.liked
    Match.where(user_id: self.product.user_id, product_id: self.product.id, buyer_id: self.user.id)&.first
  end

  def self.seed!
    products = Product.all.includes(:user)
    users = User.all

    products.each do |product|
      swipe_user = (users - [product.owner]).sample
      random = rand(0..1)

      Swipe.create!(user_id: swipe_user.id, product_id: product.id, liked: random == 1)
    end
  end

  private

  def after_save
    product = self.product
    existing_match = Match.where(user_id: product.user.id, product_id: product.id, buyer_id: self.user.id)&.first

    ## must like a product to generate a match
    if self.liked
      ## only generate a match iff it doesn't exist
      if existing_match.nil?
        match = Match.new(user_id: product.user.id, product_id: product.id, buyer_id: self.user.id)
        result = match.save
        return match
      else
        return existing_match
      end
    else
      existing_match&.destroy
      return 
    end
  end
end

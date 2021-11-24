class TokenGenerator
  def self.generate(length)
    SecureRandom.urlsafe_base64(length, false)
  end
end

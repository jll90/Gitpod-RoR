class AuthenticationService
  def self.generate_login_code
    rand(100_000..999_999).to_s
  end

  def self.login_with_phone?(user, login_code)
    return false if user.nil?
    return false if user.login_code_sent_at.nil?
    return false if login_code.nil?

    now = DateTime.now
    diff = (now.to_f - user.login_code_sent_at.to_f).to_i

    diff < 120 && user.login_code == login_code
  end
end

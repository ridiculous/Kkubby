class User < ApplicationRecord
  attr_accessor :back_to
  attr_accessor :current_password
  has_secure_password
  has_many :shelves
  before_create -> { generate_token(:auth_token) }
  validates :email, format: { with: EMAIL_PATTERN, allow_blank: true }
  validates :username, presence: true, uniqueness: { case_sensitive: false }
  before_validation :squeeze_username

  def squeeze_username
    self.username &&= username.gsub(/\s+/, '')
  end
end

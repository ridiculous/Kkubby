class User < ApplicationRecord
  attr_accessor :back_to
  attr_accessor :current_password
  has_secure_password
  has_many :shelves, dependent: :destroy
  before_create -> { generate_token(:auth_token) }
  validates :email, format: { with: EMAIL_PATTERN, allow_blank: true }
  validates :username,
            presence: true,
            uniqueness: { case_sensitive: false },
            format: { with: /\A\w+\z/ }
  before_validation :squeeze_username
  after_create ->(user) { Shelf.create_defaults(user) }

  def squeeze_username
    self.username &&= username.gsub(/\s+/, '').downcase
  end

  def display_username
    username.strip.humanize
  end

  def to_param
    username
  end

  def share_link
    "kkubby.com/@#{username}"
  end
end

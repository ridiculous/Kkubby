class ApplicationRecord < ActiveRecord::Base
  EMAIL_PATTERN = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
  include TokenGenerator
  self.abstract_class = true
end

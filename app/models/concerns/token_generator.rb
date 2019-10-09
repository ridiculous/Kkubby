module TokenGenerator
  extend ActiveSupport::Concern

  def generate_token(column)
    begin
      self[column] = SecureRandom.urlsafe_base64
    end while self.class.exists?(column => self[column])
    self[column]
  end

  def generate_number(column, size = 6)
    begin
      self[column] = (SecureRandom.random_number * (1000 ** size)).to_i.to_s[0, size]
    end while self.class.exists?(column => self[column])
    self[column]
  end
end

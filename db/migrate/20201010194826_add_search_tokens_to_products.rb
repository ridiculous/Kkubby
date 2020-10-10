class AddSearchTokensToProducts < ActiveRecord::Migration[6.0]
  def change
    add_column :products, :search_tokens, :tsvector
    add_index :products, :search_tokens
  end
end

class AddCustomUploadsToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :custom_uploads, :boolean, default: false
  end
end

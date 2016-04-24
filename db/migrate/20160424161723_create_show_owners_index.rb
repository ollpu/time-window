class CreateShowOwnersIndex < ActiveRecord::Migration[5.0]
  def change
    add_index :shows, :owners, using: 'gin'
  end
end

class AddOwnersToShows < ActiveRecord::Migration[5.0]
  def change
    add_column :shows, :owners, :integer, array: true, default: []
  end
  
  def up
    change_column :users, :owned_shows, :integer, array: true, default: []
  end
  
  def down
    change_column :users, :owned_shows, :integer, array: true, default: nil
  end
end

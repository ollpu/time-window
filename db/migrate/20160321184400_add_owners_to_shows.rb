class AddOwnersToShows < ActiveRecord::Migration[5.0]
  def up
    change_column :users, :owned_shows, :integer, array: true, default: []
    add_column :shows, :owners, :integer, array: true, default: []
  end
  
  def down
    change_column :users, :owned_shows, :integer, array: true, default: nil
    remove_column :shows, :owners
  end
end

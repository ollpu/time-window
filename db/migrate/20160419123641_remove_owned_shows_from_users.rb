class RemoveOwnedShowsFromUsers < ActiveRecord::Migration[5.0]
  def change
    remove_column :users, :owned_shows
  end
end

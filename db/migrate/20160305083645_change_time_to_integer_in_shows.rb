class ChangeTimeToIntegerInShows < ActiveRecord::Migration[5.0]
  def up
    remove_column :shows, :times
    add_column :shows, :times, :integer, array: true, default: []
  end
  def down
    remove_column :shows, :times
    add_column :shows, :times, :string, array: true, default: []
  end
end

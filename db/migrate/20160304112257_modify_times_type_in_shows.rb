class ModifyTimesTypeInShows < ActiveRecord::Migration[5.0]
  def up
    change_column :shows, :times, :string, array: true, default: []
  end
  def down
    change_column :shows, :times, :time, array: true, default: [s]
  end
end

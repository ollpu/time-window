class AddLiveToShows < ActiveRecord::Migration[5.0]
  def change
    add_column :shows, :live, :boolean
  end
end

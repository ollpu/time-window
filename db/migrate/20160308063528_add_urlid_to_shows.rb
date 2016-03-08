class AddUrlidToShows < ActiveRecord::Migration[5.0]
  def change
    add_column :shows, :urlid, :string
  end
end

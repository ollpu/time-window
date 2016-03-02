class CreateShows < ActiveRecord::Migration[5.0]
  def change
    create_table :shows do |t|
      t.string :title
      t.string :names, array: true, default: []
      t.time :times, array: true, default: []

      t.timestamps
    end
  end
end

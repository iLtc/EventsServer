class CreateEvents < ActiveRecord::Migration[5.1]
  def change
    create_table :events do |t|
      t.string :eid
      t.string :title
      t.text :url
      t.string :first_date
      t.string :last_date
      t.text :location
      t.text :description
      t.text :photo
      t.text :geo
      t.text :categories

      t.timestamps
    end
  end
end

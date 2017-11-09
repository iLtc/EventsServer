class ChangeDateFormatInEvent < ActiveRecord::Migration[5.1]
  def change
    remove_column :events, :first_date
    add_column :events, :first_date, :datetime
  end
end

class ChangeDateFormatInEvent < ActiveRecord::Migration[5.1]
  def change
    change_column :events, :first_date, :datetime
  end
end

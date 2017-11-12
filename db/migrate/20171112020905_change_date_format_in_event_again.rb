class ChangeDateFormatInEventAgain < ActiveRecord::Migration[5.1]
  def change
    remove_column :events, :last_date
    add_column :events, :last_date, :datetime
  end
end

class AddViewsToEvents < ActiveRecord::Migration[5.1]
  def change
    add_column :events, :views, :integer
  end
end

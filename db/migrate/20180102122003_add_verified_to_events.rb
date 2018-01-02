class AddVerifiedToEvents < ActiveRecord::Migration[5.1]
  def change
    add_column :events, :verified, :boolean, default: false
  end
end

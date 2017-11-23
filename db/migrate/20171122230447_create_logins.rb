class CreateLogins < ActiveRecord::Migration[5.1]
  def change
    create_table :logins do |t|
      t.belongs_to :user, index: true
      t.string :pid
      t.string :platform

      t.timestamps
    end
  end
end

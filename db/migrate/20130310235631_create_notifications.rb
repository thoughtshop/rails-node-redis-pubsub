class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.string :message

      t.timestamps
    end
  end
end

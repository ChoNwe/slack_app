class CreateTDirectMsgs < ActiveRecord::Migration[5.2]
  def change
    create_table :t_direct_msgs do |t|
      t.integer :sender_id
      t.integer :receiver_id
      t.string :message
      t.boolean :unread

      t.timestamps
    end
  end
end

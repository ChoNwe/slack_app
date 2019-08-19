class CreateTChannelUnreadMsgs < ActiveRecord::Migration[5.2]
  def change
    create_table :t_channel_unread_msgs do |t|
      t.integer :channel_msg_id
      t.integer :unread_user_id
      t.boolean :unread

      t.timestamps
    end
  end
end

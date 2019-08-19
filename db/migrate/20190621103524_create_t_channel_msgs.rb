class CreateTChannelMsgs < ActiveRecord::Migration[5.2]
  def change
    create_table :t_channel_msgs do |t|
      t.integer :channel_id
      t.integer :sender_id
      t.string :channel_msg
      t.integer :replier_id
      t.integer :parent_msg_id
      t.string :thread_msg

      t.timestamps
    end
  end
end

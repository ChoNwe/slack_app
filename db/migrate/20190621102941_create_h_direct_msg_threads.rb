class CreateHDirectMsgThreads < ActiveRecord::Migration[5.2]
  def change
    create_table :h_direct_msg_threads do |t|
      t.integer :dir_msg_id
      t.integer :user_id
      t.string :thread_msg
      t.boolean :unread

      t.timestamps
    end
  end
end

class AddWorkspaceToTDirectMsgs < ActiveRecord::Migration[5.2]
  def change
    add_column :t_direct_msgs, :workspace_id, :integer
  end
end

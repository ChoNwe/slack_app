class CreateMWorkspaces < ActiveRecord::Migration[5.2]
  def change
    create_table :m_workspaces, :id => false do |t|
      t.integer :user_id, :null => false
      t.string :workspace_name
      t.boolean :admin

      t.timestamps
    end
    add_index :m_workspaces, [:id, :user_id], :unique => true
    add_index :m_workspaces, :id
    add_index :m_workspaces, :user_id
  end
end

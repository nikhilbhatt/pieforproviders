class ChangeApprovalsToCases < ActiveRecord::Migration[6.1]
  def change
    rename_column :child_approval, :approval_id, :case_id
    rename_table :approvals, :cases
  end
end

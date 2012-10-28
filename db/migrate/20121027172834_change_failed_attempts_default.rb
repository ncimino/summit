class ChangeFailedAttemptsDefault < ActiveRecord::Migration
  def change
    change_column_default(:users, :failed_attempts, 21)
  end
end

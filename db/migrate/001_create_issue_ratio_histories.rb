class CreateIssueRatioHistories < ActiveRecord::Migration
  def self.up
    create_table :issue_ratio_histories do |t|
      t.references :issue, :null => false
      t.integer :done_ratio, :null => false
      t.date :created_at
    end
  end

  def self.down
    drop_table :issue_ratio_histories
  end
end

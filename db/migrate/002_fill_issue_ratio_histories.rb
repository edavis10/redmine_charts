class FillIssueRatioHistories < ActiveRecord::Migration
  def self.up
    Issue.all(:conditions => ["estimated_hours > 0 and done_ratio > 0"], :include => [:time_entries]).each do |issue|
      logged_hours = issue.time_entries.sum(:hours)
      entries = issue.time_entries.all(:select => "spent_on, sum(hours) hours, #{issue.done_ratio}*sum(hours)/#{logged_hours} ratio", :group => "spent_on", :order => "spent_on asc")
      ratio = 0
      entries.each do |entry|
        ratio += entry.ratio.to_i
        IssueRatioHistory.create!(:issue => issue, :done_ratio => ratio, :created_at => entry.spent_on.to_time) if ratio > 0
      end
    end
  end

  def self.down
    IssueRatioHistory.delete_all
  end
end

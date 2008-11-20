class IssueRatioHistory < ActiveRecord::Base

  belongs_to :issue
  
  def created_at=(created_at)
    write_attribute(:created_at, created_at)
  end

end

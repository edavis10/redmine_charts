require_dependency 'issue'

module IssuePatch

  def self.included(base)
    base.class_eval do
      unloadable

      has_many :issue_ratio_histories

      alias_method :old_after_save, :after_save      

      def after_save
        old_after_save

        history = IssueRatioHistory.find(:last, :conditions => {:issue_id => self.id}, :order => "created_at")

        if history
          unless history.done_ratio == self.done_ratio
            if history.created_at == Date.current
              history.done_ratio = self.done_ratio
            else
              history = IssueRatioHistory.create(:issue_id => self.id, :done_ratio => self.done_ratio)
            end
            history.save
          end
        elsif self.done_ratio > 0
          history = IssueRatioHistory.create(:issue_id => self.id, :done_ratio => self.done_ratio)          
          history.save
        end
     
        true
      end

    end
  end
end

Issue.send(:include, IssuePatch)


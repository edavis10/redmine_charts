module RedmineCharts
  module GroupingUtils

    include GLoc

    @@types = [ :users, :issues, :activities, :categories ]

    def self.default_types
      @@types
    end

    def self.from_params(params)
      if params[:grouping].blank? or not default_types.include?(params[:grouping].to_sym)
        nil
      else
         params[:grouping].to_sym
      end
    end
    
    def self.to_options(options)
      options.collect { |i| [l("charts_group_by_#{i}".to_sym), i]  }
    end

    def self.to_string(id, grouping, default = nil)
      if grouping == :categories and category = IssueCategory.find_by_id(id.to_i)
        category.name.capitalize
      elsif grouping == :users and user = User.find_by_id(id.to_i)
        user.login.capitalize
      elsif grouping == :issues and issue = Issue.find_by_id(id.to_i)
        issue.subject.capitalize
      elsif grouping == :activities and activity = Enumeration.find_by_id(id.to_i)
        activity.name.capitalize
      elsif default
        default
      else
        id
      end
    end

  end
end

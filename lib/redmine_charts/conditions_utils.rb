module RedmineCharts
  module ConditionsUtils

    include GLoc

    @@default_types = [ :user_id, :issue_id, :activity_id, "issues.category_id".to_sym ]

    def self.default_types
      @@default_types
    end

    def self.from_params(params, options)
      conditions = {:project_id => Project.find(params[:project_id]).id}
      options.each do |k|
        t = params["conditions_#{k.to_s}".to_sym].blank? ? nil : Integer(params["conditions_#{k.to_s}".to_sym])
        conditions[k] = t if t and t > 0
      end   
      conditions
    end

    def self.to_options(options, project_id)
      options.collect do |i|
        case i
        when :user_id then [:user_id, Project.find(project_id).assignable_users.collect { |u| [u.login, u.id] }.unshift([l(:charts_condition_all), 0])]
        when :issue_id then [:issue_id, nil]
        when :activity_id then [:activity_id, Enumeration.get_values("ACTI").collect { |a| [a.name.downcase, a.id] }.unshift([l(:charts_condition_all), 0])]
        when "issues.category_id".to_sym then ["issues.category_id".to_sym, IssueCategory.find_all_by_project_id(Project.find(project_id).id).collect { |c| [c.name.downcase, c.id] }.unshift([l(:charts_condition_all), 0])]
        end
      end
    end

  end
end

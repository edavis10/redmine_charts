module RedmineCharts
  module ConditionsUtils

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

  end
end

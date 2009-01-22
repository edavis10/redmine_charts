class ChartsBurndownController < ChartsController

  unloadable
  
  protected

  def get_data(conditions, grouping, range)
    prepare_ranged = RedmineCharts::RangeUtils.prepare_range(range, "start_date")

    estimated = []
    logged = []
    remaining = []
    predicted = []
    done = []
    max = 0

    conditions_sql = "project_id = ? and (start_date <= ? or (start_date is null and created_on <= ?))"

    prepare_ranged[:dates].each_with_index do |date,i|
      hours = Issue.sum(:estimated_hours, :conditions => [conditions_sql, conditions[:project_id], date[1], date[1]])
      estimated[i] = [hours, l(:charts_burndown_hint_estimated, hours)]
      max = hours if max < hours
    end

    prepare_ranged[:dates].each_with_index do |date,i|
      hours = TimeEntry.sum(:hours, :conditions => ["project_id = ? and spent_on <= ?", conditions[:project_id], date[1]])
      logged[i] = [hours, l(:charts_burndown_hint_logged, hours)]
      max = hours if max < hours
    end

    prepare_ranged[:dates].each_with_index do |date,i|
      hours = estimated[i][0]
      issues = Issue.find(:all, :conditions => [conditions_sql, conditions[:project_id], date[1], date[1]])
      total_ratio = 0
      issues.each do |issue|
        journal = issue.journals.find(:first, :conditions => ["created_on <= ?", date[1]], :order => "created_on desc", :select => "journal_details.value", :joins => "left join journal_details on journal_details.journal_id = journals.id and journal_details.prop_key = 'done_ratio'")
        ratio = journal ? journal.value.to_i : 0
        total_ratio += ratio
        hours -= issue.estimated_hours.to_f * ratio.to_f / 100 if issue.estimated_hours
      end
      done[i] = issues.size > 0 ? Integer(total_ratio/issues.size) : 0
      remaining[i] = [hours, l(:charts_burndown_hint_remaining, hours, done[i])]
    end

    prepare_ranged[:dates].each_with_index do |date,i|
      hours = logged[i][0] + remaining[i][0]
      if hours > estimated[i][0]
        predicted[i] = [hours, l(:charts_burndown_hint_predicted_over_estimation, hours, hours - estimated[i][0], prepare_ranged[:labels][i]), true]
      else
        predicted[i] = [hours, l(:charts_burndown_hint_predicted, hours)]
      end
      max = hours if max < hours
    end

    sets = [
      [l(:charts_burndown_group_estimated), estimated],
      [l(:charts_burndown_group_logged), logged],
      [l(:charts_burndown_group_remaining), remaining],
      [l(:charts_burndown_group_predicted), predicted],
    ]

    {
      :labels => prepare_ranged[:labels],
      :count => prepare_ranged[:steps],
      :max => max,
      :sets => sets
    }
  end

  def get_title
    l(:charts_link_burndown)
  end
  
  def get_help
    l(:charts_burndown_help)
  end
  
  def get_x_legend
    l(:charts_burndown_x)
  end
  
  def get_y_legend
    l(:charts_burndown_y)
  end
  
  def show_x_axis
    true
  end
  
  def show_y_axis
    true
  end
  
  def show_date_condition
    true
  end
  
  def get_grouping_options
    []
  end
  
  def get_conditions_options
    []
  end
  
end

class ChartsBurndownController < ChartsController

  unloadable
  
  protected

  def get_title
    l(:charts_link_burndown)
  end
  
  def get_help
    l(:charts_burndown_help)
  end
  
  def get_type
    "line"
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
  
  def show_conditions
    false
  end
  
  def show_date_condition
    false
  end
  
  def get_grouping_options
    []
  end
  
  def get_conditions_options
    []
  end

  def get_data(conditions, grouping, range)

    first_date = Date.current
    f = Issue.minimum(:start_date, :conditions => { :project_id => conditions[:project_id]})
    first_date = f if f < first_date
    f = Issue.minimum(:created_on, :conditions => { :project_id => conditions[:project_id]})
    first_date = f if f < first_date
    
    range = count_range({:in => :days, :offset => 1}, first_date.to_time)
    
    from, to, x_labels, x_count, range, dates = prepare_range(range, "start_date")

    estimated = []
    logged = []
    remaining = []
    predicted = []
    done = []
    y_max = 0
    
    conditions_sql = "project_id = ? and (start_date <= ? or (start_date is null and created_on <= ?))"
    
    dates.each_with_index do |date,i|
      hours = Issue.sum(:estimated_hours, :conditions => [conditions_sql, conditions[:project_id], date, date])
      estimated[i] = [hours, l(:charts_burndown_hint_estimated, hours)]
      y_max = hours if y_max < hours
    end
    
    dates.each_with_index do |date,i|
      hours = TimeEntry.sum(:hours, :conditions => ["project_id = ? and spent_on <= ?", conditions[:project_id], date])
      logged[i] = [hours, l(:charts_burndown_hint_logged, hours)]
      y_max = hours if y_max < hours
    end
    
    dates.each_with_index do |date,i|
      hours = estimated[i][0]
      issues = Issue.find(:all, :conditions => [conditions_sql, conditions[:project_id], date, date])
      total_ratio = 0
      issues.each do |issue|
        journal = issue.journals.find(:first, :conditions => ["created_on <= ?", date], :order => "created_on desc", :select => "journal_details.value", :joins => "left join journal_details on journal_details.journal_id = journals.id and journal_details.prop_key = 'done_ratio'")
        ratio = journal ? journal.value.to_i : 0
        total_ratio += ratio
        hours -= issue.estimated_hours.to_f * ratio.to_f / 100 if issue.estimated_hours
      end
      done[i] = issues.count > 0 ? Integer(total_ratio/issues.count) : 0
      remaining[i] = [hours, l(:charts_burndown_hint_remaining, hours, done[i])]        
    end
    
    dates.each_with_index do |date,i|
      hours = logged[i][0] + remaining[i][0]
      if hours > estimated[i][0]
        predicted[i] = [hours, l(:charts_burndown_hint_predicted_over_estimation, hours, hours - estimated[i][0], x_labels[i]), true]
      else
        predicted[i] = [hours, l(:charts_burndown_hint_predicted, hours)]
      end
      y_max = hours if y_max < hours
    end
    
    sets = {
      l(:charts_burndown_group_estimated) => estimated,
      l(:charts_burndown_group_logged) => logged,
      l(:charts_burndown_group_remaining) => remaining,
      l(:charts_burndown_group_predicted) => predicted,      
    }
  
    [x_labels, x_count, y_max, sets]
  end
    
end

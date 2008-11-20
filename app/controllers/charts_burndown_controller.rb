class ChartsBurndownController < ChartsController

  unloadable
  
  protected

  def get_title
    l(:charts_link_burndown)
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

  def get_data(conditions = {}, grouping = nil, range = {})

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
    y_max = 0
    
    conditions_sql = "project_id = ? and (start_date <= ? or (start_date is null and created_on <= ?))"
    
    dates.each_with_index do |date,i|
      hours = Issue.sum(:estimated_hours, :conditions => [conditions_sql, conditions[:project_id], date, date])
      estimated[i] = [hours, l(:charts_burndown_hint, hours, x_labels[i])]
      y_max = hours if y_max < hours
    end
    
    dates.each_with_index do |date,i|
      hours = TimeEntry.sum(:hours, :conditions => ["project_id = ? and spent_on <= ?", conditions[:project_id], date])
      logged[i] = [hours, l(:charts_burndown_hint, hours, x_labels[i])]
      y_max = hours if y_max < hours
    end
    
    dates.each_with_index do |date,i|
      hours = estimated[i][0]
      issues = Issue.find(:all, :conditions => [conditions_sql, conditions[:project_id], date, date])
      issues.each do |issue|
        history = IssueRatioHistory.first(:conditions => ["issue_id = ? and created_at <= ?", issue.id, date], :order => "created_at desc")
        ratio = history ? history.done_ratio : 0
        hours -= issue.estimated_hours.to_f * ratio.to_f / 100 if issue.estimated_hours
      end
      remaining[i] = [hours, l(:charts_burndown_hint, hours, x_labels[i])]        
    end
    
    sets = {
      l(:charts_burndown_group_estimated) => estimated,
      l(:charts_burndown_group_logged) => logged,
      l(:charts_burndown_group_remaining) => remaining,
    }
  
    [x_labels, x_count, y_max, sets]
  end
    
end

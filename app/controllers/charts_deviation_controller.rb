class ChartsDeviationController < ChartsController

  unloadable
  
  protected

  def get_data(conditions, grouping, range)

    conditions = ["issues.estimated_hours > 0"]

    joins = "left join time_entries on issues.id = time_entries.issue_id"
    group = "issues.id, issues.subject, issues.done_ratio, issues.estimated_hours"
    select = "#{group}, sum(time_entries.hours) as logged_hours"
    
    rows = Issue.find(:all, :conditions => conditions, :joins => joins, :select => select, :readonly => true, :group => group)

    labels = []
    max = 0

    total_logged_hours = 0
    total_estimated_hours = 0
    total_remaining_hours = 0
    total_done_ratio = 0
    total_remaining_ratio = 0
    total_logged_ratio = 0

    logged_values = []
    remaining_values = []
    
    rows.each_with_index do |row,index|
      remaining_value = nil
      logged_value = nil

      labels << l(:charts_deviation_label, row.id)

      logged_ratio = get_logged_ratio(row.logged_hours, row.estimated_hours)

      # Ratio of remaining hours.
      if row.done_ratio == 100
        # Everything is done.
        remaining_ratio = 0
        remaining_hours = 0
      elsif row.done_ratio == 0
        # None is done.
        remaining_ratio = 100
        remaining_hours = row.estimated_hours
      else
        remaining_ratio = get_remaining_ratio(logged_ratio, row.done_ratio)
        remaining_hours = get_remaining_hours(row.logged_hours, row.estimated_hours, logged_ratio, remaining_ratio)
      end

      if logged_ratio > 0
        hint = get_logged_hint(logged_ratio, remaining_ratio, row.done_ratio, row.logged_hours, row.estimated_hours, row)
        logged_value = [logged_ratio, hint]
      end

      if remaining_ratio > 0
        hint = get_remaining_hint(logged_ratio, remaining_ratio, row.done_ratio, row.logged_hours, remaining_hours, row.estimated_hours, row)
        remaining_value = [remaining_ratio, hint]
      end

      if remaining_value or logged_value
        logged_values << logged_value
        remaining_values << remaining_value
        total_logged_hours += row.logged_hours.to_i
        total_estimated_hours += row.estimated_hours.to_i
        total_logged_ratio += logged_ratio
        total_remaining_hours += remaining_hours
        total_remaining_ratio += remaining_ratio
        total_done_ratio += row.done_ratio.to_i       
        max = remaining_ratio + logged_ratio if max < remaining_ratio + logged_ratio
      else
        labels.delete_at(index)
      end
    end

    # Project logged and remaining ratio.
    if labels.size > 0
      project_done_ratio = total_done_ratio.to_f/labels.size
      project_logged_ratio = total_logged_ratio.to_f/labels.size
      project_remaining_ratio = total_remaining_ratio.to_f/labels.size
    else
      project_done_ratio = 0
      project_logged_ratio = 0
      project_remaining_ratio = 0
    end

    hint = get_logged_hint(project_logged_ratio, project_remaining_ratio, project_done_ratio, total_logged_hours, total_estimated_hours)
    project_logged_value = [project_logged_ratio, hint]

    hint = get_remaining_hint(project_logged_ratio, project_remaining_ratio, project_done_ratio, total_logged_hours, total_remaining_hours, total_estimated_hours)
    project_remaining_value = [project_remaining_ratio, hint]

    labels.unshift(l(:charts_deviation_project_label))
    logged_values.unshift(project_logged_value)
    remaining_values.unshift(project_remaining_value)

    sets = [
      [l(:charts_deviation_group_logged), logged_values],
      [l(:charts_deviation_group_remaining), remaining_values]
    ]

    {
      :labels => labels,
      :count => labels.size,
      :max => max,
      :sets => sets,
      :horizontal_line => 100
    }
  end

  def get_title
    l(:charts_link_deviation)
  end
  
  def get_help
    l(:charts_deviation_help)
  end
  
  def get_type
    :stack
  end
  
  def get_x_legend
    l(:charts_deviation_x)
  end
  
  def get_y_legend
    l(:charts_deviation_y)
  end
  
  def show_x_axis
    true
  end

  def get_x_axis_labels
    0
  end
  
  def show_y_axis
    true
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

  private

  # Ratio of logged to estimated hours.
  #
  # Logged hours: 4h
  # Estimated hours: 10h
  # Logged ratio: 4/10*100 = 40
  #
  def get_logged_ratio(logged_hours, estimated_hours)
    Integer(logged_hours.to_f/estimated_hours.to_f*100)
  end

  # Ratio of remaining hours depending on logged hours.
  #
  # Done ratio: 40% (logged by users)
  # Logged ratio: 20% (counted above)
  # Remaining ratio: 20/40*(100-40) = 120 = 60
  #
  def get_remaining_ratio(logged_ratio, done_ratio)
    if logged_ratio > 0
      Integer(logged_ratio.to_f/done_ratio.to_f*(100-done_ratio))
    else
      Integer(100-done_ratio)
    end
  end

  # Number of remaining hours depending on logged hours.
  #
  # Logged hours: 4h
  # Logged ratio: 20% (counted above)
  # Remaining ratio: 20/40*(100-40) = 120 = 60
  # Remaining hours: 4/20*120 = 24
  #
  def get_remaining_hours(logged_hours, estimated_hours, logged_ratio, remaining_ratio)
    if logged_ratio > 0
      remaining_hours = Integer(logged_hours.to_f/logged_ratio.to_f*remaining_ratio)
    else
      remaining_hours = Integer(estimated_hours.to_f*remaining_ratio/100)
    end
    remaining_hours += 1 if remaining_hours == 0
    remaining_hours
  end

  def get_remaining_hint(logged_ratio, remaining_ratio, done_ratio, logged_hours, remaining_hours, estimated_hours, row = nil)
    if logged_ratio + remaining_ratio > 100 # Issue is delayed.
      hint = l(:charts_deviation_hint_remaining_over_estimation, remaining_hours, logged_hours.to_i+remaining_hours.to_i-estimated_hours.to_i, logged_ratio + remaining_ratio - 100)
    else
      hint = l(:charts_deviation_hint_remaining, remaining_hours)
    end
    hint << l(:charts_deviation_hint_issue, estimated_hours, done_ratio)
    if row
      hint << l(:charts_deviation_hint_label, row.id, row.subject)
    else
      hint << l(:charts_deviation_hint_project_label)
    end
    hint
  end

  def get_logged_hint(logged_ratio, remaining_ratio, done_ratio, logged_hours, estimated_hours, row = nil)
    if logged_ratio > 100 and remaining_ratio == 0 # Issue is finished.
      hint = l(:charts_deviation_hint_logged_over_estimation, logged_hours.to_i, logged_hours.to_i-estimated_hours.to_i, logged_ratio - 100)
    else
      hint = l(:charts_deviation_hint_logged, logged_hours.to_i)
    end
    hint << l(:charts_deviation_hint_issue, estimated_hours, done_ratio)
    if row
      hint << l(:charts_deviation_hint_label, row.id, row.subject)
    else
      hint << l(:charts_deviation_hint_project_label)
    end
    hint
  end

end

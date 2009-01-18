class ChartsDeviationController < ChartsController

  unloadable
  
  protected

  def get_data(conditions, grouping, range)

    rows = Issue.find(:all, :conditions => ["issues.estimated_hours > 0"], :joins => "left join time_entries on issues.id = time_entries.issue_id", :select => "issues.id, issues.subject, issues.done_ratio, issues.estimated_hours, sum(time_entries.hours) as logged_hours", :readonly => true, :group => "issues.id, issues.subject, issues.done_ratio, issues.estimated_hours")

    labbels = []
    max = 0
    logged_values = []
    remaining_values = []
    sets = []

    rows.each_with_index do |row,i|
      remaining_value = nil
      logged_value = nil

      labbels << l(:charts_deviation_hint_label, row.id, row.subject)
      logged = Integer(row.logged_hours.to_f/row.estimated_hours.to_f*100)
      if row.done_ratio == 100
        remaining = 0
        remaining_hours = 0
      elsif logged == 0 or row.done_ratio == 0
        remaining = 100
        remaining_hours = row.estimated_hours
      else
        remaining = Integer(logged.to_f/row.done_ratio.to_f*(100-row.done_ratio))
        remaining_hours = Integer(row.logged_hours.to_f/row.done_ratio.to_f*(100-row.done_ratio))
      end
      if logged > 0
        if logged > 100 and remaining == 0
          logged_value = [logged, l(:charts_deviation_hint_logged_over_estimation, row.logged_hours.to_i, row.logged_hours.to_i-row.estimated_hours.to_i, logged - 100) << l(:charts_deviation_hint_issue, row.estimated_hours, row.done_ratio)]
        else
          logged_value = [logged, l(:charts_deviation_hint_logged, row.logged_hours.to_i) << l(:charts_deviation_hint_issue, row.estimated_hours, row.done_ratio)]
        end
      end
      if remaining > 0
        if logged + remaining > 100
          remaining_value = [remaining, l(:charts_deviation_hint_remaining_over_estimation, remaining_hours, row.logged_hours.to_i+remaining_hours.to_i-row.estimated_hours.to_i, logged + remaining - 100) << l(:charts_deviation_hint_issue, row.estimated_hours, row.done_ratio)]
        else
          remaining_value = [remaining, l(:charts_deviation_hint_remaining, remaining_hours) << l(:charts_deviation_hint_issue, row.estimated_hours, row.done_ratio)]
        end
      end
      if remaining_value or logged_value
        logged_values << logged_value
        remaining_values << remaining_value
        max = remaining + logged if max < remaining + logged
      end
    end

    sets << [l(:charts_deviation_group_logged), logged_values]
    sets << [l(:charts_deviation_group_remaining), remaining_values]

    [labbels, rows.size, max, sets]
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
    false
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
  
end

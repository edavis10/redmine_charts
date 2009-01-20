class ChartsDeviationController < ChartsController

  unloadable
  
  protected

  def get_data(conditions, grouping, range)

    conditions = ["issues.estimated_hours > 0"]
    joins = "left join time_entries on issues.id = time_entries.issue_id"
    select = "issues.id, issues.subject, issues.done_ratio, issues.estimated_hours, sum(time_entries.hours) as logged_hours"
    group = "issues.id, issues.subject, issues.done_ratio, issues.estimated_hours"

    rows = Issue.find(:all, :conditions => conditions, :joins => joins, :select => select, :readonly => true, :group => group)

    labels = []
    max = 0
    logged_values = []
    remaining_values = []
    sets = []

    rows.each_with_index do |row,index|
      remaining_value = nil
      logged_value = nil

      labels << l(:charts_deviation_label, row.id)

      # Ratio of logged to estimated hours.
      #
      # Logged hours: 4h
      # Estimated hours: 10h
      # Logged ratio: 4/10*100 = 40
      #
      logged_ratio = Integer(row.logged_hours.to_f/row.estimated_hours.to_f*100)

      # Ratio of remaining hours.
      if row.done_ratio == 100
        # Everything is done.
        remaining_ratio = 0
        remaining_hours = 0
      elsif logged_ratio == 0 or row.done_ratio == 0
        # None is done.
        remaining_ratio = 100
        remaining_hours = row.estimated_hours
      else
        # Ratio of remaining hours depending on logged hours.
        #
        # Estimated hours: 10h
        # Logged hours: 4h
        # Done ratio: 40% (logged by users)
        # Logged ratio: 20% (counted above)
        # Remaining ratio: 20/40*(100-40) = 120 = 60
        # Remaining hours: 4/20*120 = 24
        #
        remaining_ratio = Integer(logged_ratio.to_f/row.done_ratio.to_f*(100-row.done_ratio))
        remaining_hours = Integer(row.logged_hours.to_f/logged_ratio.to_f*remaining_ratio) + 1
      end

      if logged_ratio > 0
        if logged_ratio > 100 and remaining_ratio == 0 # Issue is finished.
          hint = l(:charts_deviation_hint_logged_over_estimation, row.logged_hours.to_i, row.logged_hours.to_i-row.estimated_hours.to_i, logged_ratio - 100)
        else
          hint = l(:charts_deviation_hint_logged, row.logged_hours.to_i)
        end
        hint << l(:charts_deviation_hint_issue, row.estimated_hours, row.done_ratio)
        hint << l(:charts_deviation_hint_label, row.id, row.subject)
        logged_value = [logged_ratio, hint]
      end

      if remaining_ratio > 0
        if logged_ratio + remaining_ratio > 100 # Issue is delayed.
          hint = l(:charts_deviation_hint_remaining_over_estimation, remaining_hours, row.logged_hours.to_i+remaining_hours.to_i-row.estimated_hours.to_i, logged_ratio + remaining_ratio - 100)
        else
          hint = l(:charts_deviation_hint_remaining, remaining_hours)
        end
        hint << l(:charts_deviation_hint_issue, row.estimated_hours, row.done_ratio)
        hint << l(:charts_deviation_hint_label, row.id, row.subject)
        remaining_value = [remaining_ratio, hint]
      end

      if remaining_value or logged_value
        logged_values << logged_value
        remaining_values << remaining_value
        max = remaining_ratio + logged_ratio if max < remaining_ratio + logged_ratio
      else
        labels.delete_at(index)
      end
    end

    sets << [l(:charts_deviation_group_logged), logged_values]
    sets << [l(:charts_deviation_group_remaining), remaining_values]

    [labels, labels.size, max, sets]
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

  def get_x_axis_steps
    1
  end

end

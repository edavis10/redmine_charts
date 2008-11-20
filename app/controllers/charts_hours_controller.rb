class ChartsHoursController < ChartsController

  unloadable
  
  protected

  def get_title
    l(:charts_link_hours)
  end
  
  def get_type
    "line"
  end
  
  def get_x_legend
    l(:charts_hours_x)
  end
  
  def get_y_legend
    l(:charts_hours_y)
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
    [ :none, :users, :issues, :activities, :categories ]
  end

  def get_hints(record = nil, grouping = nil)
    unless record.nil?
      l(:charts_hours_hint, record.value_y.to_i, record.count_y.to_i)
    else
      l(:charts_hours_hint_empty)
    end
  end
  
  def get_data(conditions = {}, grouping = nil, range = {})

    unless range[:steps] and range[:steps] > 0 and range[:offset]
        first = TimeEntry.find(:first, :conditions => conditions, :order => :spent_on)
        range = count_range(range, first.spent_on) if first
    end
    
    from, to, x_labels, x_count, range, dates = prepare_range(range, "spent_on")

    conditions[:spent_on] = (from.to_date)...(to.to_date)

    group = []
    group << range
    group << "user_id" if grouping == :users
    group << "issue_id" if grouping == :issues
    group << "project_id" if grouping == :projects
    group << "activity_id" if grouping == :activities  
    group << "issues.category_id" if grouping == :categories
    group = group.join(", ")
  
    select = []
    select << "#{range} value_x"
    select << "count(1) count_y"
    select << "sum(hours) value_y"
    select << "user_id group_id" if grouping == :users
    select << "issue_id group_id" if grouping == :issues
    select << "project_id group_id" if grouping == :projects
    select << "activity_id group_id" if grouping == :activities
    select << "issues.category_id group_id" if grouping == :categories
    select << "0 group_id" if grouping.nil? or grouping == :none
    select = select.join(", ")
  
    rows = TimeEntry.find(:all, :joins => "left join issues on issues.id = issue_id", :select => select, :conditions => conditions, :order => :spent_on, :readonly => true, :group => group)
  
    y_max, sets = get_sets(rows, grouping, x_count)
    
    [x_labels, x_count, y_max, sets]
  end
    
end

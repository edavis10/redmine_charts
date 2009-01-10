class ChartsGroupsController < ChartsController

  unloadable
  
  protected

  def get_data(conditions, grouping, range)
    grouping ||= :users

    group = case grouping
    when :users then "user_id"
    when :issues then "issue_id"
    when :activities then "activity_id"
    when :categories then "issues.category_id"
    end

    select = []
    select << "null as value_x"
    select << "sum(hours) as value_y"
    select << "#{group} as group_id"
    select = select.join(", ")

    rows = TimeEntry.find(:all, :joins => "left join issues on issues.id = issue_id", :select => select, :conditions => conditions, :readonly => true, :group => group, :order => "sum(hours) desc")

    sets = []
    total = 0
    other = 0
    other_no = 0

    rows.each do |row|
      total += row.value_y.to_i
    end

    rows.reverse.each do |row|
      if ((other + row.value_y.to_f)/total) < 0.05
        other += row.value_y.to_i
        other_no += 1
      else
        sets << row
      end
    end

    if other_no > 1
      rows = sets
      o = Struct.new(:value_x, :value_y, :group_id).new
      o.value_x = nil
      o.value_y = other
      o.group_id = 0
      rows << o
    end

    y_max, sets = get_sets(rows, grouping, rows.size, true)

    [nil, rows.size, y_max, sets]
  end

  def get_hints(record = nil, grouping = nil)
    unless record.nil?
      if record.group_id.to_i > 0
        l(:charts_groups_hint, group_id_to_string(record.group_id, grouping))
      else
        l(:charts_groups_hint_others)
      end
    else
      ""
    end
  end

  def get_title
    l(:charts_link_groups)
  end
  
  def get_help
    l(:charts_groups_help)
  end
  
  def get_type
    "pie"
  end
  
  def get_global_hints
    l(:charts_groups_global_hint)    
  end
  
end

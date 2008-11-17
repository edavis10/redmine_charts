class ChartsController < ApplicationController

  unloadable

  menu_item :charts

  before_filter :find_project, :only => [:index]
  
  Y_STEPS = 5
  
  COLORS = ['#DFC329', '#6363AC', '#5E4725', "#d01f3c", "#356aa0", "#C79810"]
  
  def index
    @graph = open_flash_chart_object("100%",400,"#{url_for(:action => nil)}/data_for_#{get_type.to_s}?#{params.to_param}",true,'/plugin_assets/open_flash_chart/')
    @grouping_options = get_grouping_options.collect { |i| [l("charts_group_by_#{i}".to_sym), i]  }
    @conditions_options = get_conditions_options.collect do |i|
      case i
      when :user_id then [:user_id, User.all.collect { |u| [u.login, u.id] }.unshift([l(:charts_condition_all), 0])]      
      when :issue_id then [:issue_id, nil]
      when :activity_id then [:activity_id, Enumeration.get_values("ACTI").collect { |a| [a.name.downcase, a.id] }.unshift([l(:charts_condition_all), 0])]
      end
    end
    @date_condition = show_date_condition
    @range_in_options = [:days, :weeks, :months].collect { |i| [l("charts_show_last_#{i}".to_sym), i]  }
    render :template => "charts/index"
  end

  def data_for_all
    chart =OpenFlashChart.new
    
    conditions, grouping, range = prepare_params
    
    x_labels, x_count, y_max, sets = get_data(conditions, grouping, range)
    
    sets.each do |name,values|
      yield(chart,name,values)
    end
    
    unless get_title.nil?
      title = Title.new(get_title)
      chart.set_title(title)
    end

    if show_y_axis
      y = YAxis.new
      y.set_range(0,y_max*1.2,y_max/Y_STEPS) if y_max
      chart.y_axis = y
    end

    if show_x_axis
      x = XAxis.new
      x.set_range(0,x_count,1) if x_count
      x.set_labels(x_labels) if x_labels
      chart.x_axis = x
    end

    unless get_x_legend.nil?
      x_legend = XLegend.new(get_x_legend)
      x_legend.set_style('{font-size: 13px}')
      chart.set_x_legend(x_legend)
    end
    
    unless get_x_legend.nil?
      y_legend = YLegend.new(get_y_legend)
      y_legend.set_style('{font-size: 13px}')
      chart.set_y_legend(y_legend)
    end
    
    render :text => chart.to_s
  end
  
  def data_for_line
    data_for_all do |chart,name,values|
      line = LineDot.new
      line.text = name
      line.width = 2
      line.colour = COLORS[i % COLORS.length]
      line.dot_size = 2
      
      vals = values.collect do |v|
        if v.is_a? Array
          d = DotValue.new(v[0], COLORS[i % COLORS.length])
          d.set_tooltip(v[1]) unless v[1].nil?
          d
        else
          v
        end
      end
      
      line.values = vals
      chart.add_element(line)
      i+=1
    end   
  end
  
  def data_for_pie
    data_for_all do |chart,name,values|
      pie = Pie.new
      pie.tooltip = get_global_hints
      pie.start_angle = 35
      pie.animate = true
      pie.colours = COLORS
      
      vals = values.collect do |v|
        if v.is_a? Array
          PieValue.new(v[0], v[1])
        else
          v
        end
      end
      
      pie.values = vals
      chart.add_element(pie)
    end    
  end
  
  protected
  
  def get_title
    nil
  end
  
  def get_data
    raise "overwrite it"
  end
  
  def get_global_hints
    nil
  end
  
  def get_hints
    nil
  end
  
  def get_type
    "line_dot"
  end
  
  def get_x_legend
    nil
  end
  
  def get_y_legend
    nil
  end
  
  def show_x_axis
    false
  end
  
  def show_y_axis
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
  
  def count_range(range, first)
    case range[:in]
    when :weeks
      strftime_i = "%W"
    when :months
      strftime_i = "%m"
    else
      strftime_i = "%j"
    end
    
    first = first.strftime(strftime_i).to_i + first.strftime('%Y').to_i
    now = Time.now.strftime(strftime_i).to_i + Time.now.strftime('%Y').to_i
    
    range[:steps] = now - first + 2
    range[:offset] = 1
    range
  end
  
  def prepare_range(range, column = "created_on")
    case range[:in]
    when :weeks
      strftime_i = "%W"
      strftime_f = "%Y-%W"
    when :months
      strftime_i = "%m"
      strftime_f = "%Y-%m"
    else
      strftime_i = "%j"
      strftime_f = "%Y-%m-%d"
    end

    from = times_ago(range[:steps],range[:offset],0,range[:in])
    to = times_ago(range[:steps],range[:offset]-1,0,range[:in])

    x_labels = []

    range[:steps].times do |i|
      x_labels[i] = times_ago(range[:steps],range[:offset],i,range[:in]).strftime(strftime_f)
    end

    diff = from.strftime(strftime_i).to_i + from.strftime('%Y').to_i      
    sql = "(strftime('#{strftime_i}', #{column}) + strftime('%Y', #{column}) - #{diff})"
    
    [from, to, x_labels, range[:steps], sql]
  end
  
  def get_sets(rows, grouping, x_count, flat = false)
    if rows.empty?
      [nil, {}]
    end
    
    sets = {}
    y_max = 0
    i = -1

    rows.each do |r|
      if flat
        group_name = ""
      else
        group_name = group_id_to_string(r.group_id, grouping)
      end
      sets[group_name] ||= Array.new(x_count, [0, get_hints])
      
      if r.value_x
        i = r.value_x.to_i
      else
        i += 1
      end
      
      sets[group_name][i] = [r.value_y.to_i, get_hints(r, grouping)]
      y_max = r.value_y.to_i if y_max < r.value_y.to_i
    end
    
    [y_max, sets]
  end
  
  def group_id_to_string(group_id, grouping)
    group_name = group_id
    group_name = User.find_by_id(group_id.to_i).login if grouping == :users
    group_name = Issue.find_by_id(group_id.to_i).subject if grouping == :issues
    group_name = Enumeration.find_by_id(group_id.to_i).name if grouping == :activities    
    group_name
  end

  private

  def find_project
    @project = Project.find(params[:project_id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end
  
  def prepare_params
    range = {:steps => 0, :offset => 1, :in => :weeks}
    range[:steps] = Integer(params[:range_steps]) unless params[:range_steps].blank?
    range[:offset] = Integer(params[:range_offset]) unless params[:range_offset].blank?
    range[:in] = params[:range_in].to_sym unless params[:range_in].blank?
    
    conditions = {:project_id => Project.find(params[:project_id]).id}
    get_conditions_options.each do |k|
      t = params["conditions_#{k.to_s}".to_sym].blank? ? nil :Integer(params["conditions_#{k.to_s}".to_sym])
      conditions[k] = t if t and t > 0
    end    
    
    grouping = params[:grouping].blank? ? nil : params[:grouping].to_sym
    
    [conditions, grouping, range]
  end
  
  def times_ago(steps, offset, i, type)
    ((steps*offset)-i-1).send(type).ago
  end

end

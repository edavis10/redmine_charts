class ChartsController < ApplicationController

  unloadable

  menu_item :charts

  before_filter :check_params

  before_filter :find_project, :authorize, :only => [:index]
  
  # Show main page with conditions form and chart
  def index
    if show_date_condition or not get_grouping_options.empty? or not get_conditions_options.empty?
      @grouping_options = get_grouping_options.collect { |i| [l("charts_group_by_#{i}".to_sym), i]  }
      @conditions_options = get_conditions_options.collect do |i|
        case i
        when :user_id then [:user_id, Project.find(params[:project_id]).assignable_users.collect { |u| [u.login, u.id] }.unshift([l(:charts_condition_all), 0])]      
        when :issue_id then [:issue_id, nil]
        when :activity_id then [:activity_id, Enumeration.get_values("ACTI").collect { |a| [a.name.downcase, a.id] }.unshift([l(:charts_condition_all), 0])]
        when "issues.category_id".to_sym then ["issues.category_id".to_sym, IssueCategory.find_all_by_project_id(Project.find(params[:project_id]).id).collect { |c| [c.name.downcase, c.id] }.unshift([l(:charts_condition_all), 0])]
        end
      end
      @date_condition = show_date_condition
      @show_conditions = true
    else
      @show_conditions = false
    end
    @help = get_help
    @title = get_title
    
    render :template => "charts/index"
  end

  # Return data for chart
  def data
    chart =OpenFlashChart.new

    range = RedmineCharts::RangeUtils.from_params(params)
    grouping = RedmineCharts::GroupingUtils.from_params(params)
    conditions = RedmineCharts::ConditionsUtils.from_params(params, get_conditions_options)

    x_labels, x_count, y_max, sets = get_data(conditions, grouping, range)

    index = 0

    converter = get_converter

    sets.each do |name,values|
      chart.add_element(converter.convert(index,name,values,x_labels))
      index += 1
    end
       
    if show_y_axis
      y = YAxis.new
      y.set_range(0,y_max*1.2,y_max/5) if y_max
      chart.y_axis = y
    end

    if show_x_axis
      x = XAxis.new
      x.set_range(0,x_count,1) if x_count
      if x_labels        
        labels = []         
        step = (x_labels.size/5).to_i
        step = 1 if step == 0
        x_labels.each_with_index do |l,i|          
          if i % step == 0
            labels << l
          else 
            labels << ""
          end
        end
        x.set_labels(labels) 
      end
      chart.x_axis = x
    else
      x = XAxis.new
      x.set_labels([""])
      chart.x_axis = x
    end

    unless get_x_legend.nil?
      x_legend = XLegend.new(get_x_legend)
      x_legend.set_style('{font-size: 12px}')
      chart.set_x_legend(x_legend)
    end
    
    unless get_x_legend.nil?
      y_legend = YLegend.new(get_y_legend)
      y_legend.set_style('{font-size: 12px}')
      chart.set_y_legend(y_legend)
    end

    chart.set_bg_colour('#ffffff');

    render :text => chart.to_s
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
        group_name = RedmineCharts::GroupingUtils.to_string(r.group_id, grouping)
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

  protected

  # Returns chart title
  def get_title
    nil
  end

  # Returns chart type: line, pie or stack
  def get_type
    "line"
  end

  # Returns help string, displayed above chart
  def get_help
    nil
  end

  # Returns data for chart
  def get_data(conditions, grouping, range)
    raise "overwrite it"
  end

  # Returns hints for given record and grouping type
  def get_hints(record, grouping)
    nil
  end

  # Returns Y legend
  def get_x_legend
    nil
  end

  # Returns Y legend
  def get_y_legend
    nil
  end

  # Returns true if X axis should be displayed
  def show_x_axis
    false
  end

  # Returns true if Y axis should be displayed
  def show_y_axis
    false
  end

  # Returns true if date condition should be displayed
  def show_date_condition
    false
  end

  # Returns values for grouping options
  def get_grouping_options
    RedmineCharts::GroupingUtils.default_types
  end

  # Returns type of conditions available for that chart
  def get_conditions_options
    RedmineCharts::ConditionsUtils.default_types
  end

  private

  def get_converter
    eval("RedmineCharts::#{get_type.to_s.camelize}DataConverter")
  end

  # Find current project or raise 404
  def find_project
    @project = Project.find(params[:project_id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def check_params
    RedmineCharts::RangeUtils.set_params(params)
  end

end

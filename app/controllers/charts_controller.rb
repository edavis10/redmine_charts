class ChartsController < ApplicationController

  unloadable

  menu_item :charts

  before_filter :check_params

  before_filter :find_project, :authorize, :only => [:index]
  
  # Show main page with conditions form and chart
  def index
    @title = get_title

    @show_conditions = false

    if show_date_condition
      @date_condition = true
      @show_conditions = true
    else
      @date_condition = false
    end

    unless get_grouping_options.empty?
      @grouping_options = RedmineCharts::GroupingUtils.to_options(get_grouping_options)
      @show_conditions = true
    else
      @grouping_options = []
    end

    unless get_conditions_options.empty?
      @conditions_options = RedmineCharts::ConditionsUtils.to_options(get_conditions_options, params[:project_id])
      @show_conditions = true
    else
      @conditions_options = []
    end

    @show_left_column = @show_conditions

    unless get_help.blank?
      @help = get_help
      @show_left_column = true
    else
      @help = nil
    end
    
    render :template => "charts/index"
  end

  # Return data for chart
  def data
    chart =OpenFlashChart.new

    range = RedmineCharts::RangeUtils.from_params(params)
    grouping = RedmineCharts::GroupingUtils.from_params(params)
    conditions = RedmineCharts::ConditionsUtils.from_params(params, get_conditions_options)

    labels, count, max, sets = get_data(conditions, grouping, range)

    get_converter.convert(chart, sets, labels)
   
    if show_y_axis
      y = YAxis.new
      y.set_range(0,max*1.2,max/get_y_axis_steps) if max
      chart.y_axis = y
    end

    if show_x_axis
      x = XAxis.new
      x.set_range(0,count,1) if count
      if labels
        labels2 = []
        labels.each_with_index do |l,i|
          if i % get_x_axis_steps == 0
            labels2 << l
          else 
            labels2 << ""
          end
        end
        x.set_labels(labels2)
      end
      chart.x_axis = x
    else
      x = XAxis.new
      x.set_labels([""])
      chart.x_axis = x
    end

    unless get_x_legend.nil?
      legend = XLegend.new(get_x_legend)
      legend.set_style('{font-size: 12px}')
      chart.set_x_legend(legend)
    end
    
    unless get_x_legend.nil?
      legend = YLegend.new(get_y_legend)
      legend.set_style('{font-size: 12px}')
      chart.set_y_legend(legend)
    end

    chart.set_bg_colour('#ffffff');

    render :text => chart.to_s
  end

  # TODO Move it outside this class
  def get_sets(rows, grouping, count, flat = false)
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
      sets[group_name] ||= Array.new(count, [0, get_hints])

      if r.value_x
        i = r.value_x.to_i
      else
        i += 1
      end

      sets[group_name][i] = [r.value_y.to_i, get_hints(r, grouping)]
      y_max = r.value_y.to_i if y_max < r.value_y.to_i
    end

    [y_max, sets.collect { |name, values| [name, values] }]
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

  # TODO
  def get_x_axis_steps
    5
  end

  # Returns true if Y axis should be displayed
  def show_y_axis
    false
  end

  # TODO
  def get_y_axis_steps
    5
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

  # Returns converter for given chart type
  def get_converter
    eval("RedmineCharts::#{get_type.to_s.camelize}DataConverter")
  end

  # Finds current project or raises 404
  def find_project
    @project = Project.find(params[:project_id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  # Checks and sets default params values
  def check_params
    RedmineCharts::RangeUtils.set_params(params)    
  end

end

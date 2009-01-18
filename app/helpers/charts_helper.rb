module ChartsHelper

  def show_charts_menu
    res = ""
    RedmineCharts::Utils.controllers_for_routing do |name, controller_name|
      res << " | "
      if controller.controller_name == controller_name
        res << l("charts_link_#{name}".to_sym)
      else
        res << link_to(l("charts_link_#{name}".to_sym), :controller => controller_name)
      end
    end
    res
  end

  def show_graph
    controller.params ||= {}
    controller.params[:action] = :data
    controller.open_flash_chart_object("100%", "400", url_for(controller.params).gsub("&amp;", "&"))
  end

  def show_date_condition(range_steps, range_in, range_offset)
    res = l(:charts_show_last) << " "
    res << text_field_tag(:range_steps, range_steps, :size => 4)
    res << hidden_field_tag(:range_offset, range_offset)
    res << " "
    res << select_tag(:range_in, options_for_select(RedmineCharts::RangeUtils.in_options, range_in.to_s))

    res << "<br/><br/>"

    res << link_to_function(l(:charts_earlier), :onclick => 'charts_earlier();')
    res << " - "
    if range_offset.to_i == 1
      res << l(:charts_later)
    else
      res << link_to_function(l(:charts_later), :onclick => 'charts_later();')
    end

    res
  end

end

module ChartsHelper

  def charts_menu
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

end

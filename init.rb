require 'redmine'

require_dependency 'redmine_charts/date_format'

Redmine::Plugin.register :charts do
  name 'Charts'
  author 'Maciej Szczytowski'
  description 'Charts plugin contains some useful project statistics.'
  version '0.1.0'

  controllers = %w{burndown groups hours deviation}.collect { |name| "charts_#{name}".to_sym }

  project_module :charts do
    permission :view_charts, Hash[*(controllers.collect { |controller| [controller, :index] }.flatten)]
  end
    
  menu :project_menu, :charts, { :controller => controllers.first.to_s, :action => :index.to_s }, :caption => :charts_menu_label, :after => :new_issue, :param => :project_id
end

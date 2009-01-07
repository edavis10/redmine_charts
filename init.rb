require 'redmine'

Redmine::Plugin.register :charts do
  name 'Charts'
  author 'Maciej Szczytowski'
  description 'Charts plugin contains some useful project statistics.'
  version '0.0.4'

  permission :charts, {"charts_groups".to_sym => [:index], "charts_hours".to_sym => [:index], "charts_burndown".to_sym => [:index]}, :public => true
    
  menu :project_menu, :charts, { :controller => 'charts_burndown', :action => 'index' }, :caption => :charts_menu_label, :after => :new_issue, :param => :project_id
end

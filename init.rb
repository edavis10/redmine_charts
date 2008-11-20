require 'redmine'

# Will not work in development mode
require_dependency 'redmine_charts/issue_patch'

Redmine::Plugin.register :charts do
  name 'Charts'
  author 'Maciej Szczytowski'
  description 'Charts plugin contains some useful project statistics.'
  version '0.0.1'

  permission :charts, {"charts_groups".to_sym => [:index], "charts_hours".to_sym => [:index], "charts_burndown".to_sym => [:index]}, :public => true
    
  menu :project_menu, :charts, { :controller => 'charts_groups', :action => 'index' }, :caption => :charts_menu_label, :after => :new_issue, :param => :project_id
end
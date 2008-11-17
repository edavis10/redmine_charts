require 'redmine'

Redmine::Plugin.register :charts do
  name 'Charts'
  author 'Maciej Szczytowski'
  description 'Charts plugin contains some useful project statistics.'
  version '0.0.1'

  permission :charts, {"charts/groups".to_sym => [:index], "charts/hours".to_sym => [:index], "charts/velocity".to_sym => [:index]}, :public => true
    
  menu :project_menu, :charts, { :controller => 'charts/groups', :action => 'index' }, :caption => :charts_menu_label, :after => :new_issue, :param => :project_id
end

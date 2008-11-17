require 'redmine'

Redmine::Plugin.register :charts do
  name 'Charts'
  author 'Maciej Szczytowski'
  description 'Charts plugin contains some useful project statistics.'
  version '0.0.1'
  
  menu :project_menu, :charts, { :controller => 'charts/groups', :action => 'index' }, :caption => ':charts_menu_label', :after => :activity, :param => :project_id
end

require 'redmine'

require_dependency 'active_record/connection_adapters/abstract_adapter'
require_dependency 'active_record/connection_adapters/mysql_adapter'
require_dependency 'active_record/connection_adapters/postgresql_adapter'

Redmine::Plugin.register :charts do
  name 'Charts'
  author 'Maciej Szczytowski'
  description 'Charts plugin contains some useful project statistics.'
  version '0.0.5'

  permission :charts, {"charts_groups".to_sym => [:index], "charts_hours".to_sym => [:index], "charts_burndown".to_sym => [:index]}, :public => true
    
  menu :project_menu, :charts, { :controller => 'charts_burndown', :action => 'index' }, :caption => :charts_menu_label, :after => :new_issue, :param => :project_id
end

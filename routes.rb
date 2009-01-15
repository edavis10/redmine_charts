require_dependency 'redmine_charts/utils'

# Configuring routing for plugin's controllers.

RedmineCharts::Utils.controllers_for_routing do |name, controller|
  connect "projects/:project_id/charts/#{name}/:action", :controller => controller
end
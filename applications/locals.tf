locals {
  #filter environemnts based on workspaces remove the ones that are empty and make a new map
  apps = {
    for name, app in local.applications : name => {
      environments      = lookup(app, terraform.workspace, null)
      efs_access_points = app.efs_access_points
    }
    if lookup(app, terraform.workspace, null) != null
  }
  names = flatten([
    for name, application in local.apps : [
      name
    ]
  ])
  #create namespaces from the map above
  namespaces = flatten([
    for name, application in local.apps : [
      for env, environment in application.environments : [
        "${name}-${environment}"
      ]
    ]
  ])
}

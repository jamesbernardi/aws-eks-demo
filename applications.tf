locals {
  applications = {
    static = {
      pre-prod          = ["dev", "stage"]
      production        = ["www"]
      efs_access_points = ["images", "video"]
    }
    wordpress = {
      pre-prod          = ["dev", "stage"]
      production        = ["www"]
      efs_access_points = ["wp-uploads"]
    }
    node = {
      pre-prod          = ["dev", "stage"]
      production        = ["www"]
      efs_access_points = ["public", "files"]
    }
  }
}

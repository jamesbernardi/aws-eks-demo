locals {
  applications = {
    globalaccess = {
      pre-prod-environments = ["dev", "stage"]
      prod-environments     = ["www"]
      efs_access_points     = ["images", "video"]
    }
    wordpress = {
      pre-prod-environments = ["dev", "stage"]
      prod-environments     = ["www"]
      efs_access_points     = ["wp-uploads"]
    }
  }
}


module "ci-demo" {
  source = "./module"

  # Github Repository Information
  repo_owner  = "setswei"
  repo_name   = "techops-ci-demo-application"
  repo_branch = "master"

}

provider "aws" {
  profile = "lab"
  region  = "ap-southeast-2"
}
# Variables for Github

variable "repo_owner" {
  description = "This is the owner of the repository"
  type        = string
}

variable "repo_name" {
  description = "This is the name of the repository"
  type        = string
}

variable "repo_branch" {
  description = "This is the name of the branch you want to utilise eg: master"
  type        = string
}

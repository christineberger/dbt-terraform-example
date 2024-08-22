// define the variables we will use
variable "dbt_account_id" {
    type = number
}

variable "dbt_token" {
    type = string
}

variable "dbt_host_url" {
    type = string
}

variable "git_repo_url" {
    type = string
}

variable "git_dbt_installation_id" {
    type = number
}

variable "project_names" {
    type = set(string)
}

// initialize the provider and set the settings
terraform {
    required_providers {
        dbtcloud = {
            source  = "dbt-labs/dbtcloud"
            version = "0.3.12"
        }
    }
}

provider "dbtcloud" {
    account_id = var.dbt_account_id
    token      = var.dbt_token
    host_url   = var.dbt_host_url
}

// Create a project
resource "dbtcloud_project" "customer_projects" {
    for_each = var.project_names
    name = each.value
}

// Use Github Integration
resource "dbtcloud_repository" "github_integration" {
    for_each = var.project_names
    project_id             = dbtcloud_project.customer_projects[each.value].id
    remote_url             = var.git_repo_url
    github_installation_id = var.git_dbt_installation_id
    git_clone_strategy     = "github_app"
}

resource "dbtcloud_project_repository" "dbt_project_repository" {
    for_each = var.project_names
    project_id    = dbtcloud_project.customer_projects[each.value].id
    repository_id = dbtcloud_repository.github_integration[each.value].repository_id
}
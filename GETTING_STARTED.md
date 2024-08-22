This demo fires Terraform with a command line interface, but Terraform [provides a cloud solution](https://app.terraform.io/public/signup/account) 
which would eliminate the need for ongoing admins to understand how to get these
things up and running locally.

### Setup
1. [Install Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli#install-terraform)
2. Clone this repository 
3. Create a file called `terraform.tfvars` - the .gitignore in this repository
   ignores this file so sensitive information is not committed to the repo.
   Add these variables and CHANGE ALL VALUES to work with your dbt Cloud
   account. Details on where to get this info is below the example.:
   ```
   dbt_account_id = 12345
   dbt_token = "<your_dbt_cloud_token>"
   dbt_host_url = "https://cloud.getdbt.com/api"
   git_repo_url = "<your repository url>"
   git_dbt_installation_id = 123456

   project_names = [
      "Customer A",
      "Customer B"
   ]
   ```

   Getting the values:
      1. `dbt_account_id` and `dbt_host_url`  
         From dbt Cloud, go to any job's home page and click `API Trigger` in the top right corner next to the job's 
         'Settings' button.
         - `dbt_account_id` will be the *Account ID* value.
         - `dbt_host_url` will be the URL seen under *Example request* under "POST",
            only up to and including the "/api" portion.

      2. `dbt_token`  
         From dbt Cloud, go to Account Settings > API Tokens > Personal
         tokens and create a new token. Make sure to save the token in a safe place
         like a password manager for later use, otherwise you will need to delete and
         regenerate to get a new token.

         ** Note that the operations in this script perform account admin capabilities
         such as creating projects, so the user will need to have that level of
         permissions or otherwise ask for a service token to be created by an admin 
         and shared.
      3. `git_repo_url`  
         The clone URL of the repository you want to to configure the new dbt
         project with.
      4. `git_dbt_installation_id`
         This is only if you use Github and have it integrated with dbt Cloud.
         Otherwise, you may change out the dbtcloud_repository resource to use
         another method.

         To find this value, go to your repository > settings > applications >
         dbt Cloud > configure. In the URL, you'll find the installation id. i.e:
         https://github.com/settings/installations/12345679
         
         The value is the number after "/installations/" - or you can try one
         of the methods listed [here](https://registry.terraform.io/providers/dbt-labs/dbtcloud/latest/docs/resources/repository)
      5. `project_names`  
         This should be an array of "nice" names for your projects. dbt Cloud
         projects will be assigned unique ids upon creation. Changes to this list
         will result in the addition or destruction of said resources - for example,
         if your original list looked like this:
         ```
         project_names = [
            "Customer A",
            "Customer B"
         ]
         ```
         and it changed to this:
         ```
         project_names = [
            "Customer A",
            "Customer C"
         ]
         ```
         then Terraform will do nothing with Customer A, destroy Customer B, and create Customer C.

### Execution
Terraform has a lot of documentation that you can read through, so this will only
point out important aspects about the operations of this script's intents:

1. Running the script will create an instance of a dbt project. If you try
   to run again, it will try to update the instance you 
   created. To manage this, you should use `terraform workspace` commands.
   - For new projects, use `terraform workspace new <name of workspace>`.  
     For example: `terraform workspace new project_a`  
     You should use a new workspace every time you are creating a new dbt project.
   - For existing projects use `terraform workspace list` to see what your
     existing workspaces are and `terraform workspace select <name of workspace>`
     to switch to that project.
2. `terraform init` will install the dependencies listed in the script. If you 
   make a change to the dependencies, you should run this.
3. You should run `terraform plan` to see what actions terraform will take if applied.
4. You should run `terraform apply` if you want to actually build the dbt cloud
   resources.
5. You should run `terraform destroy` if you want to remove all the resources
   you created. Destroying single instances from the list via a command is an 
   exercise left to the reader, as this can be more simply done by removing the
   resource from the `project_names` list and running `terraform apply`.


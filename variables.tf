variable "vpc_subnets" {
    description = "List of subnets that the GitLab runner will be placed in"
    type = "list"
}

variable "vpc_env" {
    description = "Envrioment name of VPC. I.e. Prod, Mgmt etc."
    type = "string"
}

variable "key_name" {
    description = "Name of the SSH key to use"
    type = "string"
}

variable "ami_id" {
    description = "ID of the base AMI the runner will use"
    type = "string"
}

variable "instance_type" {
    description = "AWS Instance Type to use"
    type = "string"
    default = "t2.small"
}

variable "iam_profile" {
    description = "Resource ID of the IAM profile the instance will use"
    type = "string"
}

variable "security_groups" {
    description = "List of addtional security group to apply"
    type = "list" 
}

variable "gitlab_runner_name" {
    description = "Name that the runner will appear with in GitLab"
    type = "string"
}

variable "gitlab_runner_url" {
    description = "URL of the GitLab CI server to connect to"
    type = "string"
    default = "https://gitlab.com/ci"
}

variable "gitlab_runner_token" {
    description = "Token used to authenticate with CI server"
    type = "string"
}

variable "gitlab_runner_tags" {
    description = "Tags to add to the runner"
    type = "string"
    default = "specific,docker"
  
}

variable "gitlab_runner_docker_image" {
    description = "Gitlab Runner default docker image."
    type = "string"
    default = "terraform:light"
}

variable "gitlab_concurrent_job" {
    description = "Number of concurrent tasks to run"
    type = "string"
    default = "1"
} 
variable "gitlab_check_interval" {
    description = "Amount of time between checks for work"
    type = "string"
    default = "5s"
}


variable "gitlab_rct_low_free_space" {
    description = "Threshold for when to trigger the cache and image removal"
    type = "string"
    default = "1GB"
}

variable "gitlab_rct_expected_free_space" {
    description = "How much the free space to cleanup"
    type = "string"
    default = "2GB"
}

variable "gitlab_rct_low_free_files_count" {
    description = "When the number of free files (i-nodes) runs below this value trigger the cache and image removal"
    type = "string"
    default = "131072"
}

variable "gitlab_rct_expected_free_files_count" {
    description = "How many free files (i-nodes) to cleanup"
    type = "string"
    default = "262144"
}

variable "gitlab_rct_default_ttl" {
    description = "Minimum time to preserve a newly downloaded images or created caches"
    type = "string"
    default = "1m"
}

variable "gitlab_rct_use_df" {
    description = "Use a command line df tool to check disk space. Set to false when connecting to remote Docker Engine. Set to true when using with locally installed Docker Engine"
    type = "string"
    default = "1"
}
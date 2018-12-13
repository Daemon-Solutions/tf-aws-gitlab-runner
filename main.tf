/**
 * # tf-aws-gitlab-runner
 * 
 * A Gitlab Runner Terraform Module
 *
 * Give you:
 * - An ASG for a single EC2 node with gitlab runner installed and running
 *
 * ## Contributing
 *
 * Ensure any variables you add have a type and a description.
 * This README is generated with [terraform-docs](https://github.com/segmentio/terraform-docs):
 *
 * `terraform-docs --no-sort md . > README.md`
 *
*/
data "template_file" "runner_userdata" {
  template = "${file("${path.module}/user-data.sh")}"
  vars {
    GITLAB_RUNNER_NAME                    = "${var.gitlab_runner_name}"
    GITLAB_RUNNER_URL                     = "${var.gitlab_runner_url}"
    GITLAB_RUNNER_TOKEN                   = "${var.gitlab_runner_token}"
    GITLAB_RUNNER_TAGS                    = "${var.gitlab_runner_tags}"
    GITLAB_RUNNER_DOCKER_IMAGE            = "${var.gitlab_runner_docker_image}"
    GITLAB_RUNNER_DOCKER_PRIVILEGED       = "${var.gitlab_runner_docker_privileged ? "--docker-privileged" : ""}"
    GITLAB_CONCURRENT_JOB                 = "${var.gitlab_concurrent_job}"
    GITLAB_CHECK_INTERVAL                 = "${var.gitlab_check_interval}"

    GITLAB_RCT_LOW_FREE_SPACE             = "${var.gitlab_rct_low_free_space}"
    GITLAB_RCT_EXPECTED_FREE_SPACE        = "${var.gitlab_rct_expected_free_space}"
    GITLAB_RCT_LOW_FREE_FILES_COUNT       = "${var.gitlab_rct_low_free_files_count}"
    GITLAB_RCT_EXPECTED_FREE_FILES_COUNT  = "${var.gitlab_rct_expected_free_files_count}"
    GITLAB_RCT_DEFAULT_TTL                = "${var.gitlab_rct_default_ttl}"
    GITLAB_RCT_USE_DF                     = "${var.gitlab_rct_use_df}"
  }
}

module "runner" {
  source = "../tf-aws-asg"

  subnets              = ["${var.vpc_subnets}"]
  name                 = "gitlab-runner-${var.vpc_env}"
  service              = "gitlab-runner"
  key_name             = "${var.key_name}"
  instance_type        = "${var.instance_type}"
  envname              = "${var.vpc_env}"
  ami_id               = "${var.ami_id}"
  iam_instance_profile = "${var.iam_profile}"
  security_groups      = ["${var.security_groups}"]
  user_data            = "${data.template_file.runner_userdata.rendered}"
  min                  = "1"
  max                  = "1"

}


# tf-aws-gitlab-runner

A Gitlab Runner Terraform Module

Give you:
- An ASG for a single EC2 node with gitlab runner installed and running

## Contributing

Ensure any variables you add have a type and a description.
This README is generated with [terraform-docs](https://github.com/segmentio/terraform-docs):

`terraform-docs --no-sort md . > README.md`

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| ami\_id | ID of the base AMI the runner will use | string | n/a | yes |
| enabled | Whether or not to create resources | string | `"true"` | no |
| extra\_asg\_tags |  | list | `<list>` | no |
| gitlab\_check\_interval | Amount of time between checks for work | string | `"5"` | no |
| gitlab\_concurrent\_job | Number of concurrent tasks to run | string | `"1"` | no |
| gitlab\_rct\_default\_ttl | Minimum time to preserve a newly downloaded images or created caches | string | `"1m"` | no |
| gitlab\_rct\_expected\_free\_files\_count | How many free files (i-nodes) to cleanup | string | `"262144"` | no |
| gitlab\_rct\_expected\_free\_space | How much the free space to cleanup | string | `"2GB"` | no |
| gitlab\_rct\_low\_free\_files\_count | When the number of free files (i-nodes) runs below this value trigger the cache and image removal | string | `"131072"` | no |
| gitlab\_rct\_low\_free\_space | Threshold for when to trigger the cache and image removal | string | `"1GB"` | no |
| gitlab\_rct\_use\_df | Use a command line df tool to check disk space. Set to false when connecting to remote Docker Engine. Set to true when using with locally installed Docker Engine | string | `"1"` | no |
| gitlab\_runner\_docker\_image | Gitlab Runner default docker image. | string | `"terraform:light"` | no |
| gitlab\_runner\_docker\_privileged | Toggle Gitlab Runner running privileged | string | `"false"` | no |
| gitlab\_runner\_locked | Toggle locking the Gitlab Runner to the specific project | string | `"true"` | no |
| gitlab\_runner\_name | Name that the runner will appear with in GitLab | string | n/a | yes |
| gitlab\_runner\_tags | Tags to add to the runner | string | `"specific,docker"` | no |
| gitlab\_runner\_token | Token used to authenticate with CI server | string | n/a | yes |
| gitlab\_runner\_url | URL of the GitLab CI server to connect to | string | `"https://gitlab.com/ci"` | no |
| iam\_profile | Resource ID of the IAM profile the instance will use | string | n/a | yes |
| instance\_type | AWS Instance Type to use | string | `"t2.small"` | no |
| key\_name | Name of the SSH key to use | string | n/a | yes |
| security\_groups | List of addtional security group to apply | list | n/a | yes |
| vpc\_env | Envrioment name of VPC. I.e. Prod, Mgmt etc. | string | n/a | yes |
| vpc\_subnets | List of subnets that the GitLab runner will be placed in | list | n/a | yes |


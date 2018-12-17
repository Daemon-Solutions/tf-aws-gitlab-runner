#!/bin/bash

# Update system
yum update -y && \

# Install htop and docker
yum install -y docker && \

# Install Gitlab CI Multi Runner
curl -L https://packages.gitlab.com/install/repositories/runner/gitlab-ci-multi-runner/script.rpm.sh | bash && \
yum install -y gitlab-ci-multi-runner

# Enable Services at startup
sudo chkconfig docker on
sudo chkconfig gitlab-runner on

# Start docker, we'll need it soon
service docker start

# Add gitlab-runner config
mkdir -p /etc/gitlab-runner
cat > /etc/gitlab-runner/config.toml <<- EOM
concurrent = ${GITLAB_CONCURRENT_JOB}
check_interval = ${GITLAB_CHECK_INTERVAL}

EOM

# Add ecr-credential-helper
docker run -i -v /usr/local/bin:/artifacts golang:1.8 sh << COMMANDS
go get -u github.com/awslabs/amazon-ecr-credential-helper/ecr-login/cli/docker-credential-ecr-login
cp \$${GOPATH}/bin/docker-credential-ecr-login /artifacts
COMMANDS

# Register gitlab runner
gitlab-runner register --non-interactive \
                       --name "${GITLAB_RUNNER_NAME}" \
                       --url "${GITLAB_RUNNER_URL}" \
                       --registration-token "${GITLAB_RUNNER_TOKEN}" \
                       --executor docker \
                       --tag-list "${GITLAB_RUNNER_TAGS}" \
                       --docker-image "${GITLAB_RUNNER_DOCKER_IMAGE}" \
                       --env DOCKER_AUTH_CONFIG={\"credsStore\":\"ecr-login\"} \
                       ${GITLAB_RUNNER_DOCKER_PRIVILEGED}

# Set env var for gitlab-runner, needed for ecr-login
mkdir -p /etc/systemd/system/gitlab-runner.service.d
cat > /etc/systemd/system/gitlab-runner.service.d/override.conf <<- EOM
[Service]
Environment=AWS_REGION=${AWS_REGION}
EOM

systemctl daemon-reload

# Start services
systemctl restart gitlab-runner

# Launch Gitlab Runner Cleanup Tool
docker run -d \
      -e LOW_FREE_SPACE=${GITLAB_RCT_LOW_FREE_SPACE} \
      -e EXPECTED_FREE_SPACE=${GITLAB_RCT_EXPECTED_FREE_SPACE} \
      -e LOW_FREE_FILES_COUNT=${GITLAB_RCT_LOW_FREE_FILES_COUNT} \
      -e EXPECTED_FREE_FILES_COUNT=${GITLAB_RCT_EXPECTED_FREE_FILES_COUNT} \
      -e DEFAULT_TTL=${GITLAB_RCT_DEFAULT_TTL} \
      -e USE_DF=${GITLAB_RCT_USE_DF} \
      --restart always \
      -v /var/run/docker.sock:/var/run/docker.sock \
      --name=gitlab-runner-docker-cleanup \
      quay.io/gitlab/gitlab-runner-docker-cleanup

#!/bin/bash

# Update system
yum update -y && \

# Install ntp and docker
yum install -y ntp docker && \

# Install Gitlab CI Multi Runner
curl -L https://packages.gitlab.com/install/repositories/runner/gitlab-ci-multi-runner/script.rpm.sh | bash && \
yum install -y gitlab-ci-multi-runner

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
                       --locked="${GITLAB_RUNNER_LOCKED}" \
                       ${GITLAB_RUNNER_DOCKER_PRIVILEGED}

# Set env var for gitlab-runner, needed for ecr-login
mkdir -p /etc/systemd/system/gitlab-runner.service.d
cat > /etc/systemd/system/gitlab-runner.service.d/override.conf <<- EOM
[Service]
Environment=AWS_REGION=${AWS_REGION}
EOM

# Unit file for Gitlab Runner Cleanup Tool
cat <<EOF >/etc/systemd/system/gitlab-runner-cleanup-tool.service
[Unit]
Description=Gitlab Runner Cleanup Tool Service
After=docker.service
Requires=docker.service

[Service]
TimeoutStartSec=0
Restart=always
RestartSec=5
ExecStartPre=-/bin/docker stop gitlab-runner-docker-cleanup
ExecStartPre=-/bin/docker rm gitlab-runner-docker-cleanup
ExecStart=/bin/docker run \
  -e LOW_FREE_SPACE=${GITLAB_RCT_LOW_FREE_SPACE} \
  -e EXPECTED_FREE_SPACE=${GITLAB_RCT_EXPECTED_FREE_SPACE} \
  -e LOW_FREE_FILES_COUNT=${GITLAB_RCT_LOW_FREE_FILES_COUNT} \
  -e EXPECTED_FREE_FILES_COUNT=${GITLAB_RCT_EXPECTED_FREE_FILES_COUNT} \
  -e DEFAULT_TTL=${GITLAB_RCT_DEFAULT_TTL} \
  -e USE_DF=${GITLAB_RCT_USE_DF} \
  -v /var/run/docker.sock:/var/run/docker.sock \
  --name=gitlab-runner-docker-cleanup \
  quay.io/gitlab/gitlab-runner-docker-cleanup

[Install]
WantedBy=multi-user.target
EOF

# Unit file for Prometheus node-exporter
cat <<EOF >/etc/systemd/system/node-exporter.service
[Unit]
Description=Prometheus Node Exporter Service
After=docker.service
Requires=docker.service

[Service]
TimeoutStartSec=0
Restart=always
RestartSec=5
ExecStartPre=-/bin/docker stop node-exporter
ExecStartPre=-/bin/docker rm node-exporter
ExecStart=/bin/docker run \
  --net=host \
  --pid=host \
  -v "/:/host:ro,rslave" \
  --name=node-exporter \
  quay.io/prometheus/node-exporter:v0.17.0 --path.rootfs /host

[Install]
WantedBy=multi-user.target
EOF

# Enable and start required services
systemctl daemon-reload
systemctl enable --now ntpd.service
systemctl enable --now docker.service
systemctl enable --now gitlab-runner.service
systemctl enable --now gitlab-runner-cleanup-tool.service
systemctl enable --now node-exporter.service

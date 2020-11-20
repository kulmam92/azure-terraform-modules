FROM centos:centos7.7.1908

ARG ANSIBLE_VERSION=2.10.*
ARG TF_VERSION=latest
ARG TG_VERSION=latest

ENV IAC_DEV_USER=iacdev

RUN yum check-update; \
   yum install -y gcc libffi-devel python3 epel-release sudo; \
   yum install -y openssh-clients sshpass curl git unzip ca-certificates;

# https://github.com/devops-infra/docker-terragrunt
RUN set -eux \
# Get Terraform by a specific version
	&& if [ "${TF_VERSION}" = "latest" ]; then \
		VERSION="$( curl -sS https://releases.hashicorp.com/terraform/ | cat \
			| grep -Eo '/[.0-9]+/' | grep -Eo '[.0-9]+' \
			| sort -V | tail -1 )"; \
	else \
		VERSION="${TF_VERSION}"; \
	fi \
	&& curl -sS -L -O \
		https://releases.hashicorp.com/terraform/${VERSION}/terraform_${VERSION}_linux_amd64.zip \
	&& unzip terraform_${VERSION}_linux_amd64.zip \
	&& mv terraform /usr/bin/terraform \
	&& chmod +x /usr/bin/terraform \
# Get Terragrunt by a specific version
	&& git clone https://github.com/gruntwork-io/terragrunt /terragrunt \
	&& cd /terragrunt \
	&& if [ "${TG_VERSION}" = "latest" ]; then \
		VERSION="$( git describe --abbrev=0 --tags )"; \
	else \
		VERSION="v${TG_VERSION}";\
	fi \
	&& curl -sS -L \
		https://github.com/gruntwork-io/terragrunt/releases/download/${VERSION}/terragrunt_linux_amd64 \
		-o /usr/bin/terragrunt \
	&& chmod +x /usr/bin/terragrunt \
# Get latest TFLint
	&& curl -L "$( curl -Ls https://api.github.com/repos/terraform-linters/tflint/releases/latest | grep -o -E "https://.+?_linux_amd64.zip" )" \
    -o tflint.zip \
	&& unzip tflint.zip \
	&& mv tflint /usr/bin/tflint \
  && chmod +x /usr/bin/tflint \
# Get latest hcledit
  && curl -L "$( curl -Ls https://api.github.com/repos/minamijoyo/hcledit/releases/latest | grep -o -E "https://.+?_linux_amd64.tar.gz" )" \
    -o hcledit.tar.gz \
  && tar -xf hcledit.tar.gz \
  && mv hcledit /usr/bin/hcledit \
  && chmod +x /usr/bin/hcledit \
  && chown $(id -u):$(id -g) /usr/bin/hcledit \
# Get latest sops
	&& curl -L "$( curl -Ls https://api.github.com/repos/mozilla/sops/releases/latest | grep -o -E "https://.+?\.linux" )" \
    -o /usr/bin/sops \
  && chmod +x /usr/bin/sops

RUN curl https://packages.microsoft.com/config/rhel/7/prod.repo | tee /etc/yum.repos.d/microsoft.repo; \
   yum install -y powershell; \
   pwsh -c "Set-PackageSource -Name PSGallery -Trusted"; \
   pwsh -c "Install-Module AZ -Scope AllUsers"; \
   pip3 install --upgrade pip

# install Azure CLI
RUN rpm --import https://packages.microsoft.com/keys/microsoft.asc; \
   sh -c 'echo -e "[azure-cli] \n\
name=Azure CLI \n\
baseurl=https://packages.microsoft.com/yumrepos/azure-cli \n\
enabled=1 \n\
gpgcheck=1 \n\
gpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/azure-cli.repo'; \
   yum install -y azure-cli;

# https://docs.ansible.com/ansible/latest/scenario_guides/guide_azure.html
# after ansible 2.9 plugin should be installed using ansible-galaxy
# https://raw.githubusercontent.com/MicrosoftDocs/mslearn-ansible-control-machine/master/configure-ansible-centos.sh
COPY requirements-azure.txt /requirements-azure.txt
RUN pip3 install "ansible==${ANSIBLE_VERSION}" && \
   ansible-galaxy collection install azure.azcollection --force && \
   ansible-galaxy collection install chocolatey.chocolatey && \
   ansible-galaxy collection install community.windows && \
   pip3 install -r requirements-azure.txt && \
   pip3 install "pywinrm>=0.3.0" ansible-lint

RUN groupadd ${IAC_DEV_USER} && useradd -s /bin/bash -g ${IAC_DEV_USER} ${IAC_DEV_USER} && \
    usermod -aG wheel ${IAC_DEV_USER} && \
    echo "${IAC_DEV_USER} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
    echo 'empty' > /home/${IAC_DEV_USER}/.ansible_vault

WORKDIR /home/${IAC_DEV_USER}

USER ${IAC_DEV_USER}

# CMD [ "ansible-playbook", "--version" ]
# docker build --no-cache --rm -t iacbase:latest .
# ansible localhost -m azure_rm_resourcegroup -a "name=rg-ansible location=westus2"
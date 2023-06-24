# Install and configure ubuntu cloud image with terraform and ansible
I used the original source code from Mr Stephane ROBERT (https://blog.stephane-robert.info/tags/terraform/) to adapt it to my need.

Objective: Create linux hardening with docker & docker-compose
## Let's start
 - Terraform (https://www.terraform.io/)
 - Cloudinit (https://cloudinit.readthedocs.io/en/latest/)
 - Ansible (https://www.ansible.com/)

```
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common curl cloud-init
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update && sudo apt-get install terraform
python3 -m pip install --upgrade --user ansible checkov
git clone https://github.com/lprat/terraform-libvirt-ubuntu_cloudimage-example
cd terraform-libvirt-ubuntu_cloudimage-example/terraform
#vi terraform.tfvars -> change password for user root and usradm
terraform init
terraform plan
terraform apply
```

## TODO
  - change ubuntu to debian
  - Apply CIS benchmark hardening
  - Hardening ssh service
  - Install & config
     - auditd log (https://github.com/Neo23x0/auditd)
     - rsyslog to centralized logs
     - supervision
     - backup restic tool to persistent data
     - Wazuh agent


<!-- BEGIN_ANSIBLE_DOCS -->
# Ansible Role: ansible-docker
docker role for Proserver


## Requirements

| Platform | Versions |
| -------- | -------- |

## Role Arguments


### Entrypoint: main

The main entry point for the docker role.

Installs Docker CE from the official Docker repository, configures the Docker daemon,

sets up DNS resolution for containers via dnsmasq, and optionally configures UFW firewall rules.

|Option|Description|Type|Required|Default|
|---|---|---|---|---|
| docker | Docker configuration. | dict of 'docker' options | yes |  |

#### Options for main > docker

|Option|Description|Type|Required|Default|
|---|---|---|---|---|
| repository | Docker APT repository configuration. | dict of 'repository' options | no |  |
| daemon.json | Docker daemon configuration. Written as JSON to `/etc/docker/daemon.json`. | dict of 'daemon.json' options | no |  |
| daemon_environment | Environment variables to set for the Docker daemon via a systemd override. | dict | no |  |
| use_ufw | Whether to configure UFW firewall rules for Docker DNS resolution. Defaults to `true` on Ubuntu. | bool | no | {{ ansible_facts['distribution'] == 'Ubuntu' }} |

#### Options for main > docker > repository

|Option|Description|Type|Required|Default|
|---|---|---|---|---|
| apt | URL of the Docker APT repository. | str | no | https://download.docker.com/linux/{{ ansible_facts['distribution'] | lower }} |
| key | URL of the Docker APT repository GPG key. | str | no | https://download.docker.com/linux/{{ ansible_facts['distribution'] | lower }}/gpg |

#### Options for main > docker > daemon.json

|Option|Description|Type|Required|Default|
|---|---|---|---|---|
| dns | List of DNS servers for containers. | list of 'str' | no | ['100.96.0.1'] |
| default-address-pools | List of default address pools for Docker networks. | list of 'dict' | no | [{'base': '100.96.0.0/16', 'size': 24}] |
| log-opts | Logging driver options for Docker containers. | dict | no | {"max-size": "2m", "max-file": "2"} |



## Dependencies
None.

## Example Playbook

```
- hosts: all
  tasks:
    - name: Importing role: ansible-docker
      ansible.builtin.import_role:
        name: ansible-docker
      vars:
        docker: # required, type: dict of 'docker' options
```

## License

MIT

## Author and Project Information
punkt.de

<!-- END_ANSIBLE_DOCS -->

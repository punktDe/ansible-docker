<!-- BEGIN_ANSIBLE_DOCS -->
<!--
Do not edit README.md directly!

This file is generated automatically by aar-doc and will be overwritten.

Please edit meta/argument_specs.yml instead.
-->
# ansible-docker

docker role for Proserver

## Supported Operating Systems

- Debian 12, 13
- Ubuntu 24.04, 22.04

## Role Arguments



Installs Docker CE from the official Docker repository, configures the Docker daemon,

sets up DNS resolution for containers via dnsmasq, and optionally configures UFW firewall rules.

#### Options for `docker`

|Option|Description|Type|Required|Default|
|---|---|---|---|---|
| `repository` | Docker APT repository configuration. | dict of 'repository' options | no |  |
| `daemon.json` | Docker daemon configuration. Written as JSON to `/etc/docker/daemon.json`. | dict | no |  |
| `daemon_environment` | Environment variables to set for the Docker daemon via a systemd override. | dict | no |  |
| `use_ufw` | Whether to configure UFW firewall rules for Docker DNS resolution. Defaults to `true` on Ubuntu. | bool | no | {{ ansible_facts['distribution'] == 'Ubuntu' }} |

#### Options for `docker.repository`

|Option|Description|Type|Required|Default|
|---|---|---|---|---|
| `apt` | URL of the Docker APT repository. | str | no | https://download.docker.com/linux/{{ ansible_facts['distribution'] | lower }} |
| `key` | URL of the Docker APT repository GPG key. | str | no | https://download.docker.com/linux/{{ ansible_facts['distribution'] | lower }}/gpg |

## Dependencies
None.

## Installation
Add this role to the requirements.yml of your playbook as follows:
```yaml
roles:
  - name: ansible-docker
    src: https://github.com/punktDe/ansible-docker
```

Afterwards, install the role by running `ansible-galaxy install -r requirements.yml`

## Example Playbook

```yaml
- hosts: all
  roles:
    - name: docker
```


### Usage

The following example describes setting up a Keycloak container.

For a full example, please refer to our [ansible-keycloak](https://github.com/punktDe/ansible-keycloak) role

- Create a template in the role that manages your docker container with the following contents:

```jinja2
{%- import (role_path + "/../docker/templates/systemd/container.service")|relpath(playbook_dir) as service with context -%}
{{ service.All(keycloak) }}
```

- Configure the container parameters using Ansible variables. You can add other arbitrary variables to the root of the `keycloak` dictionary (in this case, `domain` and `prefix`), and refer to them inside the same dictionary using the `vars.` prefix:

```yaml
keycloak:
  domain: auth.example.com
  prefix:
    opt: /var/opt/keycloak
  container_name: keycloak
  image: quay.io/keycloak/keycloak:latest
  container_stop_timeout: 55
  depends_on:
    - postgresql
    - nginx
  volumes:
    "/opt/keycloak/conf":
      host_dir: "{{ vars.keycloak.prefix.opt | quote }}/conf"
      relabel: unshared
      read_only: yes
    "/opt/keycloak/themes":
      host_dir: "{{ vars.keycloak.prefix.opt | quote }}/current/themes"
    "/opt/keycloak/providers":
      host_dir: "{{ vars.keycloak.prefix.opt | quote }}/current/providers"
  ports:
    127.0.0.1:8080: 8080
  environment:
    KEYCLOAK_FRONTEND_URL: "https://{{ vars.keycloak.domain }}/auth"
    KC_PROXY: "edge"
  entrypoint: /bin/kc.sh start-dev
  command: echo "hello world"
```

- Finally, provision the service file:

```yaml
- name: Install systemd service for Keycloak
  template:
    src: keycloak.service
    dest: "/etc/systemd/system/keycloak.service"
    trim_blocks: no
```


<!-- END_ANSIBLE_DOCS -->

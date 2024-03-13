# punktDe/ansible-docker

A Docker role which can be used to deploy Docker containers as SystemD services.

Installs the latest version of Docker from the official repos

Compatible with Ubuntu 20.04 & 22.04, as well as Debian 12.

### Usage
The following example describes setting up a Keycloak container.

For a full example, please refer to our [ansible-keycloak](https://github.com/punktDe/ansible-keycloak) role

* Create a template in the role that manages your docker container with the following contents:
```jinja2
{%- import (role_path + "/../docker/templates/systemd/container.service")|relpath(playbook_dir) as service with context -%}
{{ service.All(keycloak) }}
```

* Configure the container parameters using Ansible variables. You can add other arbitrary variables to the root of the `keycloak` dictionary (in this case, `domain` and `prefix`), and refer to them inside the same dictionary using the `vars.` prefix:
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
  entrypoint:
    /bin/kc.sh start-dev
  command:
    echo "hello world"
```

* Finally, provision the service file:
```yaml
- name: Install systemd service for Keycloak
  template:
    src: keycloak.service
    dest: "/etc/systemd/system/keycloak.service"
    trim_blocks: no
```

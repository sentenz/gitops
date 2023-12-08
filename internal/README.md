# `/internal`

A workspace for managing and organizing Ansible projects. The workspace is organized into several directories and files.

- `ansible.cfg`
  > Configuration file for Ansible placed in the `root` directory.

- `inventory`
  > Lists the hosts where Ansible will run tasks.

- `playbooks`
  > Contains the playbooks that Ansible will run.

- `roles`
  > Contains the roles that Ansible will use. Each role has its own directory under `roles`, and each of these directories may contain the following:

  - `tasks`
    > Contains the main list of tasks that the role will execute.

  - `handlers`
    > Contains handlers, which are tasks that will only be run if notified by another task.

  - `templates`
    > Contains `Jinja2` template files that Ansible will deploy to hosts.

  - `files`
    > Contains static files that Ansible will deploy to hosts.

  - `vars`
    > Contains variables that are used in the role.

  - `defaults`
    > Contains default values for variables used in the role.

  - `meta`
    > Contains metadata about the role.

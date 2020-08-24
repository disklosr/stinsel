# Stinsel

## What is this?

An opinionated, convention-based collection of ansible scripts to ease management of self-hosting containers and services.

I use this to manage my servers and self-hosted services. I'm keeping this repo open so others can get inspiration from it while I can gather feedback from them. 

## Why did I build this?

I build this to help me managing my self-hosted containers across many hosts. Here were my goals:

* Define all of my infrastructure in a single source-of-truth repository that contains all configuration, stack definitions, hosts, secrets and administrative scripts
* Deployments of new services can be done locally or, better, remotely from my personal laptop
* Be able to manage all my hosts remotely from a central location (my personal laptop)
* Make it easy to write new service definitions in succinct, testable and more manageable way than `docker-compose`
* Safely store encrypted secrets in git repository so I can publicly share it with the world
* Manage multiple hosts each with its own set of services
* Easily define scripts for performing regular administrative tasks
* Setup any freshly provisioned host or VPS using one single command. Ensuring it has all needed dependencies and properly securing it using sane defaults
* The tool should be simple and minimalist. No black magic involved

## What's wrong with `docker-compose` ?

A lot of people in the self-hosting community use `docker-compose` to manage their servers and stacks. I think there are better tools one should explore, even for the simplest of self-hosting setups. Ansible is the tool I choose as an alternative and it's what `Stinsel` is based on.

Here's where `docker-compose` falls short for me:

* Only deals with defining containers, which only tells half the story. You need extra steps to get your config files there before you can start your stack
* Lack of a good templating engine
* Doesn't provide a way for securely storing secrets
* Results in duplication and verbosity as the number of services grow, with no elegant way (to my knowledge) to share common configuration among them
* Was designed for development and testing workflows

## How does this work?

There are 6 main folders you can explore in this repo:

### Stacks

The `stacks` folder contains stack definitions of the services I host. A `stack` in `Stinsel` is the equivalent of -- wait for it -- a `stack` in docker swarm, or `Pods` in `k8s`. Each stack is represented by a single folder whose name is the `stack_id`.  Every `stack` folder is shaped in the following way:
  * `conf`: A directory that contains configuration files
  * `data`: A directory that contains data files that needs to be seeded during first run of a service
  * `secure_vars` contains sensitive parameters like passwords and access tokens. Everything defined here is available to be used in any configuration files thanks to the excellent `jinja` templating
  * `deploy.yml` is the equivalent of `docker-compose` files, but implemented as an Ansible Playbook. This has few drawbacks and many advantages over using simple `docker-compose` files
  * `test.yml` is a Playbook file to test that my services are correctly deployed. This could very well be included as the last step in `deploy.yml` file, but I chose to keep it separate so I can deploy and test separately

The only requirement for a stack is to have a `deploy.yml` file. Everything else is optional. For instance, the `portainer` stack can be defined using a single file:

```yml
---
- hosts: "{{target}}"
  become: yes
  gather_facts: no

  tasks:
    - include_role:
        name: deploy
      vars:
        image: portainer/portainer:1.24.0
        role_id: web
        volumes:
          - /var/run/docker.sock:/var/run/docker.sock
          - "{{data_dir}}:/data"
        labels: |
          "traefik.enable": "true"
          "traefik.http.routers.{{container_id}}.rule": "Host(`{{role_url}}`)"
```

When deploying a stack, `Stinsel` mirrors the contents of `conf` and `dir` folders to the remote host, while also evaluating any templated expressions in configuration files. The it proceeds to creating and starting containers. After everything finished successfully, the deployed stack is automatically made available at `stack_id.domain_name.tld`

`Stinsel` automatically adds some meta labels to all containers it manages:

```yml
# All containers in the same stack share this same label
"stinsel.stack.id": "stack_id"
# All containers are labeled with their base directory
"stinsel.stack.basedir": "/stinsel/stack_id"
```

These meta labels can be powerful for administrative scenarios. For instance, if I need to back up a stack, I can simply read it's `base_dir` from docker labels so I know what needs to be backed up. I can also start and stop entire stacks by filtering on the `stinsel.stack.id` labels.

`Stinsel` has a `core` stack, which contains the base infrastructure of my self-hosting setup. I chose `Traefik` as my go to reverse proxy, and `Authelia` as an SSO portal. All services are secured behind `Authelia` by default so I can't expose something publicly by mistake. This `core` stack is lightweight and consumes less than 15Mb of ram. It can be used on low end VPS without worries.

### Jobs

This is where I define my crons.

I use a selfhosted instance of the excellent `Healthchecks.io` cron monitoring tool. Each job should have an id generated by `Healthchecks.io`. This allows me to track execution and failures of my crons.

The `alive` job is an example of a cron I use to monitor uptime of all my managed servers. 

### Config

The `config` folder is where I setup global configurations of my infrastructure, which can easily be overwritten at a host level. There are only 3 files here:
* `globals.yml` contains some core `Stinsel` variables plus some other vars to tweak the behavior of the tool. This file is not encrypted as it doesn't contain any secrets
* `secure_globals` contains sensitive global configurations. Things like admin username and password, Authelia web portal password, custom ssh port and so on. This file is encrypted, only I can see its contents
* `secure_hosts` is where I define the hosts I'd like to manage, their domain names, what packages I want installed on each host, what stacks I want to enable, plus any global variable I need to override. This file is also obviously encrypted

### Scripts

This contains administrative tasks I need to perform on my hosts. Each sub directory represent an administrative action and contains a `run.yml` file that defines the tasks to be done in an Ansible Playbook. Doing it this way is far superior that writing your own bash scripts as it's readable, self-documented, idempotent and error-prone.

Take a look at step `03-install-packages` to see an example of the glory of using Ansible for administrative tasks.

### Utils

This folder contains scripts to make it easy to run `Stinsel` actions. The syntax of running Ansible playbooks can be long and boring to type, so I got myself some wrapper scripts here to reduce the friction.

For instance, here's how I'd deploy `portainer` stack on my `abra` vps:

```bash
# Deploys portainer on abra host
utils/deploy.sh abra portainer
```

And here's how I'd test that same deployment:

```bash
# Tests that portainer is working fine on abra host
utils/test.sh abra portainer
```
And for running administrative tasks, I only give the step number:

```bash
# Runs 04-setup-firewall script
utils/run.sh abra 04
```

I also include some other utility scripts, like a `pre-commit` git hook to make sure I don't commit any secrets in unencrypted format, and a tool go generate random passwords.

Most of these scripts are simple one-liners and can be replaces with linux aliases.

### Lib

The `_lib` folders is where dragons live. Or not really. 
This is where `Stinsel` code live. Everything that `Stinsel` needs is here, there are no external dependencies or black magic involved. Those who are familiar with Ansible should hopefully appreciate the simplicity and minimalism. For the rest of you, your experience may vary.

## Can I use it?

It depends.

This repo is an example of how I use `Stinsel` to manage my self-hosted infrastructure. In its current state, `Stinsel` is coupled with my infrastructure definition. It needs to be properly extracted out before others can start using it.

I'm not sure if extracting it out is worth doing right now. Until then, here are your current options:

* You can get inspiration from this repo by studying and exploring it, then maybe try to reproduce something similar or incorporate some of its concept into your own setup
* You can clone this repo and reconfigure it using your own hosts and secrets

In all cases, if you really like `Stinsel` and need help with it, please contact me I'll be glad to help you in any way I can.
# DevOps101

## Branch - master

This branch only has the node app, we will be branching off of this to add
the rest of our tooling.

## Branch - consistent local environment

In this step we're going to set up our local environment to be

* self-contained
* reproducible from machine to machine

We'll accomplish those goals using an open-source tool called [Vagrant](https://www.vagrantup.com/). You can think of Vagrant as a Docker-like tool but specifically
for development environments, rather than a distributable runtime. Vagrant defines how
to bring up a development box, but doesn't manage the VM itself, so we also need
to install Virtualbox as a place to run our environment.

We also need to install a vagrant plugin to enable filesharing on a Virtualbox OS.

Since we want to make sure it's easy for folks other than us to do what we're doing,
let's put everything we need in scripts. Run `$ touch brew_installs.sh` and then open
that file in your favorite editor. Put in:

``` shell
#! /bin/bash

brew update
brew install \
  vagrant \
  virtualbox

vagrant plugin install vagrant-vbguest
```

Now we need to make that file executable using `$ chmod +x brew_installs.sh` and then run it: `$ ./brew_installs.sh`.

Now run `$ vagrant init`. This gives us a base vagrant file to use to bring.

We'll now configure our box to use Virtualbox, starting with a base Alpine Linux image,
and adding node and npm. Check the branch on this repo for that content.

If you are on a newer version of MacOS, you may need to follow [these instructions](https://github.com/hashicorp/vagrant/issues/9567).

Now we can run `$ vagrant up && vagrant ssh`, which will provision the box, and then give us a terminal running in it. Vagrant is syncing our local files, so we can do our coding work in our favorite editor while running it in an environment that is always consistent, and can more closely match our eventual deployment environment.

You can quickly check that things are working correctly by running `$ npm test` in our ssh terminal. To get out of the ssh session, run `$ exit`.

The box continues to run in the background. If you want to stop it, run `$ vagrant suspend`. To remove it completely, run `$ vagrant destroy`.

## Branch - add-ci

Now we're going to add a configuration file for our Continuous Integration service.

Continuous Integration means that all code is vetted and tested automatically before it gets merged in to a critical branch like master. There are several services like CircleCI, TravisCI, and GitLab. They are all similar in how they are configured, but each
service has it's own specific settings. We'll use Circle for this
project.

We'll use Circle. Circle offers workflows made of multiple jobs.
Each job runs in a Docker container, so understanding Docker
is and important part of understanding CI. They also offer good
default Docker containers to run jobs in, and templates for
initial configuration for most languages. We'll use their template
for Node to get started with CI.

Now every commit we push to Github will have tests automaticall run.
We can also configure our Github repo to prevent merges unless
the tests in our CI process pass.

## Branch - containerize-it

Now we're going to get our application ready to run in a Docker container.

We'll be building it from scratch so we can follow a few security best practices.

First, we'll start with a base image of Alpine 3.10. Alpine Linux is a distribution
focused on having minimal size. The base container is about 5MB. This helps the
distribution realities of our container, as it keeps it smaller (the base Ubuntu image
is about 900MB) and also provides a smaller attack surface.

We're going with Alpine 3.10 not only because it has the latest patches for the OS itself,
but also for any packages it will download. You can explore available packages per Alpine
version at the [Alpine APK Repo site](https://pkgs.alpinelinux.org/packages). Since we're
working with Node 10.16 in the rest of our process, we want to use it in our final production
build. Alpine 3.10 is the only version of Alpine with 10.16 available.

Install the nodejs and npm packages.

Now we're going to do something you don't see in a lot of public Docker images.
We'll create a group and a user called `app`. We'll also make a directory at `/app`
and give ownership of that directory to the `app` group and user. Down below
you'll see that eventually we become that user in the container before running
our final command. This is so that if anyone got access to the container at runtime, they
have access to a user with no root or sudo privileges. This is a super low-cost way
to improve the security of your container.

Now we copy over our dependency definition files and then `$ npm install --production`.
We copy these over separately because they change less often than our app files. This
saves us build time when we're developing. We use `--production` on our install
so that we don't install unncessary testing packages to save space and time.

Similarly, we remove the npm package after we've installed, as it's no longer necessary.

Finally, we assume the `app` user role, COPY over the src directory, and run our app.

You can build this container image by running `$ docker build -t test .` and then run it
with `$ docker run -p 6000:6000 test`. Now you can test it by doing `$ curl localhost:6000/`.

### Continuous Builds

It's great that we have this container file, but we want it to be available for deployment!
Our next step is to make it build continuously as part of our CI process. A common pattern
you'll find is to have your CI process result in some artifact (a container, a binary, a JAR, etc)
and then some other process takes that artifact and deploys it. That is the pattern we will follow.

As usual, we will script out the publish process to keep it consistent, and to keep our Circle config clean.
Check the publish_docker.sh script for content.

To publish, we will need a username and password. These will be env variables kept in CircleCI (which does
not allow them to be user-readable in the jobs, but allows them to exist as env vars for the builds to use).

We will tag each image with the branch and git SHA. That way each build tag is immutable, and it's easy to
trace a container back to the code that is running in it.

Now we have continuous arifact building, and we're ready to move to deployment!

## Branch - infrastructure

As with everything we've done, creating our infrastructure will be done through code, so it is
reproducible and the history can be tracked (via git!). We will be using another OSS tool from Hashi,
[Terraform](https://www.terraform.io/), to create a tiny Kubernetes cluster on our local machine.

### Installing terraform and minikube

First, we should add `terraform` and `minikube` to our brew_installs script. For terraform, we will install
`terraform@0.11` as it is compatible with a plugin we will need to interact with `minikube`.

Since Terraform 0.11 is an old version, brew does not automatically put it on your path. It will output some instructions to do so.

Additionally, the plugin terraform-provider-minikube is not part of their official repos. You have to install
a release binary to use it. I have pre-committed it into this branch, and you can grab it from there, and
put it in the same file structure as in this branch.

### Creating the infrastructure

We'll make a `main.tf` file, and put some pretty basic configuration code in it. It will bring up our
minikube cluster repeatably, and allow us to change the config and apply those changes in a controlled way.

Terraform lets us plan our changes before we make them. To do this run `$ terraform plan` in the infra directory. You'll see that terraform wants to create a single resource, a minikube cluster, and show the config that will be applied.

NOTE: this process is not working correctly. Terraform is great; community plugins can sometimes be finicky.
I'm keeping it here as a reference, but in the meantime, just
`$ brew cask install minikube && minikube start`

## Defining the deployment

Checkout this branch to continue.

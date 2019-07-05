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

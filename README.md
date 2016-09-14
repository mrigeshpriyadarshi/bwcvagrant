# bwcvagrant

Brocade Workflow Composer (BWC) is the commercial version of the StackStorm automation platform. BWC adds priority support, advanced features such as fine-tuned access control, LDAP, and Workflow Designer.

Setup [Brocade WorkFlow Composer](https://www.stackstorm.com/product) (`bwc enterprise`) on your laptop with Vagrant and
VirtualBox, so you can play with it locally and develop integration and automation
[packs](https://docs.stackstorm.com/latest/packs.html).

If you are fluent with [Vagrant](https://www.vagrantup.com/docs/getting-started), you know where to
look and what to do. If you are new to Vagrant, just follow along with step-by-step instructions
below.


## Pre-requisites
* [Install git](https://git-scm.com/downloads), You may not have it if you're on Windows.

* Install recent version of [Vagrant](https://www.vagrantup.com/docs/installation/)
(v1.8.1 at the time of writing). For those unfortunate Windows users: [How to use Vagrant on Windows](http://tech.osteel.me/posts/2015/01/25/how-to-use-vagrant-on-windows.html) may sweeten your bitter.

* Install [VirtualBox](https://www.virtualbox.org/wiki/Downloads) (version 5.0 and up), and
VirtualBox Extension packs ([follow instructions for Extension packs
here](https://www.virtualbox.org/manual/ch01.html#intro-installing)).

## Simple installation

Clone the bwcvagrant repo, and start up Vagrant:

```bash
git clone https://github.com/mrigeshpriyadarshi/bwcvagrant.git
cd bwcvagrant
vagrant up
```

This command will download a vagrant box, create a virtual machine, and start a script to provision
the most recent stable version of Brocade WorkFlow Composer. You will see a lot of text, some of that may be red,
but not to worry, it's normal. After a while, you should see a large `BWC OK`, which means that
installation successful and a VM with Brocade WorkFlow Composer is ready to play. Log in to VM, and fire some st2
commands:

```bash
vagrant ssh
st2 --version
st2 action list
```

The BWC WebUI is available at https://192.168.16.21. The default st2admin user credentials are in
[Vagrantfile](Vagrantfile), usually `st2admin:Ch@ngeMe`.

You are in business! Go to [QuickStart](https://docs.stackstorm.com/install/bwc.html) and follow along.

To configure ChatOps, review and edit `/opt/stackstorm/chatops/st2chatops.env` configuration file
to point to Chat Service you are using. See details in "Setup ChatOps" section in installation
docs for your OS (e.g, [here is one for Ubuntu](https://docs.stackstorm.com/install/rhel7.html#setup-chatops)).

If something went wrong, jump to [Troubleshooting](https://github.com/mrigeshpriyadarshi/bwcvagrant#common-problems-and-solutions) section below.


## Customize your bwc installation

Environment variables can be used to enable or disable certain features of the Brocade WorkFlow Composer installation:

* `HOSTNAME` - the hostname to give the VM. DEFAULT: `st2vagrant`
* `BOX` - the Vagrant base box to use. DEFAULT: `bento/ubuntu-14.04`
* `ST2USER` - Username for st2. DEFAULT: st2admin
* `ST2PASSWORD` - Password for st2. DEFAULT: `Ch@ngeMe`
* `BWC_LICENSE` - Licence for BWC. DEFAULT: ``


Set the variables by pre-pending them to `vagrant up` command. In the example below, it will install
a version of bwc from development trunc, and set password to `secret`:

```BWC_LICENSE="license_key" ST2PASSWORD="secret" vagrant up```

To evaluate Brocade WorkFlow Composer on supported OS flavors, consider using the boxes we use
for best results:

* bento/ubuntu-14.04 for Ubuntu 14.04 (default)
* bento/centos-7.2 for CentOS 7.2
* bento/centos-6.7 for CentOS 6.7

Example:

```BOX="bento/centos-7.2" vagrant up```

Or use your favorite vagrant box. **Note that StackStorm installs from native Linux packages, which
are built for following OSes only. Make make sure the OS flavor of your box is one of the
following:**

* Ubuntu 14.04 (Trusty Tahr)
* CentOS 6.7 / RHEL 6.7
* CentOS 7.2 / RHEL 7.2

#### NFS mount option for Pack development

Playing with Brocade WorkFlow Composer ranges from creating rules and workflows, to turning your scripts into
actions, to writing custom sensors. And all of that involves working with files under
`/opt/stackstorm/packs` on `bwcvagrant` VM. One can do it via ssh, but with all your favorite tools
already set up on your laptop, it's convenient to hack files and work with `git` there on the host.

You can create your pack directories under `bwcvagrant/` on your host. Vagrant automatically maps
it's host directory to `/vagrant` directory on the VM, where you can symlink files and dirs to
desired locations.

Better yet, create a custom NFS mount to mount a directory on your laptop to `/opt/stackstorm/packs`
on the VM. In the Vagrantfile we are using following line for enabling ***NFS synced folder***:

```config.vm.synced_folder "path/to/folder/on/host", "/opt/stackstorm/packs", :nfs => true, :mount_options => ['nfsvers=3']```

To use this option, uncomment the line and change the location of `"path/to/folder/on/host"` to an
existing directory on your laptop.

By the time you read this hint, your VM is most likely already up and running. Not to worry: just
uncomment the above mentioned line in your `Vagrantfile` and run `vagrant reload --no-provision`.
This will restart
the VM and apply the new config without running the provision part, so you won't reinstall st2.
Vagrant will however ask you for your laptop password to sync the folders.

For details on NFS refer: https://www.vagrantup.com/docs/synced-folders/nfs.html

To learn about packs and how to work with them, see
[StackStorm documentation on packs!](https://docs.stackstorm.com/latest/packs.html)

## Manual installation

To master StackStorm and understand how things are wired together, we strongly encourage you to
[eventually] install StackStorm manually, following
[installation instructions](https://docs.stackstorm.com/install/). You can still
benefit from this Vagrantfile to get the Linux VM up and running: follow instructions to
install Vagrant & VirtualBox to get a Linux VM, and simply comment out the
`st2.vm.provision "shell"...` section in your `Vagrantfile` before running `vagrant up`.

## Common problems and solutions

#### IP Conflicts

In the event you receive an error related to IP conflict, Edit the `private_neworks` address in `Vagrantfile`, and adjust the third octet to a non-conflicting value. For example:

```
    # Configure a private network
    st2.vm.network :private_network, ip: "192.168.16.21"
```


#### Mounts

Sometimes after editing or adding NFS mounts via `config.vm.synced_folder`,and firing `vagrant up` or `vagrant reload`, you may see this:

```
==> st2express: Exporting NFS shared folders...
NFS is reporting that your exports file is invalid. Vagrant does
this check before making any changes to the file. Please correct
the issues below and execute "vagrant reload":

exports:3: path contains non-directory or non-existent components: /Volumes/Repo/st2
exports:3: path contains non-directory or non-existent components: /Volumes/Repo/st2contrib
exports:3: path contains non-directory or non-existent components: /Volumes/Repo/st2incubator
exports:3: no usable directories in export entry
exports:3: using fallback (marked offline): /Volumes/Repo
```
FIX: Remove residuals from `/etc/exports` file on the host machine, and do `vagrant reload` again.


## Contribute

1. Fork it
1. Create your feature branch (git checkout -b my-new-feature)
1. Commit your changes (git commit -am 'Add some feature')
1. Push to the branch (git push origin my-new-feature)
1. Create new Pull Request


## License

|  |  |
| ------ | --- |
| **Author:** | Mrigesh Priyadarshi |
| **Copyright:** | [Mrigesh Priyadarshi](mailto:mrigeshpriyadarshi@gmail.com) |
| **License:** | Apache License, Version 2.0 |

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

See [LICENSE](license) for more information.
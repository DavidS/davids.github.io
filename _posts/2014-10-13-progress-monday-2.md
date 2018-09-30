---
title: 'Ansible and Salt'
category: puppet
tags: puppet devops ansible salt
---

Motivated by [Florian
Haas](https://plus.google.com/110443614427234590648/posts/629TDFGcCjt) I've
looked into [Ansible](http://docs.ansible.com/) and [Salt
Stack](http://docs.saltstack.com/en/latest/). After spending most of the day
reading the docs, I've achieved a certain grasp of the functionality of both
systems. Here's my summary.

## Commonalities

> Ansible and Salt use some common concepts and share a surprising number of
> technical details that I've put them up here, to be able to concentrate on
> the unique features below.

  * Implementation language: implemented in python.
  * Syntax and templating: YAML files and the Jinja templating language are
    used as basic building blocks for their instructions. The underlying data
    model is totally different though.
  * Abstraction layer: A library of modules provides target environment
    independent commands to manage resources like services and packages. This
    is equivalent to puppet's resource abstraction layer.
  * Execution: Both provide central and decentral execution modes similar to
    puppet's agent and apply faces.
  * Ad-hoc commands: Contrary to puppet, both allow arbitrary commands to be
    executed immediately on the managed hosts. Both can use their respective
    command language to build these commands.
  * Facts Discovery/Inventory: Both provide ways to collect and use information
    from the managed systems.
  * Homogeneous Systems: Both documents focus on the homogeneous system
    use-case. Surely both do have the possibility to react to differences of
    the underlying system via facts and conditionals, but are light on the
    topic of actually implementing this. Given this is my first reading, I
    might just have missed it.

## Ansible

Ansible implements a scripting based approach. Every *task* is a series of
steps that have target-specific implementations. For example, there is a
`service` task, which has similar functionality to the `service` type of
Puppet. Contrary to Puppet, Ansible's *Playbooks* are evaluated top-to-bottom
and executed in order, except for so-called *handlers* which can be triggered
by certain events in the execution. They have the same purpose as
`notify`/`subscribe` in Puppet.

Ansible executions are always triggered from a central server and require only
a ssh connection to, and a python installation on the target hosts. I guess
local-only executions are possible too, but would not make use of Ansible's
power. Ansible can use arbitrary users to connect to hosts and use sudo as
required to affect the managed host. Together with the possibility to input
passphrases during the Ansible run, this could possibly used to manage
certified, audited, or qualified systems where Ansible is not covered by the
certification process, while still fulfilling the auditing requirements. That
makes my head spin. Also I'd question the sanity of
organizations/certifications who require such hoop-jumping, but I digress!

Playbooks can be modularized and parameterize easily. Puppet's (artificial?)
distinction between classes and defines is not required as the complete
playbook is executed serially and can intentionally modify the same resource
many times. *Task include files* in particular have the role of defines. They
can have parameters and be included multiple times with different arguments on
the same host. This leads nicely to something puppet modules (and, no, I do not
think that's a language issue, just something I noticed that the Ansible docs
introduce as a "normal" use case) are notoriously bad at, namely multi-instance
installations.

Finally, something that is really nifty, is Ansible's *delegations*. Each task
can individually be executed not on the current target host, but delegated to
some other host. For example, a Wordpress task running on the php backend host
could delegate the database setup to a mysql host and configure SSL offload on
a http frontend server. The whole process would still be a unified
top-to-bottom task description. Perhaps some includes, but nevertheless a
single flow, executed and sequenced properly.

The documentation is well organized and has a good flow to it. Reading it
cover-to-cover went smoothly from introductory material to advanced topics.

## Salt

> Salt has the severe disadvantage of having to contend against the very solid
> impression Ansible's docs made earlier. Also, leading the reader astray from
> the documentation frontpage with a string of "Getting Started" and "Continue
> reading here" links that leave you stranded in the middle of the
> documentation while skipping some basic material, didn't help my reception of
> the content.
> > Did I mention that there is a link to the Table of Contents in the
> > navigation sidebar that is not always available?
> > [What?](https://www.youtube.com/watch?v=70uTOoEzBJk)

Salt has an agent (*minion* is a great name for that) running on each managed
host. Communication happens over a ZeroMQ messagebroker hosted in the central
master process. Contrary to Ansible this causes a whole chapter about properly
firewalling the various Salt parts. On the other hand, it presumably reduces
communications overhead by orders of magnitude.

Salt lets you define states (*SLS*) which can then be applied as necessary.
This feels much more puppet-like than Ansible's sequential execution model.
Since this is state based and not execution based, the same dependency
management as puppet is required.

Configuring multiple instances of the same thing is explicitly implemented by
using jinja templating and loops over arguments or other data.

Cross-node configurations are implemented by querying the various datastores
implemented in salt, which feed from the inventorised data, external inputs and
applied states.

## Conclusions and personal opinion

This can only be a very shallow review, as I was only reading the official docs
of both projects. Still, I think it already shows the fundamental differences
between the systems.

Personally, I like Ansible's documentation, syntax, and execution model better.

---
title: '#progressmonday'
tags: programming rails productivity
---

Since coming back from vacation, my mondays were quite unstructured, as
customer's mondays seem to be mainly occupied by working up whatever the
weekend whashed up. To get a better handle on these days, I've recently
installed the
[ClearFocus](https://play.google.com/store/apps/details?id=personal.andreabasso.clearfocus)
app to do a bit of [timeboxing](https://en.wikipedia.org/wiki/Timeboxing). The
goal is to have a bit more of a structure when working alone and do not burn
through the day in a single go.

Here's a list of (public)
[pomodori](https://en.wikipedia.org/wiki/Pomodoro_Technique) I did today.

# 1. rails admin area

According to the
[designs](https://github.com/DavidS/hrdb/tree/4cb3af2c08b50c8a93b2d26ed4cedbf8916c55d2/Templates/bootstrap-3.2.0-dist),
the [hrdb app](https://github.com/DavidS/hrdb) has a separate administrative
area under `/admin` to keep those tasks separated from the common workflows.
I've
[started](https://github.com/DavidS/hrdb/commit/4cb3af2c08b50c8a93b2d26ed4cedbf8916c55d2)
by moving all routes to the `PeopleController` into the `:admin`
[scope](http://guides.rubyonrails.org/routing.html#controller-namespaces-and-routing)
and adding a `admin#index` route to a separate `AdminController`. In the
[application
layout](https://github.com/DavidS/hrdb/blob/4cb3af2c08b50c8a93b2d26ed4cedbf8916c55d2/app/views/layouts/application.html.erb)
I added a simple `menu_item` to the admin area as a placeholder.

Thanks to rails' routing intelligence, the original "People" link still works
just fine, but now points to the new path.

I've used the second half of the pomodoro to investigate authorization
solutions. As the application will require multiple roles with different
authorization levels, I think
[declarative\_authorization](https://github.com/stffn/declarative_authorization)
will be a good match.

> Note: I've not started a new pomodoro for writing this up, but spend quite a
> while typing everything up and adding all the links. Need to be more careful
> with that.

# 2. Ansible and Salt

Motivated by [Florian
Haas](https://plus.google.com/110443614427234590648/posts/629TDFGcCjt) I've
looked into [Ansible](http://docs.ansible.com/) and [Salt
Stack](http://docs.saltstack.com/en/latest/). After spending most of the day
reading the docs, I've archieved a certain grasp of the workflow and
functionality of both systems. I've put some [notes on a separate
page](2014-10-13-progress-monday-2) to make it available on [Planet
Puppet](http://www.planetpuppet.org/) without the rails
and personal stuff from here.

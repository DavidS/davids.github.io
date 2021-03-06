---
title: 'Mono Tips of the day'
tags: mono programming
---

Doing some research on the current state of
[mono](http://www.mono-project.com), collecting the findings:

* Current stable is 3.10.0.
* Xamarin's [Linux
  packages](http://www.mono-project.com/docs/getting-started/install/linux/)
  are currently at mono 3.10, and monodevelop 5.5.
* [T4](http://msdn.microsoft.com/en-us/library/bb126445.aspx) templates are
  "supported" by MonoDevelop, but [build-time
  refreshing](http://msdn.microsoft.com/en-us/library/ee847423.aspx) is not.
  There is a [separate
  tool](https://forums.xamarin.com/discussion/comment/25616/#Comment_25616)
  that can be used to evaluate T4 templates under mono(develop). This requires
  listing all .tt files, maybe viable via custom msbuild fragment.

There's even guidance from Microsoft on [running ASP.NET vNext on docker on
Azure](http://msopentech.com/blog/2014/11/07/creating-asp-net-vnext-docker-container-using-mono-2/).
[O tempora o mores!](https://en.wikipedia.org/wiki/O_tempora_o_mores!)

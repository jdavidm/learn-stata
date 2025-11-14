---
layout: page
title: About
---

<a href="{{ site.baseurl}}/about">
<i class="fa fa-group fa-fw"></i> About Us</a>

{% if site.github.repo == 'https://github.com/jdavidm/learn-stata' %}
Contact Us
: <a href="{{ site.github.repo }}"> 
  <i class="fa fa-github fa-fw"></i> On GitHub</a>
: <a href="mailto:{{ site.email }}"> 
  <i class="fa fa-envelope fa-fw"></i> Via Email</a>
{% else %}
Contact Us
: About Course Materials: <a href="{{ site.github.repo }}"> 
  <i class="fa fa-github fa-fw"></i> On GitHub</a> | 
  <a href="mailto:{{ site.email }}"> 
  <i class="fa fa-envelope fa-fw"></i> Via Email</a>
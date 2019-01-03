---
layout: page
title: Posts
published: True
---

{% for post in site.posts %}
[post.title | textilize]({{ post.url }})
{{ post.date | date_to_string }}
{% endfor %}

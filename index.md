My development log. Read at your own risk! Please send comments to me [by mail](mailto:david@black.co.at) or [via Twitter @dev\_el\_ops](https://twitter.com/dev_el_ops).

|--|--|--|
|other places:|[github](https://github.com/DavidS/)|[stackoverflow](https://careers.stackoverflow.com/david-schmitt)|
| | [twitter](https://twitter.com/dev_el_ops)| [linked.in](https://www.linkedin.com/in/davidschmitt) |
| | [CV](cv/) | |

<!-- [xing](https://www.xing.com/profile/David_Schmitt5) -->

# Latest Blog Posts

<ul>
  {% for post in site.posts %}
    <li>
      <a href="{{ post.url | relative_url }}">{{ post.date | date: "%Y, %-d %B" }}: {{ post.title }}</a>
    </li>
  {% endfor %}
</ul>

# Tags

<ul>
  {% for tag in site.tags %}
    <li>{{ tag[0] }}
      <ul>
        {% for post in tag[1] %}
          <li><a href="{{ post.url | relative_url }}">{{ post.date | date: "%Y, %-d %B" }}: {{ post.title }}</a></li>
        {% endfor %}
      </ul>
    </li>
  {% endfor %}
</ul>

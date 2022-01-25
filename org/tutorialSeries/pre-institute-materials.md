---
layout: redirected
sitemap: false
permalink: pre-institute-materials/
---
## Pre-Institute Materials


{% for member in site.data.tutorialSeries %}

{% if member.name contains 'Pre-Institute' %}

  <article class="tutorial-series">
            <a href="{{ site.baseurl }}/tutorial-series/{{ member.slug }}" class="list-group-item">
                <h2 class="list-group-item-heading">{{ member.name  }}</h2>
            <p>{{ member.description }}</p>
            </a>
   </article>   
   {% endif %}   
{% endfor %}

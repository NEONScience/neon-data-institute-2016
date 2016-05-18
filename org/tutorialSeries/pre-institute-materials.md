---
layout: tutorial-series-landing
title: 'Pre-institute Materials'
categories: [tutorial-series]
tutorialSeriesName: pre-institute-materials
permalink: pre-institute-materials/
image:
  feature: data-institute-2016.png
  credit:
  creditlink:
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

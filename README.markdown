Redmine Charts
==============

Add to Redmine several useful charts which show project statistics.

## Instalation

Download the sources and put them to your vendor/plugins folder.

    $ cd {REDMINE_ROOT}
    $ git clone git://github.com/mszczytowski/redmine_charts.git vendor/plugins/redmine_charts

Install OpenFlashChart plugin. 

    $ ./script/plugin install git://github.com/pullmonkey/open_flash_chart.git

Run Redmine and have a fun!

## Charts

### Burndown

Chart shows timeline with estimated, logged and remaining hours changes.

![Screenshot of hours chart](http://farm4.static.flickr.com/3142/3049597577_f9337729b8_o.png)

### Logged hours ratio

Chart shows how much hours was logged, grouping by users, issues, activities or categories, is ratio to total logged hours. It is possible to limit data for given user, issue, category or activity.

![Screenshot of groups chart](http://farm4.static.flickr.com/3286/3047776453_3d6a152a25_o.png)

### Logged hours timeline

Chart shows how much hours was logged in given time period. It is possible to group by and limit to given user, issue, category or activity.

![Screenshot of hours chart](http://farm4.static.flickr.com/3021/3047776559_bab9604c84_o.png)

### Logged hours deviations

Chart shows, for every issue, logged and remaining hours in the ratio of estimated hours.

![Screenshot of deviations chart](http://farm4.static.flickr.com/3176/3050436036_bcd504a8b5_o.png)

Redmine Charts
==============

Plugin for Redmine to show Your projects' charts.

## Instalation

Download the sources and put them to your vendor/plugins folder.

    $ cd {REDMINE_ROOT}
    $ git clone git://github.com/mszczytowski/redmine_charts.git vendor/plugins/redmine_charts

Install OpenFlashChart plugin. 

    $ ./script/plugin install git://github.com/pullmonkey/open_flash_chart.git

Run Redmine and have a fun!

## Charts

### Burndown

Chart shows timeline with estimated, logged and remaining hours.

![Screenshot of hours chart](http://farm4.static.flickr.com/3487/3219872709_03a137e740_o.jpg)

### Logged hours ratio

Chart shows how many hours was logged proportional to total logged ones, grouping and limiting them by users, issues, activities or categories.

![Screenshot of groups chart](http://farm4.static.flickr.com/3313/3220723922_64540005a0_o.jpg)

### Logged hours timeline

Chart shows timeline with logged hours, grouping and limiting them by users, issues, activities or categories.

![Screenshot of hours chart](http://farm4.static.flickr.com/3112/3220723804_2b274e7e2f_o.jpg)

### Logged hours deviations

Chart shows, for every estimated issue, logged and remaining hours in the ratio of estimated ones.

![Screenshot of deviations chart](http://farm4.static.flickr.com/3441/3219872389_4f1d105c1d_o.jpg)

## Issues and feature requerts

See [Redmine Chart LightHouse page](http://mszczytowski.lighthouseapp.com/projects/20445-redmine-chart/overview).

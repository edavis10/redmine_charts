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

Timeline with estimated, logged and remaining hours.

![Screenshot of hours chart](http://farm4.static.flickr.com/3487/3219872709_03a137e740_o.jpg)

### Logged hours ratio

Number of hours were logged proportional to total total, grouped and filtered by users, issues, activities or categories.

![Screenshot of groups chart](http://farm4.static.flickr.com/3313/3220723922_64540005a0_o.jpg)

### Logged hours timeline

Timeline with logged hours, grouped and filtered by users, issues, activities or categories.

![Screenshot of hours chart](http://farm4.static.flickr.com/3112/3220723804_2b274e7e2f_o.jpg)

### Logged hours deviations

Ratio of logged and remaining hours to estimated hours for each estimated issue.

![Screenshot of deviations chart](http://farm4.static.flickr.com/3441/3219872389_4f1d105c1d_o.jpg)

## Issues and feature requerts

See [Redmine Chart LightHouse page](http://mszczytowski.lighthouseapp.com/projects/20445-redmine-chart/overview).

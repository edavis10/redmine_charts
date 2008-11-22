Redmine Charts
==============

Add to Redmine several useful charts which show project statistics.

## Instalation

Download the sources and put them to your vendor/plugins folder.

    $ cd {REDMINE_ROOT}
    $ git clone git://github.com/mszczytowski/redmine_charts.git vendor/plugins/redmine_charts

Install OpenFlashChart plugin. 

    $ ./script/plugin install git://github.com/pullmonkey/open_flash_chart.git

Migrate database.

    $ rake db:migrate_plugins

Run Redmine and have a fun!

## Charts

### Logged hours

Shows total logged hours per issue, user, category or activity.

![Screenshot of groups chart](http://farm4.static.flickr.com/3286/3047776453_3d6a152a25_o.png)

### Logged hours timeline

Shows logged hours per day, week or month and groups it per issue, user, category or activity. 

![Screenshot of hours chart](http://farm4.static.flickr.com/3021/3047776559_bab9604c84_o.png)

### Burndown

Shows estimated, logged and remaining hours.

![Screenshot of hours chart](http://farm4.static.flickr.com/3142/3049597577_f9337729b8_o.png)

### Deviations

Compares estimated to logged hours.

![Screenshot of deviations chart](http://farm4.static.flickr.com/3176/3050436036_bcd504a8b5_o.png)
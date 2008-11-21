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

![Screenshot of groups chart](http://lh3.ggpht.com/_xBL3xbJZeic/SSbctJTklLI/AAAAAAAADsg/yz4YFrJATcU/groups.png)

### Logged hours timeline

Shows logged hours per day, week or month and groups it per issue, user, category or activity. 

![Screenshot of hours chart](http://lh6.ggpht.com/_xBL3xbJZeic/SSbctIcT-0I/AAAAAAAADso/XftxzImpT1I/hours.png)

### Burndown

Shows estimated, logged and remaining hours.

![Screenshot of hours chart](http://lh5.ggpht.com/_xBL3xbJZeic/SSbcsweTwFI/AAAAAAAADsY/lL7nHteCSjs/burndown.png)

## Planned charts

### Deviation

Compares estimated to logged hours per issue, user, category or activity.

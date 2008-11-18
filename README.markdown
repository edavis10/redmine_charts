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

### Logged hours

Shows total logged hours per issue, user, category or activity.

![Screenshot of groups chart](master/mages/groups.png?raw=true)

### Logged hours timeline

Shows logged hours per day, week or month and groups it per issue, user, category or activity. 

![Screenshot of hours chart](master/images/hours.png?raw=true)

## Planned charts

### Burndown

Shows estimated, logged and remaining hours.

### Deviation

Compares estimated to logged hours per issue, user, category or activity.

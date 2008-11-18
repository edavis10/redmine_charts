= Redmine Charts

Add to Redmine several useful charts which show project statistics.

= Instalation

Download the sources and put them to your vendor/plugins folder.

$ cd {REDMINE_ROOT}
$ git clone git://github.com/mszczytowski/redmine_charts.git vendor/plugins/redmine_charts

Install OpenFlashChart plugin. 

$ ./script/plugin install git://github.com/pullmonkey/open_flash_chart.git

Run Redmine and have a fun!

= Charts

* groups - show sum of logged hours per issue, user or activity
* hours - show sum of logged hours per day, week or month
* burndown - estimated, logged and remaining hours

= Planned charts

* deviation - compare estimated to logged hours per issue, user or activity

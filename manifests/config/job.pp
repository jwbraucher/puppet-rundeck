# License::   MIT

# == Define rundeck::config::job
#
# This definition is used to create Rundeck jobs
#
# === Parameters
#
# [*ensure*]
#   Set present or absent to add or remove the job
#
# [*project*]
#   The project where the job should be added or deleted
#
# [*format*]
#   When ensure=present, the job definition format. Must be yaml or xml (default is yaml)
#
# [*job_definition*]
#   When ensure=present, path to template (erb) file containing the job definition
#
# [*title*]
#   When ensure=absent, the name of the job to delete
#
# [*group*]
#   When ensure=absent, the group of the job to delete
#
# === Examples
#
# Create a job:
#
# rundeck::config::job { 'my-job':
#  name   => 'my-job',
#  job_definition => 'my_module/my_job.yaml'
# }
#
define rundeck::config::job(
  String $project,
  String $job_definition = '',
  String $format = 'yaml',
  String $group = '',
  Enum['present', 'absent'] $ensure = 'present',
) {

  include rundeck::jobs

  $jobs_dir = "${rundeck::jobs::jobs_dir}"
  $job_filename = inline_template('<%= File.basename(@job_definition) %>')

  if $ensure == 'present' {

    # create job
    file { "$title":
      ensure  => file,
      path    => "${jobs_dir}/${job_filename}",
      content => template($job_definition),
    }
    ~> exec { "$title":
      path => '/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin',
      command => "rd jobs load --remove-uuids --duplicate update --format ${format} --project ${project} --file ${jobs_dir}/${job_filename}",
      user => "${rundeck::user}",
      environment => [ "HOME=${rundeck::rdeck_home}" ],
      refreshonly => true,
      tries => 300,
      try_sleep => 1
    }

  }
  elsif $ensure == 'absent' {

    exec { "$title":
      path => '/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin',
      command => "rd jobs purge --confirm --project ${project} --jobxact ${title} --groupxact ${group}",
      user => "${rundeck::user}",
      environment => [ "HOME=${rundeck::rdeck_home}" ],
      refreshonly => true,
      tries => 90,
      try_sleep => 1
    }

  }

}

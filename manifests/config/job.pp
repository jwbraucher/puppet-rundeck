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
#   Required when ensure=present. The path to the template (erb) file containing the job definition
#
# [*title*]
#   The name of the job to add or delete
#
# [*job_name*]
#   Use this to customize the job name, or to have two jobs with the same name (e.g. group1/foo and group2/foo)
#   (defaults to $title)
#
# [*group*]
#   The group of the job to add or delete (defautls to an empty string, which means the root group)
#
# === Examples
#
# Create a job:
#
# rundeck::config::job { 'foo-job':
#  job_name   => 'Foo',
#  group => 'Operations',
#  job_definition => 'my_module/foo-job.yaml'
# }
#
# rundeck::config::job { 'delete-bar-job':
#  job_name   => 'Bar',
#  group => 'Operations',
#  ensure => absent
# }
#
#
define rundeck::config::job(
  String $job_name = $title,
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
    file { "$job_name":
      ensure  => file,
      path    => "${jobs_dir}/${job_filename}",
      content => template($job_definition),
    }
    -> exec { "$job_name":
      path => '/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin',
      command => "rd jobs load --remove-uuids --duplicate update --format ${format} --project ${project} --file ${jobs_dir}/${job_filename}",
      user => "${rundeck::user}",
      environment => [ "HOME=${rundeck::rdeck_home}" ],
      tries => 300,
      try_sleep => 1,
      onlyif => "rd jobs list --project ${project} --groupxact ${group} --jobxact ${job_name} | grep -q '0 Jobs'"
    }

  }
  elsif $ensure == 'absent' {

    exec { "$job_name":
      path => '/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin',
      command => "rd jobs purge --confirm --project ${project} --jobxact ${job_name} --groupxact ${group}",
      user => "${rundeck::user}",
      environment => [ "HOME=${rundeck::rdeck_home}" ],
      tries => 90,
      try_sleep => 1,
      onlyif => "rd jobs list --project ${project} --groupxact ${group} --jobxact ${job_name} | grep -q '1 Jobs'"
    }

  }

}

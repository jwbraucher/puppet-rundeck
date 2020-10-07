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
#   The project to which the job should be added
#
# [*job_definition*]
#   Path to template (erb) file containing the job definition
#
# [*format*]
#   Job definition format, must be yaml or xml (default is yaml)
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
  String $job_definition,
  String $format = 'yaml',
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
      refreshonly => true
    }

  }
  elsif $ensure == 'absent' {

    # delete job
    file { "$title":
      ensure  => absent,
      path    => "${jobs_dir}/${job_filename}"
    }
    # ~> exec { "$title":
    #   path => '/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin',
    #   command => "rd jobs purge --project ${project} <QUERY PARAMS>"
    #   user => "${rundeck::user}",
    #   refreshonly => true

  }

}

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
#
# [*job_definition*]
#
# === Examples
#
# Create a job:
#
# rundeck::config::job { 'my-job':
#  name   => 'my-job'
#  job_definition => '
# }
#
define rundeck::config::job(
  String $project,
  String $job_definition,
  Enum['present', 'absent'] $ensure = 'present',
) {

  $job_filename = inline_template('<%= File.basename(@job_definition) %>')

  if $ensure == 'present' {

    # create job
    file { "$title":
      ensure  => file,
      path    => "${job_dir}/${job_filename}",
      content => template($job_definition),
    }
    ~> exec { "$title":
      path => '/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin',
      command => "curl -k -F xmlBatch=@${job_dir}/${job_filename} -H 'Application/yaml' ${rundeck::config::grails_server_url}/api/35/project/${project}/jobs/import?format=yaml&uuidOption=remove&dupeOption=update",
      refreshonly => true
    }

  }
  elsif $ensure == 'absent' {

    # delete job
    file { "$title":
      ensure  => absent,
      path    => "${job_dir}/${job_filename}"
    }

  }

}

class rundeck::jobs {

  # pre-create jobs directory
  $jobs_dir = "${rundeck::rdeck_home}/jobs"
  ensure_resource(file, $jobs_dir, {'ensure'   => 'directory'})

  # create jobs
  create_resources(rundeck::config::job, $jobs)

}


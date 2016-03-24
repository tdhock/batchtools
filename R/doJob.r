doJob = function(job, measure.memory = FALSE) {
  id = job$id
  msg.start = sprintf("[job(%i): %s] Starting job with job.id=%i", id, stamp(), id)
  update = list(job.id = id, started = now(), done = NA_integer_, error = NA_character_, memory = NA_real_)
  if (measure.memory) {
    gc(reset = TRUE)
    result = capture(execJob(job))
    update$memory = sum(gc()[, 6L])
  } else {
    result = capture(execJob(job))
  }
  update$done = now()
  result$output = sprintf("[job(%i): %s] %s", id, stamp(), result$output)

  if (is.error(result$res)) {
    msg.terminated = sprintf("[job(%i): %s] Job terminated with an exception", id, stamp())
    update$error = stri_trim_both(as.character(result$res))
  } else {
    msg.terminated = sprintf("[job(%i): %s] Job terminated successfully", id, stamp())
    writeRDS(result$res, file = file.path(job$cache$file.dir, "results", sprintf("%i.rds", id)))
  }

  return(list(update = update, output = c(msg.start, result$output, msg.terminated)))
}
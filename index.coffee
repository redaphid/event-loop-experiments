GreedyOperation = require './greedy-operation'
async = require 'async'
_ = require 'lodash'

NUM_JOBS = parseInt process.argv[2]
MAX_CONCURRENT_JOBS = parseInt process.argv[3]
ACCEPTABLE_JOB_TIME = parseInt process.argv[4]

lastScheduleAdjusted = 0
jobsStarted = 0
jobs = []

console.log "Starting up. Doing #{NUM_JOBS} jobs with a max of #{MAX_CONCURRENT_JOBS} concurrently"
startTime = Date.now()

addJob =->
  return if jobsStarted >= NUM_JOBS
  return if GreedyOperation.jobsInProgress > MAX_CONCURRENT_JOBS
  startJob jobDone
  return addJob()


startJob = (callback) ->
  jobsStarted++
  greed = new GreedyOperation maxConcurrentJobs: MAX_CONCURRENT_JOBS, jobsInProgress: GreedyOperation.jobsInProgress
  greed.doWork {}, callback


_unlimited_adjustScheduling = (elapsedTime) =>
  return unless GreedyOperation.jobsInProgress > MAX_CONCURRENT_JOBS

  if elapsedTime > ACCEPTABLE_JOB_TIME * 1.25
    MAX_CONCURRENT_JOBS /= 1.25
    console.log "Jobs are taking too long. Reduced concurrent jobs to #{MAX_CONCURRENT_JOBS} "

  if elapsedTime < ACCEPTABLE_JOB_TIME / 1.25
    MAX_CONCURRENT_JOBS *= 1.25
    console.log "Jobs are faster than expected. Increased concurrent jobs to #{MAX_CONCURRENT_JOBS} "

adjustScheduling = _.throttle _unlimited_adjustScheduling, 200


printJobDone = (job) =>
  console.log
    job: job.jobNumber
    waited: job.startTime - startTime
    took: job.endTime - job.startTime
    maxConcurrent: _.round job.maxConcurrentJobs, 4
    loadAtStart: job.jobsInProgress

jobDone = (error, job) =>
  elapsedTime = job.endTime - job.startTime
  printJobDone job
  adjustScheduling elapsedTime
  jobs.push job
  addJob()
  allDone()

printJobs = ->
  endTime = Date.now()
  times = _.map jobs, (job) => job.endTime - job.startTime
  wait = _.map jobs, (job) => job.startTime - startTime
  console.log "\nDone!\n"
  console.log
    jobs: jobs.length
    elapsed: endTime - startTime
    avgTime: _.sum(times)/times.length
    avgWait: _.sum(wait)/times.length
    maxConcurrent: MAX_CONCURRENT_JOBS
    targetTime: ACCEPTABLE_JOB_TIME

allDone = _.after(printJobs, NUM_JOBS)

addJob()

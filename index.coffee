GreedyOperation = require './greedy-operation'
async = require 'async'
_ = require 'lodash'

NUM_JOBS = process.argv[2]
MAX_CONCURRENT_JOBS = process.argv[3]
ACCEPTABLE_JOB_TIME = 1000

lastScheduleAdjusted = 0
jobsStarted = 0
results = []

console.log "Starting up. Doing #{NUM_JOBS} jobs with a max of #{MAX_CONCURRENT_JOBS} concurrently"
startTime = Date.now()

addJob =->
  return if jobsStarted >= NUM_JOBS
  return if GreedyOperation.jobsInProgress > MAX_CONCURRENT_JOBS
  startJob jobDone
  addJob()


startJob = (callback) ->
  jobsStarted++
  greed = new GreedyOperation
  greed.doWork {}, callback


adjustScheduling = (elapsedTime) =>
  return unless (Date.now() - lastScheduleAdjusted) > 200

  if elapsedTime > ACCEPTABLE_JOB_TIME * 1.25
    lastScheduleAdjusted = Date.now()
    MAX_CONCURRENT_JOBS /= 1.25
    console.log "Jobs are taking too long. Reduced concurrent jobs to #{MAX_CONCURRENT_JOBS} "

  if elapsedTime < ACCEPTABLE_JOB_TIME / 1.25
    lastScheduleAdjusted = Date.now()
    MAX_CONCURRENT_JOBS *= 1.25
    console.log "Jobs are faster than expected. Increased concurrent jobs to #{MAX_CONCURRENT_JOBS} "



jobDone = (error, result) =>
  elapsedTime = result.endTime - result.startTime
  adjustScheduling elapsedTime
  results.push result
  addJob()
  allDone()

printResults = ->
  endTime = Date.now()
  console.log "#{results.length} jobs done in #{endTime - startTime}ms"
  times = _.map results, (result) => result.endTime - result.startTime
  console.log "Average job time: #{_.sum(times)/times.length}ms"
  console.log "max concurrent jobs: #{MAX_CONCURRENT_JOBS}"

allDone = _.after(printResults, NUM_JOBS)

addJob()

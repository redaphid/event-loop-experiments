GreedyOperation = require './greedy-operation'
async = require 'async'
_ = require 'lodash'

startJob = (callback) ->  
  greed = new GreedyOperation
  greed.doWork {}, callback


jobsDone = (error, results) ->
  console.log "#{results.length} jobs done!"
  console.log JSON.stringify results, null, 2
  times = _.map results, (result) => result.endTime - result.startTime
  console.log "Average job time: #{_.sum(times)/times.length}ms"


NUM_JOBS = process.argv[2]
jobs = []
jobs.length = NUM_JOBS
_.fill jobs, startJob

async.parallel jobs, jobsDone

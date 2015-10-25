GreedyOperation = require './greedy-operation'

greed = new GreedyOperation

greed.doWork {}, (error, result) ->
  reportGreed result


reportGreed = (result) ->
  console.log "Job took #{result.endTime - result.startTime}ms"

GreedyOperation = require './greedy-operation'

greed = new GreedyOperation

greed.doWork {}, (error, result) =>
  console.log "result was", result

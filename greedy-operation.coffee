_ = require 'lodash'
async = require 'async'

class GreedyOperation
  constructor: (options={})->
    {@arrayLength, @arrayCount, @offset} = options
    @arrayLength ?= 200
    @offset ?= 10

  generateMatrix: =>
    matrix = []
    rangeArray = _.range @offset, @arrayLength + @offset

    _.map rangeArray, (element) => _.shuffle rangeArray

  doWork: (job, callback=->) =>
    startTime = Date.now()
    jobNumber = GreedyOperation.jobCount++
    GreedyOperation.jobsInProgress++

    console.log "job #{jobNumber} started"

    matrix = @generateMatrix()
    jobs = _.zipWith matrix, matrix, (col1, col2) =>
        (callback) => @asyncMultiplyColumns jobNumber, col1, col2, callback

    async.series jobs, (error, results) =>
      GreedyOperation.jobsInProgress--
      result =
        sum: _.sum _.flatten results
        startTime: startTime
        endTime: Date.now()

      console.log "job #{jobNumber} ended in #{result.endTime - result.startTime}ms"

      callback null, result

  asyncMultiplyColumns: (jobNumber, column1, column2, callback=->) =>
    # console.log "job #{jobNumber} multiplying..."
    result = _.zipWith column1, column2, Math.pow
    _.defer => callback null, result

  @jobCount: 0
  @jobsInProgress: 0

module.exports = GreedyOperation

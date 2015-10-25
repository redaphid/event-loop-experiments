_ = require 'lodash'
async = require 'async'

class GreedyOperation
  constructor: (options={})->
    {@arrayLength, @arrayCount, @offset} = options
    @arrayLength ?= 100
    @arrayCount ?= 1000
    @offset ?= 10
  doWork: (job, callback=->) =>
    startTime = Date.now()
    matrix = []
    jobs = []
    rangeArray = _.range @offset, @arrayLength + @offset
    for column in [0..@arrayLength]
      matrix.push _.shuffle rangeArray

    _.each matrix, (column1) =>
      _.each matrix, (column2) =>
        jobs.push (callback) => @asyncMultiplyColumns column1, column2, callback

    async.parallel jobs, (error, results) =>
      result =
        sum: _.sum _.flatten results
        startTime: startTime
        endTime: Date.now()

      callback null, result

  asyncMultiplyColumns: (column1, column2, callback=->) =>
    result = _.zipWith column1, column2, Math.pow
    _.defer => callback null, result

module.exports = GreedyOperation

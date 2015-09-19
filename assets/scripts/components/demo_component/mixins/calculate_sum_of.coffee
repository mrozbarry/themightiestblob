
module.exports =
  calculateSumOf: (numbers) ->
    _.reduce numbers, (number, sum) ->
      sum + number

  formulaOfSum: (numbers) ->
    sum = @calculateSumOf(numbers)
    numbers.join(' + ') + " = #{sum}"


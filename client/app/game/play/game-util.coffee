class GameMath

  @PI = 3.14159

  @rad2deg: (rad) ->
    rad * 57.29578

  @deg2rad: (deg) ->
    deg * 0.01745

  @clamp: (num, min, max) ->
    if num < min
      return min
    if num > max
      return max
    return num

exports.GameMath = GameMath
module Example exposing (..)

import Expect exposing (Expectation)
import Test exposing (..)


suite : Test
suite =
    test "Change me" <| \_ -> 1 + 1 |> Expect.equal 2

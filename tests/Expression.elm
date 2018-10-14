module Expression exposing (equalSelectList, fuzzSegments)

import Expect exposing (Expectation)
import Fuzz exposing (int, list)
import Test exposing (..)
import Types exposing (..)


equalSelectList : List a -> a -> List a -> SelectList a -> Expectation
equalSelectList before a after selectList =
    Expect.equal ( before, a, after ) (toTuple selectList)


fuzzSegments : String -> (List Int -> Int -> List Int -> Expectation) -> Test
fuzzSegments =
    fuzz3 (list int) int (list int)

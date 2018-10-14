module Expression exposing
    ( equalJustSelectList
    , equalSelectList
    , fuzzSegments
    , lengthFuzz
    )

import Expect exposing (Expectation)
import Fuzz exposing (int, list, tuple)
import Test exposing (..)
import Types exposing (..)


equalSelectList : List a -> a -> List a -> SelectList a -> Expectation
equalSelectList before a after selectList =
    Expect.equal ( before, a, after ) (toTuple selectList)


equalJustSelectList : List a -> a -> List a -> Maybe (SelectList a) -> Expectation
equalJustSelectList before a after selectList =
    Expect.equal (Just ( before, a, after )) (Maybe.map toTuple selectList)


fuzzSegments : String -> (List Int -> Int -> List Int -> Expectation) -> Test
fuzzSegments =
    fuzz3 (list int) int (list int)


lengthFuzz : String -> (List Int -> ( Int, Int ) -> List Int -> Expectation) -> Test
lengthFuzz =
    fuzz3 (list int) (tuple ( int, int )) (list int)

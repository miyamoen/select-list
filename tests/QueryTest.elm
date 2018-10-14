module QueryTest exposing (query)

import Expect exposing (Expectation)
import Expression exposing (..)
import Fuzz exposing (int, list)
import Query exposing (..)
import Test exposing (..)
import Types exposing (..)


query : Test
query =
    describe "Query"
        [ fuzzSegments "isHead" <|
            \_ a after ->
                fromLists [] a after
                    |> isHead
                    |> Expect.true "Expected selected is head."
        , fuzzSegments "isLast" <|
            \before a _ ->
                fromLists before a []
                    |> isLast
                    |> Expect.true "Expected selected is last."
        , fuzz int "isSingle" <|
            \a ->
                fromLists [] a []
                    |> isSingle
                    |> Expect.true "Expected select list has single value."
        , fuzzSegments "length" <|
            \before a after ->
                fromLists before a after
                    |> length
                    |> Expect.equal (List.length before + 1 + List.length after)
        , fuzzSegments "beforeLength" <|
            \before a after ->
                fromLists before a after
                    |> beforeLength
                    |> Expect.equal (List.length before)
        , fuzzSegments "afterLength" <|
            \before a after ->
                fromLists before a after
                    |> afterLength
                    |> Expect.equal (List.length after)
        ]

module SelectTest exposing
    ( afterIfTest
    , beforeIfTest
    , byTest
    , selectTest
    , whileLoopByTest
    )

import Expect exposing (Expectation)
import Expression exposing (..)
import Fuzz exposing (int, list, tuple)
import Query exposing (isHead, isLast)
import Select exposing (..)
import Test exposing (..)
import Types exposing (..)


afterIfTest : Test
afterIfTest =
    describe "afterIf"
        [ test "found" <|
            \_ ->
                fromLists [ 1, 2, 3 ] 4 [ 5, 6, 7 ]
                    |> afterIf ((==) 6)
                    |> equalJustSelectList [ 1, 2, 3, 4, 5 ] 6 [ 7 ]
        , test "not found" <|
            \_ ->
                fromLists [ 1, 2, 3 ] 4 [ 5, 6, 7 ]
                    |> afterIf ((==) 2)
                    |> Expect.equal Nothing
        ]


beforeIfTest : Test
beforeIfTest =
    describe "beforeIf"
        [ test "found" <|
            \_ ->
                fromLists [ 1, 2, 3 ] 4 [ 5, 6, 7 ]
                    |> beforeIf ((==) 2)
                    |> equalJustSelectList [ 1 ] 2 [ 3, 4, 5, 6, 7 ]
        , test "not found" <|
            \_ ->
                fromLists [ 1, 2, 3 ] 4 [ 5, 6, 7 ]
                    |> beforeIf ((==) 6)
                    |> Expect.equal Nothing
        ]


byTest : Test
byTest =
    describe "by"
        [ test "+2" <|
            \_ ->
                fromLists [ 1, 2, 3 ] 4 [ 5, 6, 7 ]
                    |> by 2
                    |> equalJustSelectList [ 1, 2, 3, 4, 5 ] 6 [ 7 ]
        , test "-1" <|
            \_ ->
                fromLists [ 1, 2, 3 ] 4 [ 5, 6, 7 ]
                    |> by -1
                    |> equalJustSelectList [ 1, 2 ] 3 [ 4, 5, 6, 7 ]
        , test "-2" <|
            \_ ->
                fromLists [ 1, 2, 3 ] 4 [ 5, 6, 7 ]
                    |> by -2
                    |> equalJustSelectList [ 1 ] 2 [ 3, 4, 5, 6, 7 ]
        , test ">length" <|
            \_ ->
                fromLists [ 1, 2, 3 ] 4 [ 5, 6, 7 ]
                    |> by 8
                    |> Expect.equal Nothing
        , test "<length" <|
            \_ ->
                fromLists [ 1, 2, 3 ] 4 [ 5, 6, 7 ]
                    |> by -5
                    |> Expect.equal Nothing
        , lengthFuzz "inside" <|
            \before ( a, n ) after ->
                let
                    n_ =
                        if n > 0 then
                            remainderBy (List.length after) n

                        else
                            remainderBy (List.length before) n
                in
                fromLists before a after
                    |> by n_
                    |> Maybe.andThen (by -n_)
                    |> equalJustSelectList before a after
        , lengthFuzz "outside" <|
            \before ( a, n ) after ->
                let
                    res =
                        fromLists before a after
                            |> by
                                (if n > 0 then
                                    List.length after + n + 1

                                 else
                                    n - List.length before - 1
                                )
                in
                Expect.equal Nothing res
        ]


whileLoopByTest : Test
whileLoopByTest =
    describe "whileLoopBy"
        [ test "+2" <|
            \_ ->
                fromLists [ 1, 2, 3 ] 4 [ 5, 6, 7 ]
                    |> whileLoopBy 2
                    |> equalSelectList [ 1, 2, 3, 4, 5 ] 6 [ 7 ]
        , test "-1" <|
            \_ ->
                fromLists [ 1, 2, 3 ] 4 [ 5, 6, 7 ]
                    |> whileLoopBy -1
                    |> equalSelectList [ 1, 2 ] 3 [ 4, 5, 6, 7 ]
        , test "-2" <|
            \_ ->
                fromLists [ 1, 2, 3 ] 4 [ 5, 6, 7 ]
                    |> whileLoopBy -2
                    |> equalSelectList [ 1 ] 2 [ 3, 4, 5, 6, 7 ]
        , test ">length" <|
            \_ ->
                fromLists [ 1, 2, 3 ] 4 [ 5, 6, 7 ]
                    |> whileLoopBy 8
                    |> equalSelectList [ 1, 2, 3, 4 ] 5 [ 6, 7 ]
        , test "<length" <|
            \_ ->
                fromLists [ 1, 2, 3 ] 4 [ 5, 6, 7 ]
                    |> whileLoopBy -5
                    |> equalSelectList [ 1, 2, 3, 4, 5 ] 6 [ 7 ]
        , lengthFuzz "fuzz" <|
            \before ( a, n ) after ->
                fromLists before a after
                    |> whileLoopBy n
                    |> whileLoopBy -n
                    |> equalSelectList before a after
        ]


selectTest : Test
selectTest =
    describe "Select"
        [ fuzzSegments "toHead" <|
            \before a after ->
                fromLists before a after
                    |> head
                    |> isHead
                    |> Expect.true "should be head"
        , fuzzSegments "toLast" <|
            \before a after ->
                fromLists before a after
                    |> last
                    |> isLast
                    |> Expect.true "should be last"
        , test "all" <|
            \_ ->
                fromLists [ 1, 2, 3 ] 4 [ 5, 6 ]
                    |> all
                    |> Expect.equal
                        [ fromLists [] 1 [ 2, 3, 4, 5, 6 ]
                        , fromLists [ 1 ] 2 [ 3, 4, 5, 6 ]
                        , fromLists [ 1, 2 ] 3 [ 4, 5, 6 ]
                        , fromLists [ 1, 2, 3 ] 4 [ 5, 6 ]
                        , fromLists [ 1, 2, 3, 4 ] 5 [ 6 ]
                        , fromLists [ 1, 2, 3, 4, 5 ] 6 []
                        ]
        , test "allBefore" <|
            \_ ->
                fromLists [ 1, 2, 3 ] 4 [ 5, 6 ]
                    |> allBefore
                    |> Expect.equal
                        [ fromLists [] 1 [ 2, 3, 4, 5, 6 ]
                        , fromLists [ 1 ] 2 [ 3, 4, 5, 6 ]
                        , fromLists [ 1, 2 ] 3 [ 4, 5, 6 ]
                        ]
        , test "allAfter" <|
            \_ ->
                fromLists [ 1, 2, 3 ] 4 [ 5, 6 ]
                    |> allAfter
                    |> Expect.equal
                        [ fromLists [ 1, 2, 3, 4 ] 5 [ 6 ]
                        , fromLists [ 1, 2, 3, 4, 5 ] 6 []
                        ]
        ]

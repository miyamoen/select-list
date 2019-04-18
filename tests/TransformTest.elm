module TransformTest exposing
    ( indexedMapTest
    , mapTest
    , selectedMapTest
    , updateTest
    )

import Expect exposing (Expectation)
import Expression exposing (..)
import Fuzz
import Test exposing (..)
import Transform exposing (..)
import Types exposing (..)


f : Int -> Int
f num =
    num * 2


mapTest : Test
mapTest =
    describe "maps"
        [ fuzzSegments "map" <|
            \before a after ->
                fromLists before a after
                    |> map f
                    |> equalSelectList (List.map f before) (f a) (List.map f after)
        , fuzzSegments "mapBefore" <|
            \before a after ->
                fromLists before a after
                    |> mapBefore f
                    |> equalSelectList (List.map f before) a after
        , fuzzSegments "mapAfter" <|
            \before a after ->
                fromLists before a after
                    |> mapAfter f
                    |> equalSelectList before a (List.map f after)
        ]


updateTest : Test
updateTest =
    describe "update"
        [ fuzzSegments "updateSelected" <|
            \before a after ->
                fromLists before a after
                    |> updateSelected f
                    |> equalSelectList before (f a) after
        , fuzzSegments "updateBefore" <|
            \before a after ->
                fromLists before a after
                    |> updateBefore (List.map f)
                    |> equalSelectList (List.map f before) a after
        , fuzzSegments "updateAfter" <|
            \before a after ->
                fromLists before a after
                    |> updateAfter (List.map f)
                    |> equalSelectList before a (List.map f after)
        ]


selectedMapTest : Test
selectedMapTest =
    describe "selectedMaps"
        [ fuzzSegments "selectedMap" <|
            \before a after ->
                fromLists before a after
                    |> selectedMap (\pos sl -> ( pos, f <| selected sl ))
                    |> Expect.equal
                        (List.map (f >> Tuple.pair BeforeSelected) before
                            ++ ( Selected, f a )
                            :: List.map (f >> Tuple.pair AfterSelected) after
                        )
        , fuzz (Fuzz.list Fuzz.int) "selectedMapForList" <|
            \list ->
                selectedMapForList (\sl -> selected sl |> f) list
                    |> Expect.equal (List.map f list)
        ]


indexedMapTest : Test
indexedMapTest =
    describe "indexedMaps"
        [ fuzzSegments "indexedMap" <|
            \before a after ->
                let
                    length =
                        List.length before
                in
                fromLists before a after
                    |> indexedMap (\index elm -> ( index, f elm ))
                    |> Expect.equal
                        (List.indexedMap (\index elm -> ( index - length, f elm )) before
                            ++ ( 0, f a )
                            :: List.indexedMap (\index elm -> ( index + 1, f elm )) after
                        )
        , test "indexedMap static" <|
            \_ ->
                fromLists [ 1, 2, 3 ] 4 [ 5, 6 ]
                    |> indexedMap (\index elm -> ( index, f elm ))
                    |> Expect.equal
                        [ ( -3, 2 )
                        , ( -2, 4 )
                        , ( -1, 6 )
                        , ( 0, 8 )
                        , ( 1, 10 )
                        , ( 2, 12 )
                        ]
        , test "indexedMap [0],0,[]" <|
            \_ ->
                fromLists [ 0 ] 0 []
                    |> indexedMap (\index elm -> ( index, f elm ))
                    |> Expect.equal
                        [ ( -1, 0 ), ( 0, 0 ) ]
        , fuzzSegments "indexedMap_" <|
            \before a after ->
                let
                    length =
                        List.length before
                in
                fromLists before a after
                    |> indexedMap_ (\selected index elm -> ( selected, index, f elm ))
                    |> Expect.equal
                        (List.indexedMap (\index elm -> ( False, index, f elm )) before
                            ++ ( True, length, f a )
                            :: List.indexedMap (\index elm -> ( False, index + 1 + length, f elm )) after
                        )
        , test "indexedMap_ static" <|
            \_ ->
                fromLists [ 1, 2, 3 ] 4 [ 5, 6 ]
                    |> indexedMap_ (\selected index elm -> ( selected, index, f elm ))
                    |> Expect.equal
                        [ ( False, 0, 2 )
                        , ( False, 1, 4 )
                        , ( False, 2, 6 )
                        , ( True, 3, 8 )
                        , ( False, 4, 10 )
                        , ( False, 5, 12 )
                        ]
        ]

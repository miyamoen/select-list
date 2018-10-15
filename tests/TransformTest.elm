module TransformTest exposing (f, mapTest)

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

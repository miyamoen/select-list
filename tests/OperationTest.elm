module OperationTest exposing (operation)

import Expect exposing (Expectation)
import Expression exposing (..)
import Fuzz exposing (int, list, tuple)
import Operation exposing (..)
import Test exposing (..)
import Types exposing (..)


operation : Test
operation =
    describe "Operation"
        [ describe "reverse"
            [ fuzzSegments "fuzz" <|
                \before a after ->
                    fromLists before a after
                        |> reverse
                        |> equalSelectList (List.reverse after) a (List.reverse before)
            , fuzzSegments "identity" <|
                \before a after ->
                    fromLists before a after
                        |> reverse
                        |> reverse
                        |> equalSelectList before a after
            ]
        , describe "delete"
            [ fuzzSegments "select after" <|
                \before a after ->
                    fromLists before a (a :: after)
                        |> delete
                        |> Maybe.map toTuple
                        |> Expect.equal (Just ( before, a, after ))
            , fuzzSegments "select before" <|
                \before a _ ->
                    fromLists (List.reverse <| a :: before) a []
                        |> delete
                        |> Maybe.map toTuple
                        |> Expect.equal (Just ( List.reverse before, a, [] ))
            , fuzz int "Nothing" <|
                \a ->
                    fromLists [] a []
                        |> delete
                        |> Expect.equal Nothing
            ]
        , describe "insert"
            [ insertFuzz "insertBefore" <|
                \before ( a, new ) after ->
                    fromLists before a after
                        |> insertBefore new
                        |> equalSelectList (before ++ [ a ]) new after
            , insertFuzz "insertAfter" <|
                \before ( a, new ) after ->
                    fromLists before a after
                        |> insertAfter new
                        |> equalSelectList before new (a :: after)
            ]
        ]


insertFuzz : String -> (List Int -> ( Int, Int ) -> List Int -> Expectation) -> Test
insertFuzz =
    fuzz3 (list int) (tuple ( int, int )) (list int)

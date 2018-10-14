module TypesTest exposing (types)

import Expect exposing (Expectation)
import Expression exposing (..)
import Fuzz exposing (int, list)
import Test exposing (..)
import Types exposing (..)


types : Test
types =
    describe "Types"
        [ describe "Constructor"
            [ describe "fromLists"
                [ fuzzSegments "fuzz" <|
                    \before a after ->
                        fromLists before a after
                            |> equalSelectList before a after
                , test "static" <|
                    \_ ->
                        fromLists [ 1, 2, 3 ] 4 [ 5, 6 ]
                            |> equalSelectList [ 1, 2, 3 ] 4 [ 5, 6 ]
                ]
            , describe "singleton"
                [ fuzz int "fuzz" <|
                    \a ->
                        singleton a
                            |> equalSelectList [] a []
                , test "static" <|
                    \_ ->
                        singleton 4
                            |> equalSelectList [] 4 []
                ]
            , describe "fromList"
                [ fuzzSegments "fuzz" <|
                    \_ a after ->
                        fromList (a :: after)
                            |> Maybe.map toTuple
                            |> Expect.equal (Just ( [], a, after ))
                , test "empty" <|
                    \_ ->
                        fromList []
                            |> Expect.equal Nothing
                ]
            ]
        , describe "Destructor"
            [ describe "toList"
                [ fuzzSegments "fuzz" <|
                    \before a after ->
                        fromLists before a after
                            |> toList
                            |> Expect.equal (before ++ a :: after)
                , test "static" <|
                    \_ ->
                        fromLists [ 1, 2, 3 ] 4 [ 5, 6 ]
                            |> toList
                            |> Expect.equal [ 1, 2, 3, 4, 5, 6 ]
                ]
            , describe "selected"
                [ fuzzSegments "fuzz" <|
                    \before a after ->
                        fromLists before a after
                            |> selected
                            |> Expect.equal a
                , test "static" <|
                    \_ ->
                        fromLists [ 1, 2, 3 ] 4 [ 5, 6 ]
                            |> selected
                            |> Expect.equal 4
                ]
            , describe "listBefore"
                [ fuzzSegments "fuzz" <|
                    \before a after ->
                        fromLists before a after
                            |> listBefore
                            |> Expect.equal before
                , test "static" <|
                    \_ ->
                        fromLists [ 1, 2, 3 ] 4 [ 5, 6 ]
                            |> listBefore
                            |> Expect.equal [ 1, 2, 3 ]
                ]
            , describe "listAfter"
                [ fuzzSegments "fuzz" <|
                    \before a after ->
                        fromLists before a after
                            |> listAfter
                            |> Expect.equal after
                , test "static" <|
                    \_ ->
                        fromLists [ 1, 2, 3 ] 4 [ 5, 6 ]
                            |> listAfter
                            |> Expect.equal [ 5, 6 ]
                ]
            ]
        ]

module MoveTest exposing (move)

import Expect exposing (Expectation)
import Expression exposing (..)
import Fuzz exposing (int, list, tuple)
import Move exposing (..)
import Query exposing (isHead, isLast)
import Test exposing (..)
import Types exposing (..)


move : Test
move =
    describe "Move"
        [ describe "by"
            [ test "+2" <|
                \_ ->
                    fromLists [ 1, 2, 3 ] 4 [ 5, 6, 7 ]
                        |> by 2
                        |> equalSelectList [ 1, 2, 3, 5, 6 ] 4 [ 7 ]
            , test "-1" <|
                \_ ->
                    fromLists [ 1, 2, 3 ] 4 [ 5, 6, 7 ]
                        |> by -1
                        |> equalSelectList [ 1, 2 ] 4 [ 3, 5, 6, 7 ]
            , test ">length" <|
                \_ ->
                    fromLists [ 1, 2, 3 ] 4 [ 5, 6, 7 ]
                        |> by 8
                        |> equalSelectList [ 1, 2, 3, 5, 6, 7 ] 4 []
            , test "<length" <|
                \_ ->
                    fromLists [ 1, 2, 3 ] 4 [ 5, 6, 7 ]
                        |> by -5
                        |> equalSelectList [] 4 [ 1, 2, 3, 5, 6, 7 ]
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
                        |> by -n_
                        |> equalSelectList before a after
            , lengthFuzz "outside" <|
                \before ( a, n ) after ->
                    let
                        res =
                            fromLists before a after
                                |> by
                                    (if n > 0 then
                                        List.length after + n

                                     else
                                        n - List.length before
                                    )
                    in
                    Expect.true "should be last or head"
                        (isLast res || isHead res)
            ]
        ]


lengthFuzz : String -> (List Int -> ( Int, Int ) -> List Int -> Expectation) -> Test
lengthFuzz =
    fuzz3 (list int) (tuple ( int, int )) (list int)

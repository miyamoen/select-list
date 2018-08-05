module Tests exposing (..)

import Expect exposing (Expectation)
import Expression exposing (..)
import SelectList exposing (Direction(..), Position(..))
import Test exposing (..)


query : Test
query =
    describe "Query"
        [ selectListFuzz "before" <|
            \before a after ->
                SelectList.fromLists before a after
                    |> SelectList.before
                    |> Expect.equal before
        , selectListFuzz "selected" <|
            \before a after ->
                SelectList.fromLists before a after
                    |> SelectList.selected
                    |> Expect.equal a
        , selectListFuzz "after" <|
            \before a after ->
                SelectList.fromLists before a after
                    |> SelectList.after
                    |> Expect.equal after
        , selectListFuzz "toList" <|
            \before a after ->
                SelectList.fromLists before a after
                    |> SelectList.toList
                    |> Expect.equal (before ++ a :: after)
        , selectListFuzz "isHead" <|
            \_ a after ->
                SelectList.fromLists [] a after
                    |> SelectList.isHead
                    |> Expect.equal True
        , selectListFuzz "not isHead" <|
            \before a after ->
                SelectList.fromLists (a :: before) a (a :: after)
                    |> SelectList.isHead
                    |> Expect.equal False
        , selectListFuzz "isLast" <|
            \before a _ ->
                SelectList.fromLists before a []
                    |> SelectList.isLast
                    |> Expect.equal True
        , selectListFuzz "not isLast" <|
            \before a after ->
                SelectList.fromLists (a :: before) a (a :: after)
                    |> SelectList.isLast
                    |> Expect.equal False
        , selectListFuzz "index" <|
            \before a after ->
                SelectList.fromLists before a after
                    |> SelectList.index
                    |> Expect.equal (List.length before)
        , selectListFuzz "length" <|
            \before a after ->
                SelectList.fromLists before a after
                    |> SelectList.length
                    |> Expect.equal (List.length before + List.length after + 1)
        , selectListFuzz "afterLength" <|
            \before a after ->
                SelectList.fromLists before a after
                    |> SelectList.afterLength
                    |> Expect.equal (List.length after)
        , selectListFuzz "beforeLength" <|
            \before a after ->
                SelectList.fromLists before a after
                    |> SelectList.beforeLength
                    |> Expect.equal (List.length before)
        ]


operations : Test
operations =
    describe "Operations"
        [ selectListFuzz "append" <|
            \before a after ->
                SelectList.fromLists before a after
                    |> SelectList.append before
                    |> Expect.equal
                        (SelectList.fromLists before a (after ++ before))
        , selectListFuzz "prepend" <|
            \before a after ->
                SelectList.fromLists before a after
                    |> SelectList.prepend after
                    |> Expect.equal
                        (SelectList.fromLists (after ++ before) a after)
        , selectListFuzz "modify" <|
            \before a after ->
                SelectList.fromLists before a after
                    |> SelectList.modify (\a -> -1 * a)
                    |> Expect.equal (SelectList.fromLists before -a after)
        , selectListFuzz "set" <|
            \before a after ->
                SelectList.fromLists before 0 after
                    |> SelectList.set a
                    |> Expect.equal (SelectList.fromLists before a after)
        , selectListFuzz "insert after" <|
            \before a after ->
                SelectList.fromLists before a after
                    |> SelectList.insert After a
                    |> Expect.equal
                        (SelectList.fromLists before a (a :: after))
        , selectListFuzz "insert before" <|
            \before a after ->
                SelectList.fromLists before a after
                    |> SelectList.insert Before a
                    |> Expect.equal
                        (SelectList.fromLists (before ++ [ a ]) a after)
        , selectListFuzz "delete after" <|
            \before a after ->
                SelectList.fromLists before a after
                    |> SelectList.delete After
                    |> Expect.equal
                        (case after of
                            x :: xs ->
                                Just <| SelectList.fromLists before x xs

                            [] ->
                                Nothing
                        )
        , selectListFuzz "delete before" <|
            \before a after ->
                SelectList.fromLists before a after
                    |> SelectList.delete Before
                    |> Expect.equal
                        (case List.reverse before of
                            x :: xs ->
                                Just <| SelectList.fromLists (List.reverse xs) x after

                            [] ->
                                Nothing
                        )
        ]


step : Test
step =
    describe "step"
        [ selectListFuzz "after" <|
            \before a after ->
                SelectList.fromLists before a after
                    |> SelectList.step After
                    |> Expect.equal
                        (case after of
                            x :: xs ->
                                Just <| SelectList.fromLists (before ++ [ a ]) x xs

                            [] ->
                                Nothing
                        )
        , selectListFuzz "before" <|
            \before a after ->
                SelectList.fromLists before a after
                    |> SelectList.step Before
                    |> Expect.equal
                        (case List.reverse before of
                            x :: xs ->
                                Just <| SelectList.fromLists (List.reverse xs) x (a :: after)

                            [] ->
                                Nothing
                        )
        , "after n less than afterLength"
            ==> (SelectList.fromLists [ 1, 2, 3 ] 4 [ 5, 6, 7 ]
                    |> SelectList.steps After 2
                )
            === (Just <| SelectList.fromLists [ 1, 2, 3, 4, 5 ] 6 [ 7 ])
        , "after n more than afterLength"
            ==> (SelectList.fromLists [ 1, 2, 3 ] 4 [ 5, 6, 7 ]
                    |> SelectList.steps After 4
                )
            === Nothing
        , "before n less than beforeLength"
            ==> (SelectList.fromLists [ 1, 2, 3 ] 4 [ 5, 6, 7 ]
                    |> SelectList.steps Before 2
                )
            === (Just <| SelectList.fromLists [ 1 ] 2 [ 3, 4, 5, 6, 7 ])
        , "before n more than beforeLength"
            ==> (SelectList.fromLists [ 1, 2, 3 ] 4 [ 5, 6, 7 ]
                    |> SelectList.steps Before 4
                )
            === Nothing
        , selectListFuzz "moveToHead" <|
            \before a after ->
                SelectList.fromLists before a after
                    |> SelectList.moveToHead
                    |> Expect.equal
                        (case before of
                            x :: xs ->
                                SelectList.fromLists [] x (xs ++ a :: after)

                            [] ->
                                SelectList.fromLists [] a after
                        )
        , selectListFuzz "moveToLast" <|
            \before a after ->
                SelectList.fromLists before a after
                    |> SelectList.moveToLast
                    |> Expect.equal
                        (case List.reverse after of
                            x :: xs ->
                                SelectList.fromLists (before ++ a :: List.reverse xs) x []

                            [] ->
                                SelectList.fromLists before a []
                        )
        ]


transformations : Test
transformations =
    describe "Transformations"
        [ "selectAll"
            ==> (SelectList.fromLists [ 1, 2, 3 ] 4 [ 5, 6 ]
                    |> SelectList.selectAll
                )
            === [ SelectList.fromLists [] 1 [ 2, 3, 4, 5, 6 ]
                , SelectList.fromLists [ 1 ] 2 [ 3, 4, 5, 6 ]
                , SelectList.fromLists [ 1, 2 ] 3 [ 4, 5, 6 ]
                , SelectList.fromLists [ 1, 2, 3 ] 4 [ 5, 6 ]
                , SelectList.fromLists [ 1, 2, 3, 4 ] 5 [ 6 ]
                , SelectList.fromLists [ 1, 2, 3, 4, 5 ] 6 []
                ]
        , selectListFuzz "map" <|
            \before a after ->
                SelectList.fromLists before a after
                    |> SelectList.map ((*) 2)
                    |> Expect.equal
                        (SelectList.fromLists (List.map ((*) 2) before)
                            (2 * a)
                            (List.map ((*) 2) after)
                        )
        , selectListFuzz "mapBy" <|
            \before a after ->
                SelectList.fromLists before a after
                    |> SelectList.mapBy (\_ item -> SelectList.selected item * 2)
                    |> Expect.equal
                        (List.map ((*) 2) before
                            ++ (2 * a)
                            :: List.map ((*) 2) after
                        )
        , selectListFuzz "mapBy Position" <|
            \before a after ->
                SelectList.fromLists before a after
                    |> SelectList.mapBy (\pos _ -> pos)
                    |> Expect.equal
                        (List.map (always BeforeSelected) before
                            ++ Selected
                            :: List.map (always AfterSelected) after
                        )
        ]

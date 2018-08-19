module SelectList
    exposing
        ( Direction(..)
        , Position(..)
        , SelectList(..)
        , after
        , afterLength
        , append
        , attempt
        , before
        , beforeLength
        , delete
        , fromList
        , fromLists
        , index
        , insert
        , isHead
        , isLast
        , length
        , map
        , mapBy
        , mapBy_
        , modify
        , moveToHead
        , moveToLast
        , prepend
        , select
        , selectAll
        , selected
        , set
        , singleton
        , step
        , steps
        , toList
        )

{-| Yet another SelectList implementation

A SelectList is a non-empty list which always has exactly one element selected.
It is an example of a list zipper.

Inspired by these modules

  - [rtfeldman/selectlist](http://package.elm-lang.org/packages/rtfeldman/selectlist/latest)
  - [turboMaCk/lazy-tree-with-zipper](http://package.elm-lang.org/packages/turboMaCk/lazy-tree-with-zipper/latest)

[`mapBy`](#mapBy) is the main function in this package.
Use [`mapBy`](#mapBy) in view.

    view : SelectList String -> Html Msg
    view selectList =
        ul [] <|
            SelectList.mapBy
                (\position item ->
                    li [ onClick (Set item) ]
                        [ text <| toString <| SelectList.index item
                        , toString <| SelectList.selected item
                        ]
                )
                selectList


# Type

@docs SelectList, fromLists, fromList, singleton


# Query

@docs toList, selected, before, after, index, isHead, isLast
@docs length, afterLength, beforeLength


# Operations

@docs attempt, append, prepend
@docs Direction
@docs modify, set, insert, delete


# Step

@docs step, steps, moveToHead, moveToLast


# Transformations

@docs select, selectAll, map, Position, mapBy, mapBy_

-}


{-| A nonempty list which always has exactly one element selected.

Create one using `fromLists`, `fromList` or `singleton`.

-}
type SelectList a
    = SelectList (List a) a (List a)



-- constructor


{-| A `SelectList` if list has elements.

If empty, `Nothing`.

    fromList [] == Nothing
    fromList [2, 3, 4] == Just (fromLists [] 2 [ 3, 4 ])

-}
fromList : List a -> Maybe (SelectList a)
fromList list =
    case list of
        x :: xs ->
            Just <| SelectList [] x xs

        [] ->
            Nothing


{-| A `SelectList`.

    fromLists [ 1, 2, 3 ] 4 [ 5, 6 ]
        |> selected
        == 4

-}
fromLists : List a -> a -> List a -> SelectList a
fromLists before a after =
    SelectList (List.reverse before) a after


{-| A `SelectList` containing exactly one element.

    singleton 3 == fromLists [] 3 []

-}
singleton : a -> SelectList a
singleton a =
    SelectList [] a []


{-| Return a `List` containing the elements in a `SelectList`.

    fromLists [ 1, 2, 3 ] 4 [ 5, 6 ]
        |> toList
        == [ 1, 2, 3, 4, 5, 6 ]

-}
toList : SelectList a -> List a
toList (SelectList before a after) =
    List.reverse before ++ a :: after



-- Query


{-| Return the selected element.

    fromLists [ 1, 2, 3 ] 4 [ 5, 6 ]
        |> selected
        == 4

-}
selected : SelectList a -> a
selected (SelectList _ a _) =
    a


{-| Return the elements before the selected element.

    fromLists [ 1, 2, 3 ] 4 [ 5, 6 ]
        |> before
        == [ 1, 2, 3 ]

-}
before : SelectList a -> List a
before (SelectList xs _ _) =
    List.reverse xs


{-| Return the elements after the selected element.

    fromLists [ 1, 2, 3 ] 4 [ 5, 6 ]
        |> after
        == [ 5, 6 ]

-}
after : SelectList a -> List a
after (SelectList _ _ xs) =
    xs


{-| Check if the selected element is first element.

    fromLists [] 4 [ 5, 6 ]
        |> isHead
        == True

-}
isHead : SelectList a -> Bool
isHead (SelectList before _ _) =
    List.isEmpty before


{-| Check if the selected element is last element.

    fromLists [ 1, 2, 3 ] 4 []
        |> isLast
        == True

-}
isLast : SelectList a -> Bool
isLast (SelectList _ _ after) =
    List.isEmpty after


{-| Index of the selected element.

    fromLists [ 1, 2, 3 ] 4 [ 5, 6 ]
        |> index
        == 3

-}
index : SelectList a -> Int
index =
    beforeLength


{-| Length of `SelectList`.

    fromLists [ 1, 2, 3 ] 4 [ 5, 6 ]
        |> length
        == 6

-}
length : SelectList a -> Int
length (SelectList before _ after) =
    List.length before + 1 + List.length after


{-| Length of the elements before the selected element

    fromLists [ 1, 2, 3 ] 4 [ 5, 6 ]
        |> beforeLength
        == 3

-}
beforeLength : SelectList a -> Int
beforeLength (SelectList before _ _) =
    List.length before


{-| Length of the elements after the selected element

    fromLists [ 1, 2, 3 ] 4 [ 5, 6 ]
        |> afterLength
        == 2

-}
afterLength : SelectList a -> Int
afterLength (SelectList _ _ after) =
    List.length after



-- Operations


{-| Attempt to perform action over selectList and return original `SelectList`
in cases where this action returns `Nothing`.

    attempt f selectList =
        f selectList
            |> Maybe.withDefault selectList

-}
attempt : (SelectList a -> Maybe (SelectList a)) -> SelectList a -> SelectList a
attempt action selectList =
    Maybe.withDefault selectList <| action selectList


{-| Add elements to the end of a `SelectList`.

    fromLists [ 1, 2, 3 ] 4 [ 5, 6 ]
        |> append [ 7, 8 ]
        |> toList
        == [ 1, 2, 3, 4, 5, 6, 7, 8 ]

-}
append : List a -> SelectList a -> SelectList a
append list (SelectList before a after) =
    SelectList before a (after ++ list)


{-| Add elements to the beginning of a `SelectList`.

    fromLists [ 1, 2, 3 ] 4 [ 5, 6 ]
        |> prepend [ 7, 8 ]
        |> toList
        == [ 7, 8, 1, 2, 3, 4, 5, 6 ]

-}
prepend : List a -> SelectList a -> SelectList a
prepend list (SelectList before a after) =
    SelectList (before ++ List.reverse list) a after


{-| `Direction`
-}
type Direction
    = After
    | Before


{-| A selectList selects a `Direction` element by a step.

    fromLists [ 1, 2, 3 ] 4 [ 5, 6 ]
        |> step After
        == Just (fromLists [ 1, 2, 3, 4 ] 5 [ 6 ])

    fromLists [ 1, 2, 3 ] 4 []
        |> step After
        == Nothing

-}
step : Direction -> SelectList a -> Maybe (SelectList a)
step dir (SelectList before a after) =
    case dir of
        After ->
            case after of
                x :: xs ->
                    Just <| SelectList (a :: before) x xs

                [] ->
                    Nothing

        Before ->
            case before of
                x :: xs ->
                    Just <| SelectList xs x (a :: after)

                [] ->
                    Nothing


{-| A selectList selects a `Direction` element by `n` steps.

    fromLists [ 1, 2, 3 ] 4 [ 5, 6 ]
        |> steps After 2
        == Just (fromLists [ 1, 2, 3, 4, 5 ] 6 [])

    fromLists [ 1, 2, 3 ] 4 [ 5, 6 ]
        |> steps After 3
        == Nothing

-}
steps : Direction -> Int -> SelectList a -> Maybe (SelectList a)
steps dir n selectList =
    if n < 0 then
        Nothing
    else if n == 0 then
        Just selectList
    else
        step dir selectList
            |> Maybe.andThen (steps dir (n - 1))


{-| A selectList selects the first element of a selectList.

    fromLists [ 1, 2, 3 ] 4 [ 5, 6 ]
        |> moveToHead
        == fromLists [] 1 [ 2, 3, 4, 5, 6 ]

-}
moveToHead : SelectList a -> SelectList a
moveToHead ((SelectList before _ _) as selectList) =
    attempt (steps Before <| List.length before) selectList


{-| A selectList selects the last element of a selectList.

    fromLists [ 1, 2, 3 ] 4 [ 5, 6 ]
        |> moveToHead
        == fromLists [] 1 [ 2, 3, 4, 5, 6 ]

-}
moveToLast : SelectList a -> SelectList a
moveToLast ((SelectList _ _ after) as selectList) =
    attempt (steps After <| List.length after) selectList


{-| Modify the selected element using given function.

    fromLists [ 1, 2, 3 ] 4 [ 5, 6 ]
        |> modify (\selected -> 2 * selected)
        == fromLists [ 1, 2, 3 ] 8 [ 5, 6 ]

-}
modify : (a -> a) -> SelectList a -> SelectList a
modify f (SelectList before a after) =
    SelectList before (f a) after


{-| Replace the selected element with new one.

    fromLists [ 1, 2, 3 ] 4 [ 5, 6 ]
        |> set 10
        == fromLists [ 1, 2, 3 ] 10 [ 5, 6 ]

-}
set : a -> SelectList a -> SelectList a
set a (SelectList before _ after) =
    SelectList before a after


{-| Delete the selected element, then select `After`/`Before` element.

Returns Nothing if list of `After`/`Before` elements is empty.

    fromLists [ 1, 2, 3 ] 4 [ 5, 6 ]
        |> delete After
        == Just (fromLists [ 1, 2, 3 ] 5 [ 6 ])

    fromLists [ 1, 2, 3 ] 4 []
        |> delete After
        == Nothing

-}
delete : Direction -> SelectList a -> Maybe (SelectList a)
delete dir (SelectList before _ after) =
    case dir of
        After ->
            case after of
                x :: xs ->
                    Just <| SelectList before x xs

                [] ->
                    Nothing

        Before ->
            case before of
                x :: xs ->
                    Just <| SelectList xs x after

                [] ->
                    Nothing


{-| Insert the new selected element, then move the old `After`/`Before`.

    fromLists [ 1, 2, 3 ] 4 [ 5, 6 ]
        |> insert After 8
        == fromLists [ 1, 2, 3 ] 8 [ 4, 5, 6 ]

-}
insert : Direction -> a -> SelectList a -> SelectList a
insert dir x (SelectList before a after) =
    case dir of
        After ->
            SelectList before x (a :: after)

        Before ->
            SelectList (a :: before) x after


{-| Change the selected element to the nearest one which passes a predicate function.
Find the list after selected element preferentially.

    isEven num =
    num % 2 == 0

    fromLists [ 1, 2 ] 3 [ 4, 5, 6 ]
    |> select isEven
    == fromLists [ 1, 2, 3 ] 4 [ 5, 6 ]

-}
select : (a -> Bool) -> SelectList a -> Maybe (SelectList a)
select pred (SelectList before a after) =
    selectHelp pred before a after
        |> Maybe.map (\( before, a, after ) -> SelectList before a after)


selectHelp : (a -> Bool) -> List a -> a -> List a -> Maybe ( List a, a, List a )
selectHelp pred before a after =
    case selectAfterHelp pred before a after of
        Just selectList ->
            Just selectList

        Nothing ->
            selectBeforeHelp pred before a after


selectAfterHelp : (a -> Bool) -> List a -> a -> List a -> Maybe ( List a, a, List a )
selectAfterHelp pred before a after =
    if pred a then
        Just ( before, a, after )
    else
        case after of
            [] ->
                Nothing

            x :: xs ->
                selectAfterHelp pred (a :: before) x xs


selectBeforeHelp : (a -> Bool) -> List a -> a -> List a -> Maybe ( List a, a, List a )
selectBeforeHelp pred before a after =
    if pred a then
        Just ( before, a, after )
    else
        case before of
            [] ->
                Nothing

            x :: xs ->
                selectBeforeHelp pred xs x (a :: after)



-- Transformations


{-| List of all selectList.

    fromLists [ 1, 2, 3 ] 4 [ 5, 6 ]
        == [ fromLists [] 1 [ 2, 3, 4, 5, 6 ]
           , fromLists [ 1 ] 2 [ 3, 4, 5, 6 ]
           , fromLists [ 1, 2 ] 3 [ 4, 5, 6 ]
           , fromLists [ 1, 2, 3 ] 4 [ 5, 6 ]
           , fromLists [ 1, 2, 3, 4 ] 5 [ 6 ]
           , fromLists [ 1, 2, 3, 4, 5 ] 6 []
           ]

-}
selectAll : SelectList a -> List (SelectList a)
selectAll list =
    selectBefore list ++ list :: selectAfter list


selectBefore : SelectList a -> List (SelectList a)
selectBefore list =
    List.range 1 (beforeLength list)
        |> List.reverse
        |> List.filterMap (\n -> steps Before n list)


selectAfter : SelectList a -> List (SelectList a)
selectAfter list =
    List.range 1 (afterLength list)
        |> List.filterMap (\n -> steps After n list)


{-| Transform each element of the `SelectList`.

    fromLists [ 1, 2, 3 ] 4 [ 5, 6 ]
        |> map (\num -> num * 2)
        == fromLists [ 2, 4, 6 ] 8 [ 10, 12 ]

-}
map : (a -> b) -> SelectList a -> SelectList b
map f (SelectList before a after) =
    SelectList (List.map f before) (f a) (List.map f after)


{-| `Position` is used with [`mapBy`](#mapBy).

`Position` is Selected if the selected element,
BeforeSelected if an element before the selected element,
and AfterSelected if an element after the selected element.

-}
type Position
    = BeforeSelected
    | Selected
    | AfterSelected


{-| Transform each element of the `SelectList`.

The transform function receives a `Position`
and `SelectList` which selects a transformed element.

[`mapBy`](#mapBy) is the main function in this package.
Use [`mapBy`](#mapBy) in view.

    view : SelectList String -> Html Msg
    view selectList =
        ul [] <|
            SelectList.mapBy
                (\position item ->
                    li [ onClick (Set item) ]
                        [ text <| toString <| SelectList.index item
                        , toString <| SelectList.selected item
                        ]
                )
                selectList

If you can not use non-empty list, use [`mapBy_`](#mapBy_) that receives `List` instead of `SelectList`.

-}
mapBy : (Position -> SelectList a -> b) -> SelectList a -> List b
mapBy f list =
    let
        before =
            selectBefore list
                |> List.map (f BeforeSelected)

        selected =
            f Selected list

        after =
            selectAfter list
                |> List.map (f AfterSelected)
    in
    before ++ selected :: after


{-| This receives `List` instead of `SelectList`.
-}
mapBy_ : (Position -> SelectList a -> b) -> List a -> List b
mapBy_ f list =
    case fromList list of
        Just selectList ->
            mapBy f selectList

        Nothing ->
            []

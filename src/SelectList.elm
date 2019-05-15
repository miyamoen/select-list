module SelectList exposing
    ( SelectList
    , fromLists, fromList, singleton
    , toTuple, selected, listAfter, listBefore, toList
    , isHead, isLast, isSingle
    , length, beforeLength, afterLength, index
    , reverse, attempt, delete, insertBefore, insertAfter
    , map, mapBefore, mapAfter
    , updateSelected, updateBefore, updateAfter
    , replaceSelected, replaceBefore, replaceAfter
    , Position(..), selectedMap, selectedMapForList
    , indexedMap, indexedMap_
    , moveBy, moveWhileLoopBy, moveToHead, moveToLast
    , selectBeforeIf, selectAfterIf
    , selectBy, selectWhileLoopBy, selectHead, selectLast
    , selectAll, selectAllBefore, selectAllAfter
    )

{-| Yet another SelectList implementation

A SelectList is a non-empty list which always has exactly one element selected.
It is an example of a list zipper.

Inspired by these modules

  - [rtfeldman/selectlist](http://package.elm-lang.org/packages/rtfeldman/selectlist/latest)
  - [turboMaCk/lazy-tree-with-zipper](http://package.elm-lang.org/packages/turboMaCk/lazy-tree-with-zipper/latest)

[`selectedMap`](#selectedMap) is the feature function in this package.
Use `selectedMap` in view.

    view : SelectList String -> Html Msg
    view selectList =
        ul [] <|
            SelectList.selectedMap
                (\position item ->
                    li [ onClick (Set item) ]
                        [ text <| toString <| SelectList.index item
                        , text <| toString <| SelectList.selected item
                        ]
                )
                selectList


# Type

@docs SelectList


## Constructor

@docs fromLists, fromList, singleton


## Destructor

@docs toTuple, selected, listAfter, listBefore, toList


# Query

@docs isHead, isLast, isSingle
@docs length, beforeLength, afterLength, index


# Operation

@docs reverse, attempt, delete, insertBefore, insertAfter


# Transform

@docs map, mapBefore, mapAfter


## Update

@docs updateSelected, updateBefore, updateAfter


### Replace

Alias of update function.

    replaceX x =
        updateX (always x)

@docs replaceSelected, replaceBefore, replaceAfter


## Feature Functions

@docs Position, selectedMap, selectedMapForList

@docs indexedMap, indexedMap_


# Move

Move selected element.

@docs moveBy, moveWhileLoopBy, moveToHead, moveToLast


# Select

Select new element, otherwise move focus.


## Predicate

@docs selectBeforeIf, selectAfterIf


## Index

@docs selectBy, selectWhileLoopBy, selectHead, selectLast


## Multi

@docs selectAll, selectAllBefore, selectAllAfter

-}

import Move
import Operation
import Query
import Select
import Transform
import Types



-- Types


{-| A nonempty list which always has exactly one element selected.
-}
type alias SelectList a =
    Types.SelectList a


{-| Create a `SelectList` if list has elements.

If empty, `Nothing`.

    fromList [] == Nothing

    fromList [ 2, 3, 4 ] == Just (fromLists [] 2 [ 3, 4 ])

-}
fromList : List a -> Maybe (SelectList a)
fromList =
    Types.fromList


{-| Create a `SelectList`.

    fromLists [ 1, 2, 3 ] 4 [ 5, 6 ]
        |> selected
        == 4

-}
fromLists : List a -> a -> List a -> SelectList a
fromLists =
    Types.fromLists


{-| Create a `SelectList` containing exactly one element.

    singleton 3 == fromLists [] 3 []

-}
singleton : a -> SelectList a
singleton =
    Types.singleton


{-| Destruct `SelectList`.

    fromLists [ 1, 2, 3 ] 4 [ 5, 6 ]
        |> toTuple
        == ( [ 1, 2, 3 ], 4, [ 5, 6 ] )

-}
toTuple : SelectList a -> ( List a, a, List a )
toTuple =
    Types.toTuple


{-| Destruct `SelectList`.

    fromLists [ 1, 2, 3 ] 4 [ 5, 6 ]
        |> toList
        == [ 1, 2, 3, 4, 5, 6 ]

-}
toList : SelectList a -> List a
toList =
    Types.toList


{-| Return the selected element.

    fromLists [ 1, 2, 3 ] 4 [ 5, 6 ]
        |> selected
        == 4

-}
selected : SelectList a -> a
selected =
    Types.selected


{-| Return the elements before the selected element.

    fromLists [ 1, 2, 3 ] 4 [ 5, 6 ]
        |> listBefore
        == [ 1, 2, 3 ]

-}
listBefore : SelectList a -> List a
listBefore =
    Types.listBefore


{-| Return the elements after the selected element.

    fromLists [ 1, 2, 3 ] 4 [ 5, 6 ]
        |> listAfter
        == [ 5, 6 ]

-}
listAfter : SelectList a -> List a
listAfter =
    Types.listAfter



-- Query


{-| Check if the selected element is first element.

    fromLists [] 4 [ 5, 6 ]
        |> isHead
        == True

-}
isHead : SelectList a -> Bool
isHead =
    Query.isHead


{-| Check if the selected element is last element.

    fromLists [ 1, 2, 3 ] 4 []
        |> isLast
        == True

-}
isLast : SelectList a -> Bool
isLast =
    Query.isLast


{-| Check if the selected element is only element in select list.

    fromLists [] 4 []
        |> isSingle
        == True

-}
isSingle : SelectList a -> Bool
isSingle =
    Query.isSingle


{-| Length of `SelectList`.

    fromLists [ 1, 2, 3 ] 4 [ 5, 6 ]
        |> length
        == 6

-}
length : SelectList a -> Int
length =
    Query.length


{-| Length of the elements before the selected element

    fromLists [ 1, 2, 3 ] 4 [ 5, 6 ]
        |> beforeLength
        == 3

-}
beforeLength : SelectList a -> Int
beforeLength =
    Query.beforeLength


{-| Length of the elements after the selected element

    fromLists [ 1, 2, 3 ] 4 [ 5, 6 ]
        |> afterLength
        == 2

-}
afterLength : SelectList a -> Int
afterLength =
    Query.afterLength


{-| Index of the selected element.

This is alias of `beforeLength`.

    index =
        beforeLength

-}
index : SelectList a -> Int
index =
    beforeLength



-- Operation


{-| Attempt to perform action over selectList and return original `SelectList`
in cases where this action returns `Nothing`.

    attempt f selectList =
        f selectList
            |> Maybe.withDefault selectList

-}
attempt : (SelectList a -> Maybe (SelectList a)) -> SelectList a -> SelectList a
attempt action selectList =
    Maybe.withDefault selectList <| action selectList


{-| Reverse a select list. Pivot is selected element.

    fromLists [ 1, 2, 3 ] 4 [ 5, 6 ]
        |> reverse
        == fromLists [ 6, 5 ] 4 [ 3, 2, 1 ]

-}
reverse : SelectList a -> SelectList a
reverse =
    Operation.reverse


{-| Delete the selected element, then select an element after the selected.

If a list after selected is empty, then select an element before the selected.

Returns Nothing if SelectList has only single value.

    fromLists [ 1, 2, 3 ] 4 [ 5, 6 ]
        |> delete
        == Just (fromLists [ 1, 2, 3 ] 5 [ 6 ])

    fromLists [ 1, 2, 3 ] 4 []
        |> delete
        == Just (fromLists [ 1, 2 ] 3 [])

    fromLists [] 4 []
        |> delete
        == Nothing

-}
delete : SelectList a -> Maybe (SelectList a)
delete =
    Operation.delete


{-| Insert new selected element, then move the old before it.

    fromLists [ 1, 2, 3 ] 4 [ 5, 6 ]
        |> insertBefore 8
        == fromLists [ 1, 2, 3, 4 ] 8 [ 5, 6 ]

-}
insertBefore : a -> SelectList a -> SelectList a
insertBefore =
    Operation.insertBefore


{-| Insert new selected element, then move the old after it.

    fromLists [ 1, 2, 3 ] 4 [ 5, 6 ]
        |> insertAfter 8
        == fromLists [ 1, 2, 3 ] 8 [ 4, 5, 6 ]

-}
insertAfter : a -> SelectList a -> SelectList a
insertAfter =
    Operation.insertAfter



-- Move


{-| Move a selected element by n steps.
Pass an index over the length, then move to head/last.

    fromLists [ 1, 2, 3 ] 4 [ 5, 6 ]
        |> moveBy -2
        == fromLists [ 1 ] 4 [ 2, 3, 5, 6 ]

    fromLists [ 1, 2, 3 ] 4 [ 5, 6 ]
        |> moveBy 1
        == fromLists [ 1, 2, 3, 5 ] 4 [ 6 ]

    fromLists [ 1, 2, 3 ] 4 [ 5, 6 ]
        |> moveBy 3
        == fromLists [ 1, 2, 3, 5, 6 ] 4 []

-}
moveBy : Int -> SelectList a -> SelectList a
moveBy =
    Move.by


{-| Move a selected element by n steps while loop.
Pass an index over the length, then loop.

    fromLists [ 1, 2, 3 ] 4 [ 5, 6 ]
        |> moveWhileLoopBy 4
        == fromLists [ 1 ] 4 [ 2, 3, 5, 6 ]

    fromLists [ 1, 2, 3 ] 4 [ 5, 6 ]
        |> moveWhileLoopBy -4
        == fromLists [ 1 2, 3, 5, 6 ] 4 []

-}
moveWhileLoopBy : Int -> SelectList a -> SelectList a
moveWhileLoopBy =
    Move.whileLoopBy


{-| Move a selected element to head.

    fromLists [ 1, 2, 3 ] 4 [ 5, 6 ]
        |> moveToHead
        == fromLists [] 4 [ 1, 2, 3, 5, 6 ]

-}
moveToHead : SelectList a -> SelectList a
moveToHead =
    Move.toHead


{-| Move a selected element to last.

    fromLists [ 1, 2, 3 ] 4 [ 5, 6 ]
        |> moveToLast
        == fromLists [ 1, 2, 3, 5, 6 ] 4 []

-}
moveToLast : SelectList a -> SelectList a
moveToLast =
    Move.toLast



-- Select


{-| Select the first element, before the old selected, that satisfies a predicate. If none match, return Nothing.

    isOdd num =
        modBy 2 num /= 0

    fromLists [ 1, 2 ] 3 [ 4, 5, 6 ]
        |> selectBeforeIf isOdd
        == Just (fromLists [ 0 ] 1 [ 2, 3, 4, 5, 6 ])

-}
selectBeforeIf : (a -> Bool) -> SelectList a -> Maybe (SelectList a)
selectBeforeIf =
    Select.beforeIf


{-| Select the first element, after the old selected, that satisfies a predicate. If none match, return Nothing.

    isOdd num =
        modBy 2 num /= 0

    fromLists [ 1, 2 ] 3 [ 4, 5, 6 ]
        |> selectAfterIf isOdd
        == Just (fromLists [ 1, 2, 3, 4 ] 5 [ 6 ])

-}
selectAfterIf : (a -> Bool) -> SelectList a -> Maybe (SelectList a)
selectAfterIf =
    Select.afterIf


{-| Select an element by n steps.
Pass an index over the length, then returns Nothing.

    fromLists [ 1, 2, 3 ] 4 [ 5, 6 ]
        |> selectBy -1
        == Just (fromLists [ 1, 2 ] 3 [ 4, 5, 6 ])

    fromLists [ 1, 2, 3 ] 4 [ 5, 6 ]
        |> selectBy 2
        == Just (fromLists [ 1, 2, 3, 4, 5 ] 6 [])

    fromLists [ 1, 2, 3 ] 4 [ 5, 6 ]
        |> selectBy 3
        == Nothing

-}
selectBy : Int -> SelectList a -> Maybe (SelectList a)
selectBy =
    Select.by


{-| Select an element by n steps while loop.
Pass an index over the length, then loop.

    fromLists [ 1, 2, 3 ] 4 [ 5, 6 ]
        |> selectWhileLoopBy 3
        == fromLists [] 1 [ 2, 3, 4, 5, 6 ]

    fromLists [ 1, 2, 3 ] 4 [ 5, 6 ]
        |> selectWhileLoopBy -5
        == fromLists [ 1, 2, 3, 4 ] 5 [ 6 ]

-}
selectWhileLoopBy : Int -> SelectList a -> SelectList a
selectWhileLoopBy =
    Select.whileLoopBy


{-| Select a head element.

    fromLists [ 1, 2, 3 ] 4 [ 5, 6 ]
        |> selectHead
        == fromLists [] 1 [ 2, 3, 4, 5, 6 ]

-}
selectHead : SelectList a -> SelectList a
selectHead =
    Select.head


{-| Select a last element.

    fromLists [ 1, 2, 3 ] 4 [ 5, 6 ]
        |> selectLast
        == fromLists [ 1, 2, 3, 4, 5 ] 6 []

-}
selectLast : SelectList a -> SelectList a
selectLast =
    Select.last


{-| List of all SelectList.

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
selectAll =
    Select.all


{-| List of all SelectList before the selected.

    fromLists [ 1, 2, 3 ] 4 [ 5, 6 ]
        == [ fromLists [] 1 [ 2, 3, 4, 5, 6 ]
           , fromLists [ 1 ] 2 [ 3, 4, 5, 6 ]
           , fromLists [ 1, 2 ] 3 [ 4, 5, 6 ]
           , fromLists [ 1, 2, 3 ] 4 [ 5, 6 ]
           ]

-}
selectAllBefore : SelectList a -> List (SelectList a)
selectAllBefore =
    Select.allBefore


{-| List of all SelectList after the selected.

    fromLists [ 1, 2, 3 ] 4 [ 5, 6 ]
        == [ fromLists [ 1, 2, 3, 4 ] 5 [ 6 ]
           , fromLists [ 1, 2, 3, 4, 5 ] 6 []
           ]

-}
selectAllAfter : SelectList a -> List (SelectList a)
selectAllAfter =
    Select.allAfter



-- Transform


{-| Apply a function to every element of a `SelectList`.

    fromLists [ 1, 2, 3 ] 4 [ 5, 6 ]
        |> map (\num -> num * 2)
        == fromLists [ 2, 4, 6 ] 8 [ 10, 12 ]

-}
map : (a -> b) -> SelectList a -> SelectList b
map =
    Transform.map


{-| Apply a function to elements before the selected element.

    fromLists [ 1, 2, 3 ] 4 [ 5, 6 ]
        |> mapBefore (\selected -> 2 * selected)
        == fromLists [ 2, 4, 6 ] 4 [ 5, 6 ]

-}
mapBefore : (a -> a) -> SelectList a -> SelectList a
mapBefore =
    Transform.mapBefore


{-| Apply a function to elements after the selected element.

    fromLists [ 1, 2, 3 ] 4 [ 5, 6 ]
        |> mapAfter (\selected -> 2 * selected)
        == fromLists [ 1, 2, 3 ] 4 [ 10, 12 ]

-}
mapAfter : (a -> a) -> SelectList a -> SelectList a
mapAfter =
    Transform.mapAfter


{-| Update the selected element using given function.

    fromLists [ 1, 2, 3 ] 4 [ 5, 6 ]
        |> updateSelected (\selected -> 2 * selected)
        == fromLists [ 1, 2, 3 ] 8 [ 5, 6 ]

-}
updateSelected : (a -> a) -> SelectList a -> SelectList a
updateSelected =
    Transform.updateSelected


{-| Replace the selected element with new one.

    fromLists [ 1, 2, 3 ] 4 [ 5, 6 ]
        |> replaceSelected 10
        == fromLists [ 1, 2, 3 ] 10 [ 5, 6 ]

-}
replaceSelected : a -> SelectList a -> SelectList a
replaceSelected a =
    Transform.updateSelected (always a)


{-| Update elements before the selected element using given function.

    fromLists [ 1, 2, 3 ] 4 [ 5, 6 ]
        |> updateBefore (\before -> List.map ((*) 2) before)
        == fromLists [ 2, 4, 6 ] 4 [ 5, 6 ]

-}
updateBefore : (List a -> List a) -> SelectList a -> SelectList a
updateBefore =
    Transform.updateBefore


{-| Replace elements before the selected element with new elements.

    fromLists [ 1, 2, 3 ] 4 [ 5, 6 ]
        |> replaceBefore [ 7, 8 ]
        == fromLists [ 7, 8 ] 4 [ 5, 6 ]

-}
replaceBefore : List a -> SelectList a -> SelectList a
replaceBefore xs =
    Transform.updateBefore (always xs)


{-| Update elements after the selected element using given function.

    fromLists [ 1, 2, 3 ] 4 [ 5, 6 ]
        |> updateBefore (\after -> List.map ((*) 2) after)
        == fromLists [ 1, 2, 3 ] 4 [ 10, 12 ]

-}
updateAfter : (List a -> List a) -> SelectList a -> SelectList a
updateAfter =
    Transform.updateAfter


{-| Replace elements after the selected element with new elements.

    fromLists [ 1, 2, 3 ] 4 [ 5, 6 ]
        |> replaceAfter [ 9, 10, 11 ]
        == fromLists [ 1, 2, 3 ] 4 [ 9, 10, 11 ]

-}
replaceAfter : List a -> SelectList a -> SelectList a
replaceAfter xs =
    Transform.updateAfter (always xs)


{-| `Position` is used with [`selectedMap`](#selectedMap).

`Position` is Selected if the selected element,
BeforeSelected if an element before the selected element,
and AfterSelected if an element after the selected element.

-}
type Position
    = BeforeSelected
    | Selected
    | AfterSelected


convert : Transform.Position -> Position
convert position =
    case position of
        Transform.BeforeSelected ->
            BeforeSelected

        Transform.Selected ->
            Selected

        Transform.AfterSelected ->
            AfterSelected


{-| Apply a function to every element of a `SelectList`.

The transform function receives a `Position` and `SelectList` which selects a focused element.

Use in view.

    view : SelectList String -> Html Msg
    view selectList =
        ul [] <|
            SelectList.selectedMap
                (\position item ->
                    li [ onClick (Set item) ]
                        [ text <| toString <| SelectList.index item
                        , text <| toString <| SelectList.selected item
                        ]
                )
                selectList

Get a focused item and index from select list.
`Position` describes whether it is selected, or not.

Compared with `List.indexedMap`.

    selectedMap : (Position -> SelectList a -> b) -> SelectList a -> List b

    indexedMap : (Int -> a -> b) -> List a -> List b

Unlike `indexedMap`, we can get full access to all elements in the list.
And set new list to `Model`.

If you don't use non-empty list, use [`selectedMapForList`](#selectedMapForList) that receives `List` instead of `SelectList`.

-}
selectedMap : (Position -> SelectList a -> b) -> SelectList a -> List b
selectedMap f =
    Transform.selectedMap (\pos list -> f (convert pos) list)


{-| Apply a function to every element of a `List`.

The transform function receives a `SelectList` which selects a focused element.

Use in view.

    view : List String -> Html Msg
    view selectList =
        ul [] <|
            SelectList.selectedMapForList
                (\item ->
                    li [ onClick (Set <| SelectList.toList <| SelectList.update updateFunction item) ]
                        [ text <| toString <| SelectList.index item
                        , text <| toString <| SelectList.selected item
                        ]
                )
                selectList

Use this instead of `indexedMap`.

-}
selectedMapForList : (SelectList a -> b) -> List a -> List b
selectedMapForList =
    Transform.selectedMapForList


{-| Apply a function to every element of a `SelectList`.

The transform function receives an index and an element.

A problem with `selectedMap` is to produce many `SelectList`s. `indexedMap` solves it.

The index is relative. We can create new list with original list and relative index.

    fromLists [ 1, 2, 3 ] 4 [ 5, 6 ]
        |> indexedMap (\index elm -> ( index, elm * 2 ))
        == [ ( -3, 2 )
           , ( -2, 4 )
           , ( -1, 6 )
           , ( 0, 8 )
           , ( 1, 10 )
           , ( 2, 12 )
           ]

-}
indexedMap : (Int -> a -> b) -> SelectList a -> List b
indexedMap =
    Transform.indexedMap


{-| Absolute index version.

    fromLists [ 1, 2, 3 ] 4 [ 5, 6 ]
        |> indexedMap_ (\selected index elm -> ( selected, index, 2 * elm ))
        == [ ( False, 0, 2 )
           , ( False, 1, 4 )
           , ( False, 2, 6 )
           , ( True, 3, 8 )
           , ( False, 4, 10 )
           , ( False, 5, 12 )
           ]

-}
indexedMap_ : (Bool -> Int -> a -> b) -> SelectList a -> List b
indexedMap_ =
    Transform.indexedMap_

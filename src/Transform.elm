module Transform exposing
    ( map, mapBefore, mapAfter
    , updateSelected, updateBefore, updateAfter
    , indexedMap, indexedMap_
    , Position(..), selectedMap, selectedMapForList
    )

{-|

@docs map, mapBefore, mapAfter
@docs updateSelected, updateBefore, updateAfter
@docs indexedMap, indexedMap_
@docs Position, selectedMap, selectedMapForList

-}

import Select
import Types exposing (..)


map : (a -> b) -> SelectList a -> SelectList b
map f (SelectList before a after) =
    SelectList (List.map f before) (f a) (List.map f after)


mapBefore : (a -> a) -> SelectList a -> SelectList a
mapBefore f (SelectList before a after) =
    SelectList (List.map f before) a after


mapAfter : (a -> a) -> SelectList a -> SelectList a
mapAfter f list =
    updateAfter (List.map f) list


updateSelected : (a -> a) -> SelectList a -> SelectList a
updateSelected f (SelectList before a after) =
    SelectList before (f a) after


updateBefore : (List a -> List a) -> SelectList a -> SelectList a
updateBefore f (SelectList before a after) =
    SelectList (List.reverse before |> f |> List.reverse) a after


updateAfter : (List a -> List a) -> SelectList a -> SelectList a
updateAfter f (SelectList before a after) =
    SelectList before a (f after)


{-| Relative coordinates
-}
indexedMap : (Int -> a -> b) -> SelectList a -> List b
indexedMap f (SelectList before a after) =
    let
        newBefore =
            List.indexedMap
                (\index -> f (-1 * (1 + index)))
                before

        newAfter =
            List.indexedMap
                (\index -> f (1 + index))
                after
    in
    reverseAppend newBefore (f 0 a :: newAfter)


{-| Absolute coordinates
-}
indexedMap_ : (Bool -> Int -> a -> b) -> SelectList a -> List b
indexedMap_ f (SelectList before a after) =
    let
        targetIndex =
            List.length before

        newBefore =
            List.indexedMap
                (\index -> f False (targetIndex - 1 - index))
                before

        newAfter =
            List.indexedMap
                (\index -> f False (targetIndex + 1 + index))
                after
    in
    reverseAppend newBefore (f True targetIndex a :: newAfter)


type Position
    = BeforeSelected
    | Selected
    | AfterSelected


selectedMap : (Position -> SelectList a -> b) -> SelectList a -> List b
selectedMap f list =
    let
        before =
            Select.allBeforeHelp list
                |> List.map (f BeforeSelected)

        after =
            Select.allAfter list
                |> List.map (f AfterSelected)
    in
    reverseAppend before (f Selected list :: after)


selectedMapForList : (SelectList a -> b) -> List a -> List b
selectedMapForList f list =
    case fromList list of
        Just selectList ->
            Select.all selectList
                |> List.map f

        Nothing ->
            []

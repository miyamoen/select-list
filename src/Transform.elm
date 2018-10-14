module Transform exposing
    ( map, mapBefore, mapAfter
    , updateSelected, updateBefore, updateAfter
    , Position(..), selectedMap, selectedMapForList
    )

{-|

@docs map, mapBefore, mapAfter
@docs updateSelected, updateBefore, updateAfter
@docs Position, selectedMap, selectedMapForList

-}

import Select
import Types exposing (..)


map : (a -> b) -> SelectList a -> SelectList b
map f (SelectList before a after) =
    SelectList (List.map f before) (f a) (List.map f after)


mapBefore : (a -> a) -> SelectList a -> SelectList a
mapBefore f list =
    updateBefore (List.map f) list


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


type Position
    = BeforeSelected
    | Selected
    | AfterSelected


selectedMap : (Position -> SelectList a -> b) -> SelectList a -> List b
selectedMap f list =
    let
        before =
            Select.allBefore list
                |> List.map (f BeforeSelected)

        after =
            Select.allAfter list
                |> List.map (f AfterSelected)
    in
    before ++ f Selected list :: after


selectedMapForList : (SelectList a -> b) -> List a -> List b
selectedMapForList f list =
    case fromList list of
        Just selectList ->
            selectedMap (always f) selectList

        Nothing ->
            []

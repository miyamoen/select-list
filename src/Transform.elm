module Transform exposing
    ( map
    , Position(..), selectedMap, selectedMapForList
    , updateSelected, updateBefore, updateAfter
    )

{-|

@docs map
@docs Position, selectedMap, selectedMapForList
@docs updateSelected, updateBefore, updateAfter

-}

import Select
import Types exposing (..)


map : (a -> b) -> SelectList a -> SelectList b
map f (SelectList before a after) =
    SelectList (List.map f before) (f a) (List.map f after)


updateSelected : (a -> a) -> SelectList a -> SelectList a
updateSelected f (SelectList before a after) =
    SelectList before (f a) after


updateBefore : (a -> a) -> SelectList a -> SelectList a
updateBefore f (SelectList before a after) =
    SelectList (List.reverse before |> List.map f |> List.reverse) a after


updateAfter : (a -> a) -> SelectList a -> SelectList a
updateAfter f (SelectList before a after) =
    SelectList before a (List.map f after)


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

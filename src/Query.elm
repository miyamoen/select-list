module Query exposing
    ( isHead, isLast, isSingle
    , length, beforeLength, afterLength
    )

{-|

@docs isHead, isLast, isSingle
@docs length, beforeLength, afterLength

-}

import Types exposing (..)



--Bool


isHead : SelectList a -> Bool
isHead (SelectList before _ _) =
    List.isEmpty before


isLast : SelectList a -> Bool
isLast (SelectList _ _ after) =
    List.isEmpty after


isSingle : SelectList a -> Bool
isSingle (SelectList before _ after) =
    List.isEmpty before && List.isEmpty after



-- length


length : SelectList a -> Int
length (SelectList before _ after) =
    List.length before + 1 + List.length after


beforeLength : SelectList a -> Int
beforeLength (SelectList before _ _) =
    List.length before


afterLength : SelectList a -> Int
afterLength (SelectList _ _ after) =
    List.length after

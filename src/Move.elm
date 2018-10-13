module Move exposing (by, whileLoopBy, toHead, toLast)

{-|

@docs by, whileLoopBy, toHead, toLast

-}

import Types exposing (SelectList(..), loopIndex, reverseAppend, toList)


by : Int -> SelectList a -> SelectList a
by n ((SelectList before a after) as original) =
    if n > 0 then
        SelectList
            (reverseAppend (List.take n after) before)
            a
            (List.drop n after)

    else if n < 0 then
        SelectList
            (List.drop (abs n) before)
            a
            (reverseAppend (List.take (abs n) before) after)

    else
        original


whileLoopBy : Int -> SelectList a -> SelectList a
whileLoopBy n selectList =
    by (loopIndex n selectList) selectList


toHead : SelectList a -> SelectList a
toHead (SelectList before a after) =
    SelectList [] a (reverseAppend before after)


toLast : SelectList a -> SelectList a
toLast (SelectList before a after) =
    SelectList (reverseAppend after before) a []

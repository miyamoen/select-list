module Operation exposing
    ( reverse
    , delete, insertBefore, insertAfter
    )

{-|

@docs reverse
@docs delete, insertBefore, insertAfter

-}

import Types exposing (..)


reverse : SelectList a -> SelectList a
reverse (SelectList before a after) =
    SelectList (List.reverse after) a (List.reverse before)


delete : SelectList a -> Maybe (SelectList a)
delete (SelectList before _ after) =
    case ( before, after ) of
        ( _, x :: xs ) ->
            Just <| SelectList before x xs

        ( x :: xs, [] ) ->
            Just <| SelectList xs x []

        ( [], [] ) ->
            Nothing


insertBefore : a -> SelectList a -> SelectList a
insertBefore x (SelectList before a after) =
    SelectList (a :: before) x after


insertAfter : a -> SelectList a -> SelectList a
insertAfter x (SelectList before a after) =
    SelectList before x (a :: after)

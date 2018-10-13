module Types exposing
    ( SelectList(..)
    , fromLists, fromList, singleton
    , selected, listAfter, listBefore, toList
    , loopIndex, reverseAppend
    )

{-|

@docs SelectList
@docs fromLists, fromList, singleton
@docs selected, listAfter, listBefore, toList

-}


type SelectList a
    = SelectList (List a) a (List a)


fromList : List a -> Maybe (SelectList a)
fromList list =
    case list of
        x :: xs ->
            Just <| SelectList [] x xs

        [] ->
            Nothing


fromLists : List a -> a -> List a -> SelectList a
fromLists before a after =
    SelectList (List.reverse before) a after


singleton : a -> SelectList a
singleton a =
    SelectList [] a []


toList : SelectList a -> List a
toList (SelectList before a after) =
    reverseAppend before (a :: after)


selected : SelectList a -> a
selected (SelectList _ a _) =
    a


listBefore : SelectList a -> List a
listBefore (SelectList xs _ _) =
    List.reverse xs


listAfter : SelectList a -> List a
listAfter (SelectList _ _ xs) =
    xs


reverseAppend : List a -> List a -> List a
reverseAppend xs ys =
    List.foldl (::) ys xs


loopIndex : Int -> SelectList a -> Int
loopIndex n (SelectList before a after) =
    let
        beforeLength =
            List.length before

        allLenght =
            beforeLength + List.length after + 1
    in
    modBy allLenght (n + beforeLength) - beforeLength

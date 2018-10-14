Yet another SelectList implementation

A SelectList is a non-empty list which always has exactly one element selected.
It is one of zipper.

Inspired by these modules

* [rtfeldman/selectlist](https://package.elm-lang.org/packages/rtfeldman/selectlist/latest)
* [turboMaCk/lazy-tree-with-zipper](https://package.elm-lang.org/packages/turboMaCk/lazy-tree-with-zipper/latest)
* [arowM/elm-reference](https://package.elm-lang.org/packages/arowM/elm-reference/latest/)

[`selectedMap`](https://package.elm-lang.org/packages/miyamoen/select-list/latest/SelectList#selectedMap) is the feature function in this package.
Use `selectedMap` in view.

```
    view : SelectList String -> Html Msg
    view selectList =
        ul [] <|
            SelectList.selectedMap
                (\position item ->
                    li [ onClick (Set item) ]
                        [ text <| toString <| SelectList.index item
                        , toString <| SelectList.selected item
                        ]
                )
                selectList
```
Get a focused item and index from select list.
`Position` describes whether it is selected, or not.

Compared with `List.indexedMap`.

```
    selectedMap : (Position -> SelectList a -> b) -> SelectList a -> List b
    indexedMap : (Int -> a -> b) -> List a -> List b
```

Unlike `indexedMap`, we can get full access to all elements in the list.
And set new list to `Model`.

If you don't use non-empty list, use [`selectedMapForList`](https://package.elm-lang.org/packages/miyamoen/select-list/latest/SelectList#selectedMapForList) that receives `List` instead of `SelectList`.

`List.indexedMap` is replaced with `selectedMapForList` .

[example](https://github.com/miyamoen/select-list/tree/master/example)

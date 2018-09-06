Yet another SelectList implementation

A SelectList is a non-empty list which always has exactly one element selected.
It is one of zipper.

Inspired by these modules

* [rtfeldman/selectlist](http://package.elm-lang.org/packages/rtfeldman/selectlist/latest)
* [turboMaCk/lazy-tree-with-zipper](http://package.elm-lang.org/packages/turboMaCk/lazy-tree-with-zipper/latest)
* [arowM/elm-reference](https://package.elm-lang.org/packages/arowM/elm-reference/latest/)

[`selectedMap`](http://package.elm-lang.org/packages/miyamoen/select-list/latest/SelectList#selectedMap) is the main function in this package.
Use [`selectedMap`](http://package.elm-lang.org/packages/miyamoen/select-list/latest/SelectList#selectedMap) in view.

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

[example](https://github.com/miyamoen/select-list/tree/master/example)

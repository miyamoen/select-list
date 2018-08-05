Yet another SelectList implementation

A SelectList is a nonempty list which always has exactly one element selected.
It is an example of a list zipper).

Inspired the modules

*   [rtfeldman/selectlist](http://package.elm-lang.org/packages/rtfeldman/selectlist/latest)
*   [turboMaCk/lazy-tree-with-zipper](http://package.elm-lang.org/packages/turboMaCk/lazy-tree-with-zipper/latest)

[`mapBy`](http://package.elm-lang.org/packages/miyamoen/select-list#mapBy) is main function in this package.
Use [`mapBy`](http://package.elm-lang.org/packages/miyamoen/select-list#mapBy) in view.

```
    view : SelectList String -> Html Msg
    view selectList =
        ul [] <|
            SelectList.mapBy
                (\position item ->
                    li [ onClick (Set item) ]
                        [ text <| toString <| SelectList.index item
                        , toString <| SelectList.selected item
                        ]
                )
                selectList
```

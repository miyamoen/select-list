Yet another SelectList implementation

A SelectList is a non-empty list which always has exactly one element selected.
It is an example of a list zipper.

Inspired by these modules

*   [rtfeldman/selectlist](http://package.elm-lang.org/packages/rtfeldman/selectlist/latest)
*   [turboMaCk/lazy-tree-with-zipper](http://package.elm-lang.org/packages/turboMaCk/lazy-tree-with-zipper/latest)

[`mapBy`](http://package.elm-lang.org/packages/miyamoen/select-list/latest/SelectList#mapBy) is the main function in this package.
Use [`mapBy`](http://package.elm-lang.org/packages/miyamoen/select-list/latest/SelectList#mapBy) in view.

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

module UpDownWithSelectList exposing (main)

import Browser
import Html exposing (Html, div, text)
import Html.Attributes as Attributes
import Html.Events as Events
import SelectList exposing (SelectList)



-- APP


main : Program () Model Msg
main =
    Browser.element
        { init = \_ -> init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


init : ( Model, Cmd Msg )
init =
    ( { todos =
            [ "foo"
            , "bar"
            , "baz"
            , "foobar"
            , "foobaz"
            , "barbaz"
            , "foobarbaz"
            ]
      }
    , Cmd.none
    )



-- MODEL


type alias Model =
    { todos : List String
    }



-- UPDATE


type Msg
    = UpdateTodo (List String)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UpdateTodo todo ->
            ( { model | todos = todo }
            , Cmd.none
            )



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ div [] <|
            SelectList.selectedMapForList renderRow model.todos
        , div []
            [ text "Results:"
            , div [ Attributes.style "padding-left" "1em" ] <|
                List.map (\str -> div [] [ text str ]) model.todos
            ]
        ]


renderRow : SelectList String -> Html Msg
renderRow selected =
    div
        []
        [ Html.input
            [ Attributes.type_ "text"
            , Events.onInput
                (\str ->
                    SelectList.replaceSelected str selected
                        |> SelectList.toList
                        |> UpdateTodo
                )
            , Attributes.value <| SelectList.selected selected
            ]
            []
        , Html.button
            [ Attributes.type_ "button"
            , Events.onClick
                (SelectList.delete selected
                    |> Maybe.map SelectList.toList
                    |> Maybe.withDefault []
                    |> UpdateTodo
                )
            ]
            [ text "×"
            ]
        , Html.button
            [ Attributes.type_ "button"
            , Events.onClick
                (SelectList.moveBy -1 selected
                    |> SelectList.toList
                    |> UpdateTodo
                )
            ]
            [ text "△"
            ]
        , Html.button
            [ Attributes.type_ "button"
            , Events.onClick
                (SelectList.moveBy 1 selected
                    |> SelectList.toList
                    |> UpdateTodo
                )
            ]
            [ text "▽"
            ]
        ]



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none

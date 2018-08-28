module ListWithSelectList exposing (main)

import Browser
import Html exposing (Html, div, text)
import Html.Events as Events
import SelectList exposing (Position, SelectList)



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
    ( { nums = [ 1, 2, 3, 4, 5, 6 ]
      }
    , Cmd.none
    )



-- MODEL


type alias Model =
    { nums : List Int
    }



-- UPDATE


type Msg
    = ClickNumber (SelectList Int)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ClickNumber selected ->
            ( { model
                | nums =
                    SelectList.toList <| SelectList.modify ((+) 1) selected
              }
            , Cmd.none
            )



-- VIEW


view : Model -> Html Msg
view model =
    div [] <| SelectList.mapBy_ renderRow model.nums


renderRow : SelectList Int -> Html Msg
renderRow selected =
    div
        [ Events.onClick (ClickNumber selected)
        ]
        [ text <| String.fromInt <| SelectList.selected selected
        ]



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none

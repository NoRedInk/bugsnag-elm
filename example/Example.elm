module Example exposing (main)

import Browser
import Bugsnag exposing (BugsnagClient)
import Dict
import Html exposing (..)
import Html.Attributes exposing (value)
import Html.Events exposing (onClick, onInput)
import Json.Encode
import Task


token : String
token =
    -- The api key to the Bugsnag project you want to report errors to.
    -- Bugsnag doesn't formally support Elm, so create a generic JS project.
    -- Bugsnag offers free single-user accounts - go ahead and play around!
    -- https://app.bugsnag.com
    "12345abcde........"

{-| Bugsnag will take any model type and convert it via `Debug.toString` to report as metaData.
You can pass any other value if you do not wish to report your model to the api
-}
bugsnagClient : BugsnagClient Model
bugsnagClient =
    Bugsnag.bugsnagClient
        { token = token
        , codeVersion = "24dcf3a9a9cf1a5e2ea319018644a68f4743a731"
        , context = "Example" -- location, e.g. "Page.Customer.Login.Main"
        , releaseStage = "test"
        , notifyReleaseStages = ["production", "staging", "test"] -- remove "test" to see how unreported errors log in your concosle.
        , user =
            Just
                { id = "42"
                , username = "Leeroy Jenkins"
                , email = "support@bugsnag.com"
                }
        }



-- MODEL --


type alias Model =
    { errorMessage : String
    }


initialModel : Model
initialModel =
    { errorMessage = ""
    }



-- UPDATE --


type Msg
    = SetText String
    | NoOp
    | Send


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        SetText text ->
            ( { model | errorMessage = text }, Cmd.none )

        Send ->
            ( model, notifyBugsnag model.errorMessage model )


notifyBugsnag : String -> Model -> Cmd Msg
notifyBugsnag errorMessage model =
    bugsnagClient.info errorMessage Dict.empty model
        |> Cmd.map (\_ -> NoOp)


json : Json.Encode.Value
json =
    Json.Encode.object [ ( "releaseStage", Json.Encode.string "test" ) ]



-- VIEW --


view : Model -> Html Msg
view model =
    div []
        [ input [ onInput SetText, value model.errorMessage ] []
        , button [ onClick Send ] [ text "Send to bugsnag" ]
        ]



-- INIT --


main : Program () Model Msg
main =
    Browser.document
        { init = \_ -> init
        , subscriptions = \_ -> Sub.none
        , update = update
        , view = \model -> { title = "Example", body = [ view model ] }
        }


init : ( Model, Cmd msg )
init =
    ( initialModel, Cmd.none )

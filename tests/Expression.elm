module Expression exposing (..)

import Expect exposing (Expectation)
import Fuzz exposing (int, list)
import Test exposing (..)


infixr 0 ==>
(==>) : String -> (() -> Expectation) -> Test
(==>) =
    Test.test


infixr 0 ===
(===) : a -> a -> () -> Expectation
(===) a b _ =
    Expect.equal a b


infixr 0 /==
(/==) : a -> a -> () -> Expectation
(/==) a b _ =
    Expect.notEqual a b


isErr : Result a b -> () -> Expectation
isErr result _ =
    case result of
        Ok ok ->
            Expect.fail <| "Not Error. Ok " ++ toString ok

        Err _ ->
            Expect.pass


selectListFuzz : String -> (List Int -> Int -> List Int -> Expectation) -> Test
selectListFuzz =
    fuzz3 (list int) int (list int)

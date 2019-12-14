module PageCss exposing (..)

import Css exposing (..)
import Css.Global as CG exposing (..)
import Html.Styled exposing (toUnstyled)


pageCss =
    toUnstyled <|
        global
            [ body [ fontFamily sansSerif ]
            , CG.table
                [ borderRadius (px 5)
                , border3 (px 1) solid <| rgba 190 190 190 0.25
                , boxShadow5 (px 0) (px 0) (px 20) (px 2) <| rgba 190 190 190 0.25
                , margin (px 0)
                , padding (px 0)
                ]
            , tr [ nthChild "even" [ backgroundColor <| rgba 0 0 0 0.035 ] ]
            , thead
                [ descendants
                    [ tr [ color <| rgb 50 50 50 ] ]
                ]
            , th [ width (pct 15), padding (rem 0.5), textAlign left ]
            , td [ padding (rem 0.5) ]
            , selector ".sort-indicator"
                [ marginLeft (px 10)
                , fontSize (pt 10)
                ]
            , input
                [ borderRadius (px 2)
                , border (px 1)
                , borderColor <| rgb 0 0 0
                , padding (rem 0.25)

                -- , width (pct 100)
                ]

            -- , selector "th > input"
            --     [ width (pct 100) ]
            ]

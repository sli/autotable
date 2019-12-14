module PageCss exposing (..)

import Css exposing (..)
import Css.Global as CG exposing (..)
import Html.Styled exposing (toUnstyled)


pageCss =
    toUnstyled <|
        global
            [ body [ fontFamily sansSerif ]
            , CG.table
                [ borderSpacing (px 0)
                , borderCollapse collapse
                , boxShadow5 (px 0) (px 0) (px 20) (px 2) <| rgba 190 190 190 0.25
                , margin2 (rem 10.0) auto
                , padding (px 0)
                ]
            , thead
                [ descendants
                    [ tr [ color <| rgb 50 50 50, backgroundColor <| rgba 0 0 0 0.035 ]
                    , tr [ lastChild [ borderBottom3 (px 1) solid <| rgba 190 190 190 0.25 ] ]
                    ]
                ]
            , tbody
                [ descendants
                    [ tr
                        [ nthChild "even" [ backgroundColor <| rgba 0 0 0 0.035 ]
                        , borderBottom3 (px 1) solid <| rgba 190 190 190 0.25
                        ]
                    ]
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
                ]
            ]

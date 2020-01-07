module DemoCss exposing (..)

import Css exposing (..)
import Css.Global exposing (..)
import Html.Styled exposing (toUnstyled)


pageCss =
    toUnstyled <|
        global
            [ body [ fontFamily sansSerif ]
            , input
                [ borderRadius (px 3)
                , border3 (px 1) solid <| rgba 0 0 0 0.25
                , padding (rem 0.25)
                , fontSize (pt 12)
                , width (pct 100)
                , focus
                    [ boxShadow5 (px 0) (px 0) (px 2) (px 1) <| hex "63B3ED"
                    ]
                ]
            , button
                [ borderRadius (px 3)
                , border (px 0)
                , padding (rem 0.5)
                , color <| rgb 255 255 255
                , fontSize (pt 12)
                , backgroundColor <| hex "63B3ED"
                ]
            , selector "div.container"
                [ margin2 (px 0) auto
                , width (pct 60)
                ]
            ]


tableDefaultCss =
    toUnstyled <|
        global
            [ selector "table.autotable"
                [ borderSpacing (px 0)
                , borderCollapse collapse
                , borderRadius (px 5)
                , boxShadow5 (px 0) (px 0) (px 20) (px 2) <| rgba 190 190 190 0.25
                , marginTop (rem 2.0)
                , width (pct 100)
                ]
            , selector "div.autotable__pagination"
                [ displayFlex
                , justifyContent flexEnd
                , paddingTop (rem 0.5)
                ]
            , selector "button.autotable__pagination-page"
                [ border3 (px 1) solid <| hex "63B3ED"
                , backgroundColor <| rgb 0 0 0
                , color <| rgb 0 0 0
                , borderRadius (px 2)
                , display inline
                , margin (rem 0.1)
                , padding2 (rem 0.25) (rem 0.5)
                , hover [ cursor pointer ]
                ]
            , selector "button.autotable__pagination-active"
                [ backgroundColor <| hex "63B3ED"
                , color <| hex "FFFFFF"
                ]
            , selector "table.autotable thead"
                [ descendants
                    [ tr
                        [ color <| rgb 50 50 50
                        , backgroundColor <| rgba 0 0 0 0.035
                        , lastChild [ borderBottom3 (px 1) solid <| rgba 190 190 190 0.25 ]
                        ]
                    ]
                ]
            , selector "table.autotable tbody"
                [ descendants
                    [ tr
                        [ nthChild "even" [ backgroundColor <| rgba 0 0 0 0.035 ]
                        , borderBottom3 (px 1) solid <| rgba 190 190 190 0.25
                        , lastChild [ borderBottom (px 0) ]
                        ]
                    ]
                ]
            , th [ width (pct 15), padding (rem 0.5), textAlign left ]
            , td [ padding (rem 0.5) ]
            , selector "span.autotable__sort-indicator"
                [ marginLeft (px 10)
                , fontSize (pt 10)
                ]
            , selector "table.autotable tr.filter-inputs th > input"
                [ borderRadius (px 3)
                , borderColor <| rgba 0 0 0 0.1
                ]
            , selector "table.autotable tbody tr td:not(.editing)"
                [ padding (rem 0.8)
                ]
            ]

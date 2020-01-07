module DemoCss exposing (..)

import Css as C exposing (..)
import Css.Global as CG exposing (..)
import Html.Styled exposing (toUnstyled)


pageCss =
    toUnstyled <|
        global
            [ body [ fontFamily sansSerif ]
            , button
                [ borderRadius (px 3)
                , border zero
                , padding (rem 0.5)
                , color <| rgb 255 255 255
                , fontSize (pt 12)
                , backgroundColor <| hex "63B3ED"
                ]
            , selector "div.container"
                [ margin2 zero auto
                , width (pct 60)
                ]
            ]

emptyFlatTableCss =
    toUnstyled <|
        global
            [ selector "table.autotable" []
            , selector "table.autotable thead" []
            , selector "table.autotable th.autotable__checkbox-header" []
            , selector "table.autotable span.autotable__sort-indicator" []
            , selector "table.autotable th.autotable__column-filter" []
            , selector "table.autotable tbody" []
            , selector "table.autotable td.autotable__checkbox" []
            , selector "table.autotable tbody tr td:not(.editing)" [] -- Probably handy to keep.
            , selector "div.autotable__pagination" []
            , selector "button.autotable__pagination-page" []
            , selector "button.autotable__pagination-active" []
            ]


emptyNestedTableCss =
    toUnstyled <|
        global
            [ selector "table.autotable"
                [ descendants
                    [ thead
                        [ descendants
                            [ selector "th.autotable__checkbox-header" []
                            , selector "th.autotable__column"
                                [ descendants
                                    [ selector "span.autotable__sort-indicator" [] ]
                                ]
                            , selector "th.autotable__column-filter" []
                            ]
                        ]
                    , tbody
                        [ descendants
                            [ selector "td.autotable__checkbox" []
                            , selector "td.autotable__actions" []
                            , selector "td:not(.editing)" [] -- Probably handy to keep.
                            ]
                        ]
                    ]
                ]
            , selector "div.autotable__pagination" []
            , selector "button.autotable__pagination-page" []
            , selector "button.autotable__pagination-active" []
            ]


tableDefaultCss =
    toUnstyled <|
        global
            [ selector "table.autotable"
                [ borderSpacing zero
                , borderCollapse collapse
                , borderRadius (px 5)
                , boxShadow5 zero zero (px 20) (px 2) <| rgba 190 190 190 0.25
                , marginTop (rem 2.0)
                , width (pct 100)
                , descendants
                    [ thead
                        [ descendants
                            [ tr
                                [ color <| rgb 50 50 50
                                , backgroundColor <| rgba 0 0 0 0.035
                                , lastChild [ borderBottom3 (px 1) solid <| rgba 190 190 190 0.25 ]
                                ]
                            , th
                                [ width (pct 15)
                                , padding (rem 0.5)
                                , textAlign left
                                ]
                            , selector "th.autotable__checkbox-header" []
                            , selector "th.autotable__column"
                                [ descendants
                                    [ selector "span.autotable__sort-indicator"
                                        [ marginLeft (px 10)
                                        , fontSize (pt 10)
                                        ]
                                    ]
                                ]
                            , selector "th.autotable__column-filter"
                                [ descendants
                                    [ input
                                        [ borderRadius (px 3)
                                        , border3 (px 1) solid <| rgba 0 0 0 0.25
                                        , padding (rem 0.25)
                                        , fontSize (pt 12)
                                        , width (pct 100)
                                        , focus [ boxShadow5 zero zero (px 2) (px 1) <| hex "63B3ED" ]
                                        ]
                                    ]
                                ]
                            ]
                        ]
                    , tbody
                        [ descendants
                            [ tr
                                [ nthChild "even" [ backgroundColor <| rgba 0 0 0 0.035 ]
                                , borderBottom3 (px 1) solid <| rgba 190 190 190 0.25
                                , lastChild [ borderBottom zero ]
                                ]
                            , td
                                [ padding (rem 0.5)
                                , descendants
                                    [ input
                                        [ borderRadius (px 3)
                                        , border3 (px 1) solid <| rgba 0 0 0 0.25
                                        , padding (rem 0.25)
                                        , fontSize (pt 12)
                                        , width (pct 100)
                                        , focus [ boxShadow5 zero zero (px 2) (px 1) <| hex "63B3ED" ]
                                        ]
                                    ]
                                ]
                            , selector "td.autotable__checkbox" []
                            , selector "td.autotable__actions" []
                            , selector "td:not(.editing)"
                                [ padding (rem 0.8) ]

                            -- Probably handy to keep.
                            ]
                        ]
                    ]
                ]
            , selector "div.autotable__pagination"
                [ displayFlex
                , justifyContent flexEnd
                , paddingTop (rem 0.5)
                ]
            , selector "button.autotable__pagination-page"
                [ border3 (px 1) solid <| hex "63B3ED"
                , backgroundColor <| rgb 255 255 255
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
            ]


tableOldDefaultCss =
    toUnstyled <|
        global
            [ selector "table.autotable"
                [ borderSpacing zero
                , borderCollapse collapse
                , borderRadius (px 5)
                , boxShadow5 zero zero (px 20) (px 2) <| rgba 190 190 190 0.25
                , marginTop (rem 2.0)
                , width (pct 100)
                ]
            , selector "table.autotable thead"
                [ descendants
                    [ tr
                        [ color <| rgb 50 50 50
                        , backgroundColor <| rgba 0 0 0 0.035
                        , lastChild [ borderBottom3 (px 1) solid <| rgba 190 190 190 0.25 ]
                        ]
                    , th
                        [ width (pct 15)
                        , padding (rem 0.5)
                        , textAlign left
                        ]
                    ]
                ]
            , selector "table.autotable th.autotable__checkbox-header" []
            , selector "table.autotable span.autotable__sort-indicator"
                [ marginLeft (px 10)
                , fontSize (pt 10)
                ]
            , selector "table.autotable th.autotable__column-filter"
                [ descendants
                    [ input
                        [ borderRadius (px 3)
                        , border3 (px 1) solid <| rgba 0 0 0 0.25
                        , padding (rem 0.25)
                        , fontSize (pt 12)
                        , width (pct 100)
                        , focus [ boxShadow5 zero zero (px 2) (px 1) <| hex "63B3ED" ]
                        ]
                    ]
                ]
            , selector "table.autotable tbody"
                [ descendants
                    [ tr
                        [ nthChild "even" [ backgroundColor <| rgba 0 0 0 0.035 ]
                        , borderBottom3 (px 1) solid <| rgba 190 190 190 0.25
                        , lastChild [ borderBottom zero ]
                        ]
                    , td [ padding (rem 0.5) ]
                    ]
                ]
            , selector "table.autotable td.autotable__checkbox" []
            , selector "table.autotable tbody tr td:not(.editing)"
                [ padding (rem 0.8) ]
            , selector "div.autotable__pagination"
                [ displayFlex
                , justifyContent flexEnd
                , paddingTop (rem 0.5)
                ]
            , selector "button.autotable__pagination-page"
                [ border3 (px 1) solid <| hex "63B3ED"
                , backgroundColor <| rgb 255 255 255
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
            ]

module PageCss exposing (..)

import Css exposing (..)
import Css.Global as CG exposing (..)
import Html.Styled exposing (toUnstyled)


pageCss =
    toUnstyled <|
        global
            [ body [ fontFamily sansSerif ]
            , CG.table []
            , tr [ nthChild "even" [ backgroundColor <| rgba 0 0 0 0.1 ] ]
            , thead []
            , typeSelector "thead"
                [ descendants
                    [ typeSelector "tr"
                        [ backgroundColor <| rgb 0 0 0
                        , color <| rgb 255 255 255
                        ]
                    ]
                ]
            , th [ margin2 (px 0) auto, width (pct 15) ]
            , td []
            ]

module Constants exposing (apiUrl)

import Data.Mode exposing (Mode(..))


apiUrl : Mode -> String
apiUrl mode =
    case mode of
        Development ->
            "http://localhost:9081"

        Production ->
            "https://api.parasrah.com:9091"

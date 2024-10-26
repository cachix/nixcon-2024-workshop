{-
   Flakestry API
   No description provided (generated by Openapi Generator https://github.com/openapitools/openapi-generator)

   The version of the OpenAPI document: 0.1.0

   NOTE: This file is auto generated by the openapi-generator.
   https://github.com/openapitools/openapi-generator.git

   DO NOT EDIT THIS FILE MANUALLY.

   For more info on generating Elm code, see https://eriktim.github.io/openapi-elm/
-}


module Api.Data exposing
    ( AnyType
    , FlakeRelease
    , GetFlakeResponse
    , GetOwnerResponse
    , GetRepoResponse
    , Publish
    , Release
    , anyTypeDecoder
    , encodeFlakeRelease
    , encodeGetFlakeResponse
    , encodeGetOwnerResponse
    , encodeGetRepoResponse
    , encodePublish
    , encodeRelease
    , flakeReleaseDecoder
    , getFlakeResponseDecoder
    , getOwnerResponseDecoder
    , getRepoResponseDecoder
    , publishDecoder
    , releaseDecoder
    )

import Api
import Api.Time exposing (Posix)
import Dict
import Json.Decode
import Json.Encode



-- MODEL


type alias FlakeRelease =
    { commit : Maybe String
    , createdAt : Posix
    , description : String
    , owner : String
    , readme : Maybe String
    , repo : String
    , version : String
    }


type alias GetFlakeResponse =
    { count : Int
    , query : Maybe String
    , releases : List FlakeRelease
    }


type alias GetOwnerResponse =
    { repos : List FlakeRelease
    }


type alias GetRepoResponse =
    { releases : List FlakeRelease
    }


type alias Publish =
    { metadata : Maybe JsonObject
    , metadataErrors : Maybe String
    , outputs : Maybe JsonObject
    , outputsErrors : Maybe String
    , owner : String
    , readme : Maybe String
    , ref : Maybe String
    , repository : String
    , version : Maybe String
    }


type alias Release =
    { commit : String
    , createdAt : Posix
    , description : Maybe String
    , metaData : Maybe JsonObject
    , metaDataErrors : Maybe (List String)
    , outputs : Maybe JsonObject
    , outputsErrors : Maybe (List String)
    , readme : Maybe String
    , readmeFilename : Maybe String
    , repoId : Int
    , version : String
    }



-- ENCODER


encodeFlakeRelease : FlakeRelease -> Json.Encode.Value
encodeFlakeRelease =
    encodeObject << encodeFlakeReleasePairs


encodeFlakeReleaseWithTag : ( String, String ) -> FlakeRelease -> Json.Encode.Value
encodeFlakeReleaseWithTag ( tagField, tag ) model =
    encodeObject (encodeFlakeReleasePairs model ++ [ encode tagField Json.Encode.string tag ])


encodeFlakeReleasePairs : FlakeRelease -> List EncodedField
encodeFlakeReleasePairs model =
    let
        pairs =
            [ maybeEncode "commit" Json.Encode.string model.commit
            , encode "created_at" Api.Time.encodeDateTime model.createdAt
            , encode "description" Json.Encode.string model.description
            , encode "owner" Json.Encode.string model.owner
            , maybeEncode "readme" Json.Encode.string model.readme
            , encode "repo" Json.Encode.string model.repo
            , encode "version" Json.Encode.string model.version
            ]
    in
    pairs


encodeGetFlakeResponse : GetFlakeResponse -> Json.Encode.Value
encodeGetFlakeResponse =
    encodeObject << encodeGetFlakeResponsePairs


encodeGetFlakeResponseWithTag : ( String, String ) -> GetFlakeResponse -> Json.Encode.Value
encodeGetFlakeResponseWithTag ( tagField, tag ) model =
    encodeObject (encodeGetFlakeResponsePairs model ++ [ encode tagField Json.Encode.string tag ])


encodeGetFlakeResponsePairs : GetFlakeResponse -> List EncodedField
encodeGetFlakeResponsePairs model =
    let
        pairs =
            [ encode "count" Json.Encode.int model.count
            , maybeEncodeNullable "query" Json.Encode.string model.query
            , encode "releases" (Json.Encode.list encodeFlakeRelease) model.releases
            ]
    in
    pairs


encodeGetOwnerResponse : GetOwnerResponse -> Json.Encode.Value
encodeGetOwnerResponse =
    encodeObject << encodeGetOwnerResponsePairs


encodeGetOwnerResponseWithTag : ( String, String ) -> GetOwnerResponse -> Json.Encode.Value
encodeGetOwnerResponseWithTag ( tagField, tag ) model =
    encodeObject (encodeGetOwnerResponsePairs model ++ [ encode tagField Json.Encode.string tag ])


encodeGetOwnerResponsePairs : GetOwnerResponse -> List EncodedField
encodeGetOwnerResponsePairs model =
    let
        pairs =
            [ encode "repos" (Json.Encode.list encodeFlakeRelease) model.repos
            ]
    in
    pairs


encodeGetRepoResponse : GetRepoResponse -> Json.Encode.Value
encodeGetRepoResponse =
    encodeObject << encodeGetRepoResponsePairs


encodeGetRepoResponseWithTag : ( String, String ) -> GetRepoResponse -> Json.Encode.Value
encodeGetRepoResponseWithTag ( tagField, tag ) model =
    encodeObject (encodeGetRepoResponsePairs model ++ [ encode tagField Json.Encode.string tag ])


encodeGetRepoResponsePairs : GetRepoResponse -> List EncodedField
encodeGetRepoResponsePairs model =
    let
        pairs =
            [ encode "releases" (Json.Encode.list encodeFlakeRelease) model.releases
            ]
    in
    pairs


encodePublish : Publish -> Json.Encode.Value
encodePublish =
    encodeObject << encodePublishPairs


encodePublishWithTag : ( String, String ) -> Publish -> Json.Encode.Value
encodePublishWithTag ( tagField, tag ) model =
    encodeObject (encodePublishPairs model ++ [ encode tagField Json.Encode.string tag ])


encodePublishPairs : Publish -> List EncodedField
encodePublishPairs model =
    let
        pairs =
            [ maybeEncodeNullable "metadata" encodeJsonObject model.metadata
            , maybeEncodeNullable "metadata_errors" Json.Encode.string model.metadataErrors
            , maybeEncodeNullable "outputs" encodeJsonObject model.outputs
            , maybeEncodeNullable "outputs_errors" Json.Encode.string model.outputsErrors
            , encode "owner" Json.Encode.string model.owner
            , maybeEncodeNullable "readme" Json.Encode.string model.readme
            , maybeEncodeNullable "ref_" Json.Encode.string model.ref
            , encode "repository" Json.Encode.string model.repository
            , maybeEncodeNullable "version" Json.Encode.string model.version
            ]
    in
    pairs


encodeRelease : Release -> Json.Encode.Value
encodeRelease =
    encodeObject << encodeReleasePairs


encodeReleaseWithTag : ( String, String ) -> Release -> Json.Encode.Value
encodeReleaseWithTag ( tagField, tag ) model =
    encodeObject (encodeReleasePairs model ++ [ encode tagField Json.Encode.string tag ])


encodeReleasePairs : Release -> List EncodedField
encodeReleasePairs model =
    let
        pairs =
            [ encode "commit" Json.Encode.string model.commit
            , encode "created_at" Api.Time.encodeDateTime model.createdAt
            , maybeEncodeNullable "description" Json.Encode.string model.description
            , maybeEncodeNullable "meta_data" encodeJsonObject model.metaData
            , maybeEncode "meta_data_errors" (Json.Encode.list Json.Encode.string) model.metaDataErrors
            , maybeEncodeNullable "outputs" encodeJsonObject model.outputs
            , maybeEncode "outputs_errors" (Json.Encode.list Json.Encode.string) model.outputsErrors
            , maybeEncodeNullable "readme" Json.Encode.string model.readme
            , maybeEncodeNullable "readme_filename" Json.Encode.string model.readmeFilename
            , encode "repo_id" Json.Encode.int model.repoId
            , encode "version" Json.Encode.string model.version
            ]
    in
    pairs



-- DECODER


flakeReleaseDecoder : Json.Decode.Decoder FlakeRelease
flakeReleaseDecoder =
    Json.Decode.succeed FlakeRelease
        |> maybeDecode "commit" Json.Decode.string Nothing
        |> decode "created_at" Api.Time.dateTimeDecoder
        |> decode "description" Json.Decode.string
        |> decode "owner" Json.Decode.string
        |> maybeDecode "readme" Json.Decode.string Nothing
        |> decode "repo" Json.Decode.string
        |> decode "version" Json.Decode.string


getFlakeResponseDecoder : Json.Decode.Decoder GetFlakeResponse
getFlakeResponseDecoder =
    Json.Decode.succeed GetFlakeResponse
        |> decode "count" Json.Decode.int
        |> maybeDecodeNullable "query" Json.Decode.string Nothing
        |> decode "releases" (Json.Decode.list flakeReleaseDecoder)


getOwnerResponseDecoder : Json.Decode.Decoder GetOwnerResponse
getOwnerResponseDecoder =
    Json.Decode.succeed GetOwnerResponse
        |> decode "repos" (Json.Decode.list flakeReleaseDecoder)


getRepoResponseDecoder : Json.Decode.Decoder GetRepoResponse
getRepoResponseDecoder =
    Json.Decode.succeed GetRepoResponse
        |> decode "releases" (Json.Decode.list flakeReleaseDecoder)


publishDecoder : Json.Decode.Decoder Publish
publishDecoder =
    Json.Decode.succeed Publish
        |> maybeDecodeNullable "metadata" jsonObjectDecoder Nothing
        |> maybeDecodeNullable "metadata_errors" Json.Decode.string Nothing
        |> maybeDecodeNullable "outputs" jsonObjectDecoder Nothing
        |> maybeDecodeNullable "outputs_errors" Json.Decode.string Nothing
        |> decode "owner" Json.Decode.string
        |> maybeDecodeNullable "readme" Json.Decode.string Nothing
        |> maybeDecodeNullable "ref_" Json.Decode.string Nothing
        |> decode "repository" Json.Decode.string
        |> maybeDecodeNullable "version" Json.Decode.string Nothing


releaseDecoder : Json.Decode.Decoder Release
releaseDecoder =
    Json.Decode.succeed Release
        |> decode "commit" Json.Decode.string
        |> decode "created_at" Api.Time.dateTimeDecoder
        |> maybeDecodeNullable "description" Json.Decode.string Nothing
        |> maybeDecodeNullable "meta_data" jsonObjectDecoder Nothing
        |> maybeDecode "meta_data_errors" (Json.Decode.list Json.Decode.string) Nothing
        |> maybeDecodeNullable "outputs" jsonObjectDecoder Nothing
        |> maybeDecode "outputs_errors" (Json.Decode.list Json.Decode.string) Nothing
        |> maybeDecodeNullable "readme" Json.Decode.string Nothing
        |> maybeDecodeNullable "readme_filename" Json.Decode.string Nothing
        |> decode "repo_id" Json.Decode.int
        |> decode "version" Json.Decode.string



-- HELPER


type alias AnyType =
    ()


anyTypeDecoder : Json.Decode.Decoder AnyType
anyTypeDecoder =
    Json.Decode.succeed ()


type alias JsonObject =
    Json.Decode.Value


encodeJsonObject : JsonObject -> Json.Encode.Value
encodeJsonObject =
    identity


jsonObjectDecoder : Json.Decode.Decoder JsonObject
jsonObjectDecoder =
    Json.Decode.value


type alias EncodedField =
    Maybe ( String, Json.Encode.Value )


encodeObject : List EncodedField -> Json.Encode.Value
encodeObject =
    Json.Encode.object << List.filterMap identity


encode : String -> (a -> Json.Encode.Value) -> a -> EncodedField
encode key encoder value =
    Just ( key, encoder value )


encodeNullable : String -> (a -> Json.Encode.Value) -> Maybe a -> EncodedField
encodeNullable key encoder value =
    Just ( key, Maybe.withDefault Json.Encode.null (Maybe.map encoder value) )


maybeEncode : String -> (a -> Json.Encode.Value) -> Maybe a -> EncodedField
maybeEncode key encoder =
    Maybe.map (Tuple.pair key << encoder)


maybeEncodeNullable : String -> (a -> Json.Encode.Value) -> Maybe a -> EncodedField
maybeEncodeNullable =
    encodeNullable


decode : String -> Json.Decode.Decoder a -> Json.Decode.Decoder (a -> b) -> Json.Decode.Decoder b
decode key decoder =
    decodeChain (Json.Decode.field key decoder)


decodeLazy : (a -> c) -> String -> Json.Decode.Decoder a -> Json.Decode.Decoder (c -> b) -> Json.Decode.Decoder b
decodeLazy f key decoder =
    decodeChainLazy f (Json.Decode.field key decoder)


decodeNullable : String -> Json.Decode.Decoder a -> Json.Decode.Decoder (Maybe a -> b) -> Json.Decode.Decoder b
decodeNullable key decoder =
    decodeChain (maybeField key decoder Nothing)


decodeNullableLazy : (Maybe a -> c) -> String -> Json.Decode.Decoder a -> Json.Decode.Decoder (c -> b) -> Json.Decode.Decoder b
decodeNullableLazy f key decoder =
    decodeChainLazy f (maybeField key decoder Nothing)


maybeDecode : String -> Json.Decode.Decoder a -> Maybe a -> Json.Decode.Decoder (Maybe a -> b) -> Json.Decode.Decoder b
maybeDecode key decoder fallback =
    -- let's be kind to null-values as well
    decodeChain (maybeField key decoder fallback)


maybeDecodeLazy : (Maybe a -> c) -> String -> Json.Decode.Decoder a -> Maybe a -> Json.Decode.Decoder (c -> b) -> Json.Decode.Decoder b
maybeDecodeLazy f key decoder fallback =
    -- let's be kind to null-values as well
    decodeChainLazy f (maybeField key decoder fallback)


maybeDecodeNullable : String -> Json.Decode.Decoder a -> Maybe a -> Json.Decode.Decoder (Maybe a -> b) -> Json.Decode.Decoder b
maybeDecodeNullable key decoder fallback =
    decodeChain (maybeField key decoder fallback)


maybeDecodeNullableLazy : (Maybe a -> c) -> String -> Json.Decode.Decoder a -> Maybe a -> Json.Decode.Decoder (c -> b) -> Json.Decode.Decoder b
maybeDecodeNullableLazy f key decoder fallback =
    decodeChainLazy f (maybeField key decoder fallback)


maybeField : String -> Json.Decode.Decoder a -> Maybe a -> Json.Decode.Decoder (Maybe a)
maybeField key decoder fallback =
    let
        fieldDecoder =
            Json.Decode.field key Json.Decode.value

        valueDecoder =
            Json.Decode.oneOf [ Json.Decode.map Just decoder, Json.Decode.null fallback ]

        decodeObject rawObject =
            case Json.Decode.decodeValue fieldDecoder rawObject of
                Ok rawValue ->
                    case Json.Decode.decodeValue valueDecoder rawValue of
                        Ok value ->
                            Json.Decode.succeed value

                        Err error ->
                            Json.Decode.fail (Json.Decode.errorToString error)

                Err _ ->
                    Json.Decode.succeed fallback
    in
    Json.Decode.value
        |> Json.Decode.andThen decodeObject


decodeChain : Json.Decode.Decoder a -> Json.Decode.Decoder (a -> b) -> Json.Decode.Decoder b
decodeChain =
    Json.Decode.map2 (|>)


decodeChainLazy : (a -> c) -> Json.Decode.Decoder a -> Json.Decode.Decoder (c -> b) -> Json.Decode.Decoder b
decodeChainLazy f =
    decodeChain << Json.Decode.map f

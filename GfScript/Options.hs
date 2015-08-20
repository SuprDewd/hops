-- |
-- Copyright   : Anders Claesson 2015
-- Maintainer  : Anders Claesson <anders.claesson@gmail.com>
-- License     : BSD-3
--
-- Command line options for gfscript.

module GfScript.Options
    ( Options (..)
    , getOptions
    ) where

import Options.Applicative

-- | Command line options:
data Options = Options
    {
    -- | Filename of script to run.
      script         :: String
    -- | Generating function precision.
    , prec           :: Int
    -- | Tag sequences with TAG-numbers
    , tagSeqs        :: Maybe Int
    -- | List all transforms
    , listTransforms :: Bool
    -- | convert to JSON
    , tojson         :: Bool
    -- | convert from JSON
    , fromjson       :: Bool
    -- | Output all the sequences of the local DB
    , dumpSeqs       :: Bool
    -- | Updated local DB
    , update         :: Bool
    -- | Show version info
    , version        :: Bool
    -- Search terms or programs
    , terms          :: [String]
    }

-- | Parse command line options.
optionsParser :: Parser Options
optionsParser =
  abortOption ShowHelpText (long "help") <*> (Options
    <$> strOption
        ( short 'f'
       <> long "script"
       <> metavar "FILENAME"
       <> value ""
       <> help "Filename of script to run" )
    <*> option auto
        ( long "prec"
       <> metavar "N"
       <> value 15
       <> help "Generating function precision [default: 15]" )
    <*> optional (option auto
        ( long "tag"
       <> metavar "N"
       <> help "Read sequences from stdin and tag them, starting at N" ))
    <*> switch
        ( long "list-transforms"
       <> help "List the names of all transforms" )
    <*> switch
        ( long "to-json"
       <> help "Convert to JSON" )
    <*> switch
        ( long "from-json"
       <> help "Convert from JSON" )
    <*> switch
        ( long "dump"
       <> help "Output all the sequences of the local DB" )
    <*> switch
        ( long "update"
       <> help "Update the local database" )
    <*> switch
        ( long "version"
       <> help "Show version info" )
    <*> many (argument str (metavar "TERMS...")))

-- | Run the command line options parser (above).
getOptions :: IO Options
getOptions = execParser (info optionsParser fullDesc)
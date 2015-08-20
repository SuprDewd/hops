{-# LANGUAGE CPP #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveGeneric #-}

-- |
-- Copyright   : Anders Claesson 2015
-- Maintainer  : Anders Claesson <anders.claesson@gmail.com>
-- License     : BSD-3
--

module GfScript.Entry
    ( Entry (..)
    , PackedEntry (..)
    , parsePackedEntryErr
    , parseEntry
    ) where

import GHC.Generics (Generic)
import Data.Monoid
import Data.Maybe
import Data.ByteString.Char8 (ByteString)
import qualified Data.ByteString.Char8 as B
import qualified Data.Attoparsec.ByteString.Char8 as Ch
import Data.Attoparsec.ByteString.Char8
import Data.Aeson
import Control.Monad
#if __GLASGOW_HASKELL__ < 710
import Control.Applicative
#endif
import GfScript.Utils
import GfScript.Gf
import GfScript.OEIS

-- | An entry consists of a program together with a list of rational
-- numbers.
data Entry = Entry
    { getPrg :: Prg Integer
    , getSeq :: [Rational]
    } deriving (Eq, Show)

-- | Similary, a packed entry consists of a packed program together with
-- a packed sequence.
data PackedEntry = PackedEntry
    { getPackedPrg :: PackedPrg
    , getPackedSeq :: PackedSeq
    } deriving (Eq, Show, Generic)

instance ToJSON PackedEntry where
    toJSON (PackedEntry p s) =
        object [ "prg" .= toJSON p
               , "seq" .= toJSON ("{" <> s <> "}")
               ]

instance FromJSON PackedEntry where
    parseJSON (Object v) =
        let shave' = PSeq . shave . unPSeq
        in PackedEntry <$> v .: "prg" <*> (shave' <$> v .: "seq")
    parseJSON _ = mzero

packedEntry :: Parser PackedEntry
packedEntry =
    let f w = if B.last w == '=' then return (PPrg (B.init w)) else mzero
    in PackedEntry <$> (Ch.takeWhile1 (/='>') >>= f)
                   <*> (char '>' *> packedSeq)

-- | A parser for packed entries.
parsePackedEntry :: ByteString -> Maybe PackedEntry
parsePackedEntry = parse_ packedEntry . B.filter (/=' ')

-- | Like `parsePackedEntry` but throws an error rather than returning
-- `Nothing` in case the parse fails.
parsePackedEntryErr :: ByteString -> PackedEntry
parsePackedEntryErr = fromMaybe (error "cannot parse input") . parsePackedEntry

-- | A parser for entries.
parseEntry :: ByteString -> Entry
parseEntry b =
    let PackedEntry (PPrg p) (PSeq s) = parsePackedEntryErr b
    in Entry (parsePrgErr p) (parseSeqErr s)
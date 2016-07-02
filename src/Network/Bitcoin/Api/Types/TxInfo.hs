{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell   #-}

module Network.Bitcoin.Api.Types.TxInfo where

import           Control.Applicative ((<$>), (<*>))
import           Control.Lens.TH     (makeLenses)
import           Control.Monad       (mzero)

import qualified Data.Base58String   as B58S
import           Data.Word           (Word64, Word32)

import           Data.Aeson
import           Data.Aeson.Types

import qualified Data.Bitcoin.Types  as BT
import qualified Data.Bitcoin.Transaction as Tx

import qualified Data.Text           as T


data TxInfo = TxInfo {
   txid        :: BT.TransactionId
  ,vouts       :: [Vout]
  ,confs       :: Integer
  ,blockhash   :: BT.BlockHash
} deriving (Eq, Show)


instance FromJSON TxInfo where
  parseJSON (Object o) =
    TxInfo
      <$> o .:  "txid"
      <*> o .:  "vout"
      <*> o .:  "confirmations"
      <*> o .:  "blockhash"
  parseJSON _          = mzero


data Vout = Vout {
   amount      :: BT.Btc
  ,index       :: Word32
  ,addresses   :: [B58S.Base58String]
} deriving (Eq, Show)

parseScriptPubKey :: Value -> Parser [B58S.Base58String]
parseScriptPubKey (Object o) = o .: "addresses"
parseScriptPubKey _ = mzero

instance FromJSON Vout where
  parseJSON (Object o) =
    Vout
      <$> o .:  "value"
      <*> o .:  "n"
      <*> ( (o .:  "scriptPubKey") >>= parseScriptPubKey )
  parseJSON _          = mzero
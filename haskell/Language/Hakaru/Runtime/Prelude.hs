{-# LANGUAGE GADTs
           , DataKinds
           , OverloadedStrings
           #-}

{-# OPTIONS_GHC -Wall -fwarn-tabs -fsimpl-tick-factor=1000 #-}
module Language.Hakaru.Runtime.Prelude where

import qualified System.Random.MWC               as MWC
import qualified System.Random.MWC.Distributions as MWCD
import           Data.Number.Natural
import qualified Control.Monad                   as M
import           Prelude hiding ((>>=))


lam :: (a -> b) -> a -> b
lam = id

let_ :: a -> (a -> b) -> b
let_ x f = let x1 = x in f x1

normal :: Double -> Double -> MWC.GenIO -> IO Double
normal mu sd g = MWCD.normal mu sd g

(>>=) :: (MWC.GenIO -> IO a)
      -> (a -> MWC.GenIO -> IO b)
      -> MWC.GenIO
      -> IO b
m >>= f = \g -> m g M.>>= flip f g

dirac :: a -> MWC.GenIO -> IO a
dirac x _ = return x

nat_ :: Integer -> Integer
nat_ = id

nat2prob :: Integer -> Double
nat2prob = fromIntegral

nat2real :: Integer -> Double
nat2real = fromIntegral

real_ :: Rational -> Double
real_ = fromRational

prob_ :: NonNegativeRational -> Double
prob_ = fromRational . fromNonNegativeRational

run :: Show a => MWC.GenIO -> (MWC.GenIO -> IO a) -> IO ()
run g k = k g M.>>= print

iterateM_ :: Monad m => (a -> m a) -> a -> m b
iterateM_ f = g
    where g x = f x M.>>= g

withPrint :: Show a => (a -> IO b) -> a -> IO b
withPrint f x = print x >> f x

{-# LANGUAGE FlexibleInstances
           , GADTs
           , DataKinds
           , TypeOperators
           , ViewPatterns
           , KindSignatures
           , RankNTypes
           , UndecidableInstances 
           #-}

{-# OPTIONS_GHC -Wall -fwarn-tabs #-}
-- |
-- Module      :  Language.Hakaru.Syntax.Command  
-- Copyright   :  Copyright (c) 2016 the Hakaru team
-- License     :  BSD3
-- Stability   :  experimental
-- Portability :  GHC-only
--
-- An encoding of (some) Hakaru commands and their types. 
----------------------------------------------------------------
module Language.Hakaru.Syntax.Command where 
    
import Language.Hakaru.Types.Sing
import Language.Hakaru.Types.DataKind
import Language.Hakaru.Syntax.ABT
import Language.Hakaru.Syntax.AST
import Language.Hakaru.Syntax.IClasses
import GHC.TypeLits (Symbol)

----------------------------------------------------------------

data CommandType (c :: Symbol) (i :: Hakaru) (o :: Hakaru) where 
  Simplify     :: CommandType "Simplify"     a a 
  DisintMeas   :: CommandType "Disintegrate" (HMeasure (HPair a b)) (a :-> HMeasure b)
  DisintFun    :: !(CommandType "Disintegrate" x x') 
               -> CommandType "Disintegrate" (a :-> x) (a :-> x') 
  Summarize    :: CommandType "Summarize"     a a 

commandIsType :: CommandType c i o -> Sing i -> Sing o
commandIsType DisintMeas (SMeasure (sUnPair->(a,b))) = SFun a (SMeasure b)
commandIsType (DisintFun t) (SFun a x) = SFun a (commandIsType t x)
commandIsType Simplify x = x
commandIsType Summarize x = x
  
nameOfCommand :: CommandType c i o -> Sing c
nameOfCommand Simplify{} = sing 
nameOfCommand Summarize{} = sing 
nameOfCommand DisintMeas{} = sing
nameOfCommand DisintFun{} = sing 

commandFromName 
  :: Sing c 
  -> Sing i 
  -> (forall o . Maybe (CommandType c i o, Sing o) -> k) 
  -> k
commandFromName (jmEq1 (sing :: Sing "Simplify") -> Just Refl) i k = k $ Just (Simplify, i)

commandFromName (jmEq1 (sing :: Sing "Disintegrate") -> Just Refl) i k = 
  case i of 
    SMeasure (SData (STyApp (STyApp (STyCon (jmEq1 sSymbol_Pair -> Just Refl)) a) b) _) -> 
      k $ Just (DisintMeas, SFun a (SMeasure b))
    SFun a x -> 
      commandFromName (sing :: Sing "Disintegrate") x $ \q -> 
        k $ fmap (\(c,x') -> (DisintFun c, SFun a x')) q

commandFromName (jmEq1 (sing :: Sing "Summarize") -> Just Refl) i k = k $ Just (Summarize, i)

commandFromName _ _ k = k Nothing 



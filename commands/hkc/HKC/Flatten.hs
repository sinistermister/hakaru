{-# LANGUAGE DataKinds,
             FlexibleContexts,
             GADTs #-}

module HKC.Flatten where

import Language.Hakaru.Syntax.AST
import Language.Hakaru.Syntax.ABT

import Language.C.Data.Node
import Language.C.Data.Position
import Language.C.Syntax.AST

flatten :: ABT Term abt => abt xs a -> CTranslUnit
flatten e =
  let n = undefNode in
  case viewABT e of
    (Syn x) -> flattenSyn x
    _           -> CTranslUnit [CDeclExt (CDecl [CTypeSpec (CIntType n)] [] n)] n
    -- (Var x)    -> CTranslUnit [] undefNode
    -- (Bind x v) -> CTranslUnit [] undefNode

flattenSyn :: Term abt a -> CTranslUnit
flattenSyn (Literal_ (LNat x)) = undefined
flattenSyn x = CTranslUnit [CDeclExt (CDecl [CTypeSpec (CIntType n)] [] n)] n
  where n = undefNode

-- | Types of literals are 'HNat, 'HInt, 'HProb, 'HReal

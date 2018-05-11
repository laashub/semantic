{-# LANGUAGE TypeFamilies #-}
module Serializing.DOT
( Style
, serializeDOT
) where

import Algebra.Graph.Class
import Algebra.Graph.Export hiding (export, (<+>))
import qualified Algebra.Graph.Export as E
import Algebra.Graph.Export.Dot hiding (export)
import Data.List
import Data.String
import Prologue

serializeDOT :: (IsString s, Monoid s, Ord a, ToGraph g, ToVertex g ~ a) => Style a s -> g -> s
serializeDOT Style {..} g = render $ header <> body <> "}\n"
  where
    header    = "digraph" <+> literal graphName <> "\n{\n"
             <> literal preamble <> "\n"
    with x as = if null as then mempty else line (x <+> attributes as)
    line s    = indent 2 s <> "\n"
    body      = ("graph" `with` graphAttributes)
             <> ("node"  `with` defaultVertexAttributes)
             <> ("edge"  `with` defaultEdgeAttributes)
             <> E.export vDoc eDoc g
    label     = doubleQuotes . literal . vertexName
    vDoc x    = line $ label x <+>                      attributes (vertexAttributes x)
    eDoc x y  = line $ label x <> " -> " <> label y <+> attributes (edgeAttributes x y)


(<+>) :: IsString s => Doc s -> Doc s -> Doc s
x <+> y = x <> " " <> y

attributes :: IsString s => [Attribute s] -> Doc s
attributes [] = mempty
attributes as = brackets . mconcat . intersperse " " $ map dot as
  where
    dot (k := v) = literal k <> "=" <> doubleQuotes (literal v)

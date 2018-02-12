module Main where

import Data.Semigroup
import qualified Data.Text as Text
import qualified Data.Text.Unsafe as Unsafe
import Test.QuickCheck.Function as QC
import Test.Tasty
import Test.Tasty.QuickCheck

import qualified Data.Rope.UTF16 as Rope
import qualified Data.Rope.UTF16.Internal.Text as Rope

main :: IO ()
main = defaultMain $ testGroup "Tests"
  [ testProperty "toText . fromText = id" $ \s -> do
    let t = Text.pack s
    Rope.toText (Rope.fromText t) == t

  , testProperty "append matches Text" $ \s1 s2 -> do
    let t1 = Text.pack s1
        t2 = Text.pack s2
    Rope.toText (Rope.fromText t1 <> Rope.fromText t2) == t1 <> t2

  , testProperty "length is UTF-16 code units" $ \s -> do
    let t = Text.pack s
    Rope.length (Rope.fromText t) == Unsafe.lengthWord16 t

  , testProperty "splitAt matches Text" $ \s i -> do
    let t = Text.pack s
        (r1, r2) = Rope.splitAt i $ Rope.fromText t
    (Rope.toText r1, Rope.toText r2) == Rope.split16At i t

  , testProperty "take matches Text" $ \s i -> do
    let t = Text.pack s
    Rope.toText (Rope.take i $ Rope.fromText t) == Rope.take16 i t

  , testProperty "drop matches Text" $ \s i -> do
    let t = Text.pack s
    Rope.toText (Rope.drop i $ Rope.fromText t) == Rope.drop16 i t

  , testProperty "rowColumnCodeUnits first line" $ \s i -> do
    let t = Text.pack $ takeWhile (/= '\n') s
    Rope.clamp16 i t == Rope.rowColumnCodeUnits (Rope.RowColumn 0 i) (Rope.fromText t)

  , testProperty "rowColumnCodeUnits subsequent lines" $ \s (NonNegative newlines) (NonNegative i) -> do
    let t = Text.pack $ replicate newlines '\n' ++ takeWhile (/= '\n') s
    Rope.clamp16 (newlines + i) t == Rope.rowColumnCodeUnits (Rope.RowColumn newlines i) (Rope.fromText t)

  , testProperty "span matches Text" $ \s p -> do
    let t = Text.pack s
        f = QC.applyFun p
        (r1, r2) = Rope.span f $ Rope.fromText t
    (Rope.toText r1, Rope.toText r2) == Text.span f t

  , testProperty "break matches Text" $ \s p -> do
    let t = Text.pack s
        f = QC.applyFun p
        (r1, r2) = Rope.break f $ Rope.fromText t
    (Rope.toText r1, Rope.toText r2) == Text.break f t

  , testProperty "takeWhile matches Text" $ \s p -> do
    let t = Text.pack s
        f = QC.applyFun p
    Rope.toText (Rope.takeWhile f $ Rope.fromText t) == Text.takeWhile f t

  , testProperty "dropWhile matches Text" $ \s p -> do
    let t = Text.pack s
        f = QC.applyFun p
    Rope.toText (Rope.dropWhile f $ Rope.fromText t) == Text.dropWhile f t

  , testProperty "null matches Text" $ \s -> do
    let t = Text.pack s
    Rope.null (Rope.fromText t) == Text.null t

  , testProperty "rows is number of newlines" $ \s -> do
    let t = Text.pack s
        newlines = length $ filter (== '\n') s
    Rope.rows (Rope.fromText t) == newlines

  , testProperty "columns is number of code units of last line" $ \s -> do
    let t = Text.pack s
        lastLine = Text.takeWhileEnd (/= '\n') t
        cols = Unsafe.lengthWord16 lastLine
    Rope.columns (Rope.fromText t) == cols

  , testProperty "foldl matches Text" $ \s p a -> do
    let t = Text.pack s
        f = QC.applyFun2 p
    Rope.foldl f (a :: Int) (Rope.fromText t) == Text.foldl f a t

  , testProperty "foldl' matches Text" $ \s p a -> do
    let t = Text.pack s
        f = QC.applyFun2 p
    Rope.foldl' f (a :: Int) (Rope.fromText t) == Text.foldl' f a t

  , testProperty "foldr matches Text" $ \s p a -> do
    let t = Text.pack s
        f = QC.applyFun2 p
    Rope.foldr f (a :: Int) (Rope.fromText t) == Text.foldr f a t

  , testProperty "any matches Text" $ \s p -> do
    let t = Text.pack s
        f = QC.applyFun p
    Rope.any f (Rope.fromText t) == Text.any f t

  , testProperty "all matches Text" $ \s p -> do
    let t = Text.pack s
        f = QC.applyFun p
    Rope.all f (Rope.fromText t) == Text.all f t

  , testProperty "map matches Text" $ \s p -> do
    let t = Text.pack s
        f = QC.applyFun p
    Rope.toText (Rope.map f (Rope.fromText t)) == Text.map f t

  , testProperty "intercalate matches Text" $ \s ss -> do
    let t = Text.pack s
        ts = Text.pack <$> ss
    Rope.toText (Rope.intercalate (Rope.fromText t) (Rope.fromText <$> ts)) == Text.intercalate t ts
  ]

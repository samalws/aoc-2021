{-# LANGUAGE TupleSections #-}

import Criterion.Main
import qualified Data.Map as M
import Data.List.Utils

parseFileLine :: String -> ((Int,Int),(Int,Int))
parseFileLine s = ((read a,read b),(read c,read d)) where
  [x,y] = split " -> " s
  [a,b] = split "," x
  [c,d] = split "," y

parseFile :: String -> [((Int,Int),(Int,Int))]
parseFile s = parseFileLine <$> lines s

lineIsHorizontal :: ((Int,Int),(Int,Int)) -> Bool
lineIsHorizontal ((a,b),(c,d)) = b == d

lineIsVertical :: ((Int,Int),(Int,Int)) -> Bool
lineIsVertical ((a,b),(c,d)) = a == c

lineIsStraight :: ((Int,Int),(Int,Int)) -> Bool
lineIsStraight a = lineIsHorizontal a || lineIsVertical a

sortLine :: ((Int,Int),(Int,Int)) -> ((Int,Int),(Int,Int))
sortLine ((a,b),(c,d)) = ((min a c,min b d),(max a c,max b d))

lineToList :: ((Int,Int),(Int,Int)) -> [(Int,Int)]
lineToList l@((a,b),(c,d))
  | (a,b) == (c,d) = [(a,b)]
  | lineIsHorizontal l && a < c = (a,b):(lineToList ((a+1,b),(c,d)))
  | lineIsHorizontal l && a > c = (a,b):(lineToList ((a-1,b),(c,d)))
  | lineIsVertical l   && b < d = (a,b):(lineToList ((a,b+1),(c,d)))
  | lineIsVertical l   && b > d = (a,b):(lineToList ((a,b-1),(c,d)))
  | a < c && b < d = (a,b):(lineToList ((a+1,b+1),(c,d)))
  | a < c && b > d = (a,b):(lineToList ((a+1,b-1),(c,d)))
  | a > c && b < d = (a,b):(lineToList ((a-1,b+1),(c,d)))
  | a > c && b > d = (a,b):(lineToList ((a-1,b-1),(c,d)))

addMap :: M.Map (Int,Int) Int -> [(Int,Int)] -> M.Map (Int,Int) Int
addMap onto [] = onto
addMap onto (a:b) = addMap (M.insert a (1+(maybe 0 id $ M.lookup a onto)) onto) b

addLine :: ((Int,Int),(Int,Int)) -> M.Map (Int,Int) Int -> M.Map (Int,Int) Int
addLine l m = addMap m (lineToList l)

countOverOne :: M.Map (Int,Int) Int -> Int
countOverOne m = length $ filter ((> 1) . snd) $ M.toList m

runFile1 :: [((Int,Int),(Int,Int))] -> Int
runFile1 f = countOverOne $ foldr addLine M.empty $ filter lineIsStraight f

runFile2 :: [((Int,Int),(Int,Int))] -> Int
runFile2 f = countOverOne $ foldr addLine M.empty f

main = do
  f <- parseFile <$> readFile "inputs/D5.txt"
  print $ runFile1 f
  print $ runFile2 f
  defaultMain
    [ bgroup
        "D4"
        [ bench "P1" $ whnf runFile1 f,
          bench "P2" $ whnf runFile2 f
        ]
    ]

import Data.Sort
import Criterion.Main

data LineResult = Good | Incomplete String | Corrupted Char

starter :: Char -> Bool
starter = (`elem` "([{<")

ender :: Char -> Char -> Bool
ender '(' ')' = True
ender '[' ']' = True
ender '{' '}' = True
ender '<' '>' = True
ender _ _ = False

_runLine :: String -> String -> LineResult
_runLine [] [] = Good
_runLine r [] = Incomplete r
_runLine [] (h:r)
  | starter h = _runLine [h] r
_runLine (h1:r1) (h2:r2)
  | starter h2 = _runLine (h2:h1:r1) r2
  | ender h1 h2 = _runLine r1 r2
  | otherwise = Corrupted h2

runLine = _runLine ""

median :: [a] -> a
median [x] = x
median x = median $ tail $ init x

score1 :: LineResult -> Int
score1 (Corrupted ')') = 3
score1 (Corrupted ']') = 57
score1 (Corrupted '}') = 1197
score1 (Corrupted '>') = 25137
score1 _ = 0

score2 :: LineResult -> Int
score2 (Incomplete s) = foldl f 0 s where
  f n '(' = n*5 + 1
  f n '[' = n*5 + 2
  f n '{' = n*5 + 3
  f n '<' = n*5 + 4
score2 _ = 0

part1 :: [LineResult] -> Int
part1 = sum . fmap score1

part2 :: [LineResult] -> Int
part2 = median . sort . filter (/= 0) . fmap score2

main = do
  fc <- lines <$> readFile "inputs/D10.txt"
  let rl = runLine <$> fc
  print $ part1 rl
  print $ part2 rl

  defaultMain
    [ bgroup
        "D10"
        [ bench "runLines" $ whnf (fmap runLine) fc,
          bench "P1" $ whnf part1 rl,
          bench "P2" $ whnf part2 rl
        ]
    ]

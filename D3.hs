import Criterion.Main
import Data.List

parseLine :: String -> [Int]
parseLine = map (read . (:[]))

parseFile :: String -> [[Int]]
parseFile f = parseLine <$> lines f

sums :: [[Int]] -> [Int]
sums l = foldl' (zipWith (+)) (repeat 0) l

gammaL :: [[Int]] -> [Int]
gammaL l = (\n -> if n*2 >= len then 1 else 0) <$> sums l where len = length l

epsilonL :: [Int] -> [Int]
epsilonL = ((1 -) <$>)

binaryToDecimal' :: [Int] -> Int
binaryToDecimal' [] = 0
binaryToDecimal' (a:b) = a + 2*(binaryToDecimal' b)

binaryToDecimal :: [Int] -> Int
binaryToDecimal = binaryToDecimal' . reverse

gamma :: [Int] -> Int
gamma = binaryToDecimal

epsilon :: [Int] -> Int
epsilon = binaryToDecimal . epsilonL

runFile1 :: [[Int]] -> Int
runFile1 a = gamma l * epsilon l where l = gammaL a

oxy :: Int -> [[Int]] -> Int
oxy _ l | length l == 1 = binaryToDecimal $ head l
oxy b l = oxy (b+1) $ filter (\n -> n !! b == dig) l where dig = (gammaL l) !! b

co2 :: Int -> [[Int]] -> Int
co2 _ l | length l == 1 = binaryToDecimal $ head l
co2 b l = co2 (b+1) $ if newL == [] then l else newL where
  dig = (gammaL l) !! b
  newL = filter (\n -> n !! b /= dig) l

runFile2 :: [[Int]] -> Int
runFile2 l = oxy 0 l * co2 0 l

main = do
  f <- parseFile <$> readFile "inputs/D3.txt"
  print $ runFile1 f
  print $ runFile2 f
  defaultMain
    [ bgroup
        "D3"
        [ bench "P1" $ whnf runFile1 f,
          bench "P2" $ whnf runFile2 f
        ]
    ]

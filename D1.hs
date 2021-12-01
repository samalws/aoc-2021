groupsOfN :: [a] -> Int -> [[a]]
groupsOfN l n = groupsOfN' l n (length l) where
  groupsOfN' :: [a] -> Int -> Int -> [[a]]
  groupsOfN' l n lenLeft
    | lenLeft < n = []
    | otherwise = [take n l] <> groupsOfN' (drop 1 l) n (lenLeft - 1)

convolute :: (Num n) => [n] -> [n] -> [n]
convolute c l = (sum . zipWith (*) c) <$> (groupsOfN l (length c))

numIncreases :: (Ord n, Num n) => [n] -> Int
numIncreases = length . filter (> 0) . convolute [-1,1]

threes :: (Num n) => [n] -> [n]
threes = convolute [1,1,1]

threesIncreases :: (Ord n, Num n) => [n] -> Int
threesIncreases = length . filter (> 0) . convolute [-1,0,0,1]

nIncreases :: (Ord n, Num n) => Int -> [n] -> Int
nIncreases n = length . filter (> 0) . (convolute $ [-1] <> replicate (n-1) 0 <> [1])

main = do
  f1 <- readFile "inputs/D1P1.txt"
  print $ numIncreases $ read <$> lines f1
  print $ nIncreases 1 $ read <$> lines f1

  putStrLn ""

  f2 <- readFile "inputs/D1P2.txt"
  print $ numIncreases $ threes $ read <$> lines f2
  print $ threesIncreases $ read <$> lines f2
  print $ nIncreases 3 $ read <$> lines f2

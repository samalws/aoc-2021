import Data.Maybe

data Snail = Leaf Int | Pair Snail Snail deriving (Show, Read, Eq)

parseSnail :: String -> Snail
parseSnail s = read $ concat $ repl <$> s where
  repl ',' = " "
  repl '[' = "(Pair "
  repl ']' = ")"
  repl x | x `elem` ['0'..'9'] = "(Leaf " <> [x] <> ")"

parseSnailFile :: String -> [Snail]
parseSnailFile s = parseSnail <$> filter (/= "") (lines s)

indices :: Snail -> [[Bool]]
indices (Leaf _) = [[]]
indices (Pair a b) = ((False:) <$> indices a) <> ((True:) <$> indices b)

getIndex :: Snail -> [Bool] -> Int
getIndex (Leaf n) [] = n
getIndex (Pair a b) (False:r) = getIndex a r
getIndex (Pair a b) (True: r) = getIndex b r

updateIndex :: Snail -> [Bool] -> (Int -> Int) -> Snail
updateIndex (Leaf n) [] f = Leaf (f n)
updateIndex (Pair a b) (False:r) f = Pair (updateIndex a r f) b
updateIndex (Pair a b) (True: r) f = Pair a (updateIndex b r f)

zeroIndexPair :: [Bool] -> Snail -> Snail
zeroIndexPair [False]   (Pair a b) = Leaf 0
zeroIndexPair (False:r) (Pair a b) = Pair (zeroIndexPair r a) b
zeroIndexPair (True:r)  (Pair a b) = Pair a (zeroIndexPair r b)

firstGoodIndex :: [(a,[Bool])] -> Maybe a
firstGoodIndex ((x,a):(_,b):c) | length a > 4 && last a == False && last b == True && init a == init b = Just x
firstGoodIndex (_:c) = firstGoodIndex c
firstGoodIndex [] = Nothing

explodeSnail :: Snail -> Maybe Snail
explodeSnail s = if (isNothing fgi) then Nothing else Just result where
  inds = indices s
  ni = length inds
  taggedInds = [0..] `zip` inds
  fgi = firstGoodIndex taggedInds
  firstInd = fromJust fgi
  tryIndex :: Int -> Int -> Snail -> Snail
  tryIndex i add ss
    | i < 0 || i >= ni = ss
    | otherwise = updateIndex ss (inds !! i) (+ add)
  result = zeroIndexPair (inds !! firstInd) $ tryIndex (firstInd-1) (getIndex s (inds!!firstInd)) $ tryIndex (firstInd+2) (getIndex s (inds!!(firstInd+1))) s

splitSnail :: Snail -> Maybe Snail
splitSnail (Leaf n)
  | n >= 10 = Just $ Pair (Leaf (n `div` 2)) (Leaf ((n+1) `div` 2))
  | otherwise = Nothing
splitSnail (Pair a b) = maybe (Pair a <$> splitSnail b) (Just . flip Pair b) (splitSnail a)

reduceSnail :: Snail -> Maybe Snail
reduceSnail s = maybe (splitSnail s) Just (explodeSnail s)

reduceSnailBigly :: Snail -> Snail
reduceSnailBigly s = case (reduceSnail s) of
  Just ss -> reduceSnailBigly ss
  Nothing -> s

addSnails :: Snail -> Snail -> Snail
addSnails a b = reduceSnailBigly $ Pair a b

addSnailsList' :: Snail -> [Snail] -> Snail
addSnailsList' s [] = s
addSnailsList' s (a:b) = addSnailsList' (s `addSnails` a) b

addSnailsList (a:b) = addSnailsList' a b

magnitude :: Snail -> Int
magnitude (Leaf n) = n
magnitude (Pair a b) = 3*(magnitude a) + 2*(magnitude b)

powerset :: (Eq a) => [a] -> [(a,a)]
powerset l = [(x,y) | x <- l, y <- l, x /= y]

part1 = magnitude . addSnailsList

part2 s = maximum $ magnitude . uncurry addSnails <$> powerset s

main = do
  f <- parseSnailFile <$> readFile "inputs/D18.txt"
  print $ part1 f
  print $ part2 f

import Data.Maybe
import Data.List
import Data.List.Split
import qualified Data.Set as S

-- type Reflection = (Int, Bool)
type Reflection = Int -> Int

applyReflection :: Int -> Reflection -> Int
-- applyReflection x (n, p) = n + (if p then x else -x) -- extremely sad........
applyReflection x f = f x

applyReflections :: (Int, Int) -> (Reflection, Reflection) -> (Int, Int)
applyReflections (x, y) (rx, ry) = (applyReflection x rx, applyReflection y ry)

blankReflection :: Reflection
-- blankReflection = (0, True)
blankReflection = id

blankReflections :: (Reflection, Reflection)
blankReflections = (blankReflection, blankReflection)

addReflection :: Int -> Reflection -> Reflection
-- addReflection m (n, b) = (2*m - n, not b)
addReflection m r x = if xx > m then 2*m - xx else xx where xx = applyReflection x r

addReflectionX :: Int -> (Reflection, Reflection) -> (Reflection, Reflection)
addReflectionX n (x, y) = (addReflection n x, y)

addReflectionY :: Int -> (Reflection, Reflection) -> (Reflection, Reflection)
addReflectionY n (x, y) = (x, addReflection n y)

parseReflections :: String -> (Reflection, Reflection) -> (Reflection, Reflection)
parseReflections s r = helper (drop (length "fold along ") s) r where
  helper ('x':_:n) r = addReflectionX (read n) r
  helper ('y':_:n) r = addReflectionY (read n) r

parseReflectionss1 :: String -> (Reflection, Reflection)
parseReflectionss1 = flip parseReflections blankReflections . head . lines

parseReflectionss :: String -> (Reflection, Reflection)
parseReflectionss = foldl (flip parseReflections) blankReflections . lines

parsePoint :: String -> (Int, Int)
parsePoint s = (read a, read b) where [a,b] = splitOn "," s

parsePoints :: String -> [(Int, Int)]
parsePoints s = parsePoint <$> lines s

parseFile :: String -> ([(Int, Int)], (Reflection, Reflection))
parseFile f = (parsePoints a, parseReflectionss b) where [a,b] = splitOn "\n\n" f

parseFile1 :: String -> ([(Int, Int)], (Reflection, Reflection))
parseFile1 f = (parsePoints a, parseReflectionss1 b) where [a,b] = splitOn "\n\n" f

fileToSet :: [(Int, Int)] -> (Reflection, Reflection) -> S.Set (Int, Int)
fileToSet pts refls = S.fromList $ flip applyReflections refls <$> pts

printSet :: S.Set (Int, Int) -> String
printSet s = unlines $ nthRow <$> [0..maxRow] where
  asList = S.toList s
  maxCol = maximum $ fst <$> asList
  maxRow = maximum $ snd <$> asList
  nthRow y = (\x -> if S.member (x,y) s then '#' else ' ') <$> [0..maxCol]

part1 :: [(Int, Int)] -> (Reflection, Reflection) -> Int
part1 pts refls = length $ fileToSet pts refls

part2 :: [(Int, Int)] -> (Reflection, Reflection) -> String
part2 pts refls = printSet $ fileToSet pts refls

main = do
  f <- readFile "inputs/D13.txt"
  let f1 = parseFile1 f
  let f2 = parseFile  f
  print $ uncurry part1 f1
  putStrLn $ uncurry part2 f2

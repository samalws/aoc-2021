import qualified Data.Set as S
import qualified Data.Map as M
import Data.List.Split
import Data.List.Index
import Data.Semigroup
import Data.Foldable

type Coord = (Int, Int)
type Board = (Bool, ((Int,Int),(Int,Int)), S.Set Coord)
type Rule = M.Map [Bool] Bool

getCoordVal :: Board -> Coord -> Bool
getCoordVal bb@(bg,_,b) c
  | inBackground bb c = bg
  | otherwise = S.member c b

inBackground :: Board -> Coord -> Bool
inBackground (_,((x0,y0),(x1,y1)),_) (x,y) = x < x0 || x > x1 || y < y0 || y > y1

maxExtents :: S.Set Coord -> (Coord, Coord)
maxExtents b = ((f getMin Min fst, f getMin Min snd), (f getMax Max fst, f getMax Max snd)) where
  f gm m fs = gm $ fold $ (m . fs) `S.map` b

maxExtentsList :: Board -> [[Coord]]
maxExtentsList (_,((x0,y0),(x1,y1)),_) = [[x0-1..x1+1] `zip` repeat y | y <- [y0-1..y1+1]]

neighbors :: Coord -> [Coord]
neighbors (x,y) = [(xi,yi) | yi <- [y-1..y+1], xi <- [x-1..x+1]]

updateBoard :: Rule -> Board -> Board
updateBoard r b@(bg,_,_) = (r M.! replicate 9 bg, maxExtents newSet, newSet) where
  newSet = S.fromList $ filter f $ concat $ maxExtentsList b
  f c = r M.! (getCoordVal b <$> neighbors c)

updateBoardN :: Int -> Rule -> Board -> Board
updateBoardN 0 _ = id
updateBoardN n r = updateBoard r . updateBoardN (n-1) r

binaryCount :: Int -> [[Bool]]
binaryCount 0 = [[]]
binaryCount n = [a:b | a <- [False, True], b <- binaryCount (n-1)]

charToBool :: Char -> Bool
charToBool '.' = False
charToBool '#' = True

boolToChar :: Bool -> Char
boolToChar False = '.'
boolToChar True = '#'

parseRule :: String -> Rule
parseRule s = M.fromList $ binaryCount 9 `zip` (charToBool <$> s)

indexed2D :: [[a]] -> [[((Int,Int),a)]]
indexed2D l = f <$> indexed l where
  f (y, r) = g y <$> indexed r
  g y (x, a) = ((x,y),a)

parseBoard :: String -> Board
parseBoard s = (False, maxExtents set, set) where set = S.fromList . fmap fst . filter (charToBool . snd) . concat . indexed2D . filter (/= "") . lines $ s

parseFile :: String -> (Rule, Board)
parseFile s = (parseRule r,parseBoard b) where [r,b] = splitOn "\n\n" s

printBoard :: Board -> String
printBoard b = unlines $ fmap (fmap (boolToChar . getCoordVal b)) $ maxExtentsList b

printBoardFull :: Board -> String
printBoardFull b@(bg,ex,_) = printBoard b <> "\nExtents: " <> show ex <> "\nBackground: " <> show bg

boardNumLit :: Board -> Int
boardNumLit (_,_,b) = S.size b

main = do
  (r,b) <- parseFile <$> readFile "inputs/D20.txt"
  print $ boardNumLit $ updateBoardN 2 r $ b
  print $ boardNumLit $ updateBoardN 50 r $ b

{-# LANGUAGE TupleSections #-}

import Criterion.Main
import Control.Monad.State
import Data.Array
import Data.Tuple.Lazy
import Data.List
import Data.List.Index

type Board = Array (Int, Int) Int
type BoardMarking = Array (Int, Int) Bool

-- bool: whether delim is in the next position
splitList' :: (Eq a) => a -> [a] -> (Bool, [[a]])
splitList' _ [] = (False, [])
splitList' x (y:z)
  | x == y = (True, listNext)
  | delimNext = (False, [y]:listNext)
  | null listNext = (False, [[y]])
  | otherwise = (False, (y:(head listNext)):(tail listNext))
  where
    (delimNext, listNext) = splitList' x z

splitList :: (Eq a) => a -> [a] -> [[a]]
splitList a b = snd $ splitList' a b

boardFrom2DArr :: [[Int]] -> Board
boardFrom2DArr l = listArray ((0,0), ((length l)-1, (length $ head l)-1)) (concat l)

parseNums :: String -> [Int]
parseNums s = read $ "[" <> s <> "]"

parseBoard :: [String] -> Board
parseBoard l = boardFrom2DArr $ (fmap read . words) <$> l

parseBoards :: [String] -> [Board]
parseBoards l = parseBoard <$> splitList "" l

parseFile :: String -> ([Board], [Int])
parseFile s = (parseBoards $ drop 2 l, parseNums $ head l) where l = lines s

markBoard :: Int -> BoardMarking -> Board -> BoardMarking
markBoard num marking board = marking // ((,True) <$> matchingIndices) where
  matchingIndices = fst <$> filter ((num ==) . snd) (assocs board)

bingoGameMarkPhase :: State ([(BoardMarking, Board)], [Int]) ()
bingoGameMarkPhase = do
  firstNum <- gets $ head . snd
  boards <- gets fst
  let newBoards = uncurry (markBoard firstNum) <$> boards
  modify $ mapFst $ const $ zip newBoards (snd <$> boards)

bingoGameCheckPhase :: Bool -> State ([(BoardMarking, Board)], [Int]) ((BoardMarking, Board), [Int])
bingoGameCheckPhase b = do
  boardMarkings <- gets $ (fst <$>) . fst
  let winningBoardNum = getWinningBoard b boardMarkings
  maybe (bingoGameRepeatPhase b) (bingoGameReturnPhase b) winningBoardNum

bingoGameRepeatPhase :: Bool -> State ([(BoardMarking, Board)], [Int]) ((BoardMarking, Board), [Int])
bingoGameRepeatPhase b = do
  modify $ mapSnd tail
  bingoGame b

bingoGameReturnPhase :: Bool -> Int -> State ([(BoardMarking, Board)], [Int]) ((BoardMarking, Board), [Int])
bingoGameReturnPhase False boardNum = do
  (marking, board) <- gets $ (!! boardNum) . fst
  numList <- gets snd
  pure ((marking, board), numList)
bingoGameReturnPhase True boardNum = do
  (marking, board) <- gets $ (!! boardNum) . fst
  modify $ mapFst $ const [(marking, board)]
  bingoGameRepeatPhase False

getWinningBoard :: Bool -> [BoardMarking] -> Maybe Int
getWinningBoard False markings = findIndex boardIsWinning markings
getWinningBoard True markings = if (length losings == 1) then Just (head losings) else Nothing where
  losings = fst <$> filter (not . boardIsWinning . snd) (indexed markings)

boardIsWinning :: BoardMarking -> Bool
boardIsWinning marking = or $ fmap and $ fmap getElems $ rowElems <> colElems where
  rowElems = [rowElemsR r | r <- [0..numRows-1]]
  colElems = [colElemsC c | c <- [0..numCols-1]]
  rowElemsR r = [(r,c) | c <- [0..numCols-1]]
  colElemsC c = [(r,c) | r <- [0..numRows-1]]
  (numRows, numCols) = snd $ bounds marking
  getElems e = (marking !) <$> e

bingoGame :: Bool -> State ([(BoardMarking, Board)], [Int]) ((BoardMarking, Board), [Int])
bingoGame b = do
  bingoGameMarkPhase
  bingoGameCheckPhase b

sumUnmarked :: BoardMarking -> Board -> Int
sumUnmarked marking board = sum $ fmap snd $ filter (not . fst) $ elems marking `zip` elems board

runFile :: Bool -> ([Board], [Int]) -> Int
runFile b (boards, nums) = processResult $ fst $ runState (bingoGame b) (zip initialMarkings boards, nums) where
  processResult ((winningMarking, winningBoard), newNums) = head newNums * sumUnmarked winningMarking winningBoard
  initialMarkings = (const False <$>) <$> boards

runFile1 :: ([Board], [Int]) -> Int
runFile1 = runFile False

runFile2 :: ([Board], [Int]) -> Int
runFile2 = runFile True

main = do
  f <- parseFile <$> readFile "inputs/D4.txt"
  print $ runFile1 f
  print $ runFile2 f
  defaultMain
    [ bgroup
        "D4"
        [ bench "P1" $ whnf runFile1 f,
          bench "P2" $ whnf runFile2 f
        ]
    ]

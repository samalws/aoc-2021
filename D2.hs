import Control.Monad.State
import Data.Tuple.Lazy

parseCmd1 :: String -> Int -> State (Int, Int) ()
parseCmd1 "forward" n = modify $ mapFst (+ n)
parseCmd1 "up" n = modify $ mapSnd (subtract n)
parseCmd1 "down" n = modify $ mapSnd (+ n)

parseLine1 :: String -> State (Int, Int) ()
parseLine1 s = parseCmd1 a (read b) where [a,b] = words s

parseFile1 :: String -> State (Int, Int) ()
parseFile1 s = (sequence $ parseLine1 <$> lines s) >> pure ()

runFile1 :: String -> (Int, Int)
runFile1 = snd . flip runState (0, 0) . parseFile1

parseCmd2 :: String -> Int -> State (Int, (Int, Int)) ()
parseCmd2 "forward" n = modify (\(a,(x,y)) -> (a,(x+n,y+a*n)))
parseCmd2 "up" n = modify $ mapFst (subtract n)
parseCmd2 "down" n = modify $ mapFst (+ n)

parseLine2 :: String -> State (Int, (Int, Int)) ()
parseLine2 s = parseCmd2 a (read b) where [a,b] = words s

parseFile2 :: String -> State (Int, (Int, Int)) ()
parseFile2 s = (sequence $ parseLine2 <$> lines s) >> pure ()

runFile2 :: String -> (Int, Int)
runFile2 = snd . snd . flip runState (0,(0, 0)) . parseFile2

main = do
  f1 <- readFile "inputs/D2P1.txt"
  print $ uncurry (*) $ runFile1 f1
  print $ uncurry (*) $ runFile2 f1

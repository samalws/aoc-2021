import qualified Data.Set as S
import qualified Data.Map as M
import Data.List
import Data.Maybe
import Data.Char
import Criterion.Main

type Crabs = [(String, String)]
type Octopus = M.Map String [String]

isBig :: String -> Bool
isBig (a:_) = toUpper a == a

explore :: Octopus -> S.Set String -> Bool -> String -> Int
explore _ _ _ "end" = 1
explore octopus visited usedTwice startPoint = if (not canGo) then 0 else sum subExplores where
  needToUseTwice = S.member startPoint visited
  canGo = (not needToUseTwice) || (not usedTwice && startPoint /= "start")
  usingTwice = usedTwice || needToUseTwice
  thisAdded = if isBig startPoint then visited else S.insert startPoint visited
  subExplores = explore octopus thisAdded usingTwice <$> octopus M.! startPoint

explore1Start :: Octopus -> Int
explore1Start octopus = explore octopus S.empty True "start"

explore2Start :: Octopus -> Int
explore2Start octopus = explore octopus S.empty False "start"

parseCrab :: String -> (String, String)
parseCrab s = tail <$> splitAt (fromJust $ findIndex (== '-') s) s

parseCrabs :: String -> Crabs
parseCrabs s = parseCrab <$> lines s

parseOctopus :: String -> Octopus
parseOctopus = crabsToOctopus . parseCrabs

crabsToOctopus :: Crabs -> Octopus
crabsToOctopus crabs = M.fromList $ caveMapEntry <$> S.toList allCaves where
  allCaves = foldr S.union S.empty $ (\(a,b) -> S.fromList [a,b]) <$> crabs
  caveMapEntry cave = (cave, S.toList $ connectionsForCave cave)
  connectionsForCave cave = foldr S.union S.empty $ checkCaveConn cave <$> crabs
  checkCaveConn cave (a,b)
    | cave == a = S.singleton b
    | cave == b = S.singleton a
    | otherwise = S.empty

part1 = explore1Start
part2 = explore2Start

main = do
  f <- parseOctopus <$> readFile "inputs/D12B1.txt"
  print $ part1 f
  print $ part2 f
  {-
  defaultMain
    [ bgroup
        "D12"
        [ bench "P1" $ whnf part1 f,
          bench "P2" $ whnf part2 f
        ]
    ]
  -}

type Parser a = [Int] -> ([Int], a)
data Packet = LiteralPacket { versionNum :: Int, packetId :: Int, literalContents :: [Int] } | OperatorPacket { versionNum :: Int, packetId :: Int, operatorContents :: [Packet] } deriving Show

hexToNum :: Char -> Int
hexToNum d
  | elem d "ABCDEF" = fromEnum d - fromEnum 'A' + 10
  | elem d "abcdef" = fromEnum d - fromEnum 'a' + 10
  | elem d "1234567890" = fromEnum d - fromEnum '0'

hexToBin :: Int -> [Int]
hexToBin n = d <$> [3,2,1,0] where
  d x = (n `div` (2 ^ x)) `mod` 2

parseHexs :: String -> [Int]
parseHexs = fmap hexToNum

binToInt :: [Int] -> Int
binToInt = helper . reverse where
  helper [] = 0
  helper (a:b) = a + 2*(helper b)

hexToInt :: [Int] -> Int
hexToInt = helper . reverse where
  helper [] = 0
  helper (a:b) = a + 16*(helper b)

parseBins :: String -> [Int]
parseBins = concat . fmap hexToBin . parseHexs

parseNBit :: Int -> Parser Int
parseNBit n s = (drop n s, binToInt (take n s))

parseBool :: Parser Bool
parseBool = fmap (== 1) . parseNBit 1 where

parseVerNum = parseNBit 3
parseID = parseNBit 3

parseLiteralEntry :: Parser (Bool, Int)
parseLiteralEntry s = (r,(b,i)) where
  (r0, b) = parseBool s
  (r,  i) = parseNBit 4 r0

-- answer in hex
parseLiteralBody :: Parser [Int]
parseLiteralBody = f . parseLiteralEntry where
  f (r, (False, i)) = (r, [i])
  f (r, (True,  i)) = g i (parseLiteralBody r)
  g i (r, s) = (r, i:s)

parseLengthID = parseBool
parseLength0 = parseNBit 15
parseLength1 = parseNBit 11

parseLength :: Parser (Bool, Int)
parseLength s = (r, (b, i)) where
  (r0, b) = parseLengthID s
  (r,  i) = (if b then parseLength1 else parseLength0) r0

parseLength0Packets :: Int -> Parser [Packet]
parseLength0Packets n s = f (take n s) where
  f ss = g (parsePacket ss)
  g ([], p) = (drop n s, [p])
  g (r,  p) = (p:) <$> f r

parseLength1Packets :: Int -> Parser [Packet]
parseLength1Packets 0 s = (s, [])
parseLength1Packets n s = (r, p:ps) where
  (r0, p) = parsePacket s
  (r, ps) = parseLength1Packets (n-1) r0

parseOperatorBody :: Parser [Packet]
parseOperatorBody s = result where
  (r, (b, l)) = parseLength s
  result0 = parseLength0Packets l r
  result1 = parseLength1Packets l r
  result = if b then result1 else result0

parsePacket :: Parser Packet
parsePacket s = result where
  (r0,  v) = parseVerNum s
  (r1,  i) = parseID r0
  resultL = LiteralPacket  v i <$> parseLiteralBody r1
  resultO = OperatorPacket v i <$> parseOperatorBody r1
  result = if i == 4 then resultL else resultO

versionNumSum :: Packet -> Int
versionNumSum p@(LiteralPacket _ _ _) = versionNum p
versionNumSum p@(OperatorPacket _ _ _) = versionNum p + sum (versionNumSum <$> operatorContents p)

operatorFn :: Int -> [Int] -> Int
operatorFn 0 l = sum l
operatorFn 1 l = product l
operatorFn 2 l = minimum l
operatorFn 3 l = maximum l
operatorFn 5 l = fromEnum $ (l !! 0) > (l !! 1)
operatorFn 6 l = fromEnum $ (l !! 0) < (l !! 1)
operatorFn 7 l = fromEnum $ (l !! 0) == (l !! 1)

evalPacket :: Packet -> Int
evalPacket p@(LiteralPacket _ _ _) = hexToInt $ literalContents p
evalPacket p@(OperatorPacket _ _ _) = operatorFn (packetId p) $ evalPacket <$> operatorContents p

main = do
  f <- init <$> readFile "inputs/D16.txt"
  let (r, pkt) = parsePacket $ parseBins f
  print $ versionNumSum pkt
  print $ evalPacket pkt

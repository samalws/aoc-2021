def makeEnumFromPair(s):
  d = {}
  d[s[0]] = 1
  d[s[1]] = 2 if s[0] == s[1] else 1
  return d

def mergeEnumDicts(a, b, sub):
  d = {}
  for k,v in a.items():
    if k not in d: d[k] = 0
    d[k] += v
  for k,v in b.items():
    if k not in d: d[k] = 0
    d[k] += v
  d[sub] -= 1
  return d

toEnum = [a + b for a in "QWERTYUIOPASDFGHJKLZXCVBNM" for b in "QWERTYUIOPASDFGHJKLZXCVBNM"]

def makeFirstEnumDict():
  enumDict = {}
  for pair in toEnum:
    enumDict[pair] = makeEnumFromPair(pair)
  return enumDict

def makeNextEnumDict(lastDict, rs):
  enumDict = {}
  for pair in toEnum:
    if not pair in rs: continue
    pair1 = pair[0] + rs[pair]
    pair2 = rs[pair] + pair[1]
    enumDict[pair] = mergeEnumDicts(lastDict[pair1], lastDict[pair2], rs[pair])
  return enumDict

def makeEnumDict(n, rs):
  dict = makeFirstEnumDict()
  for i in range(n):
    if i % 1000 == 0:
      print(i)
    dict = makeNextEnumDict(dict, rs)
  return dict

def makeEnumDictLong(n, rs, s):
  enumDict = makeEnumDict(n, rs)
  finalDict = enumDict[s[0:2]]
  for i in range(1,len(s)-1):
    finalDict = mergeEnumDicts(finalDict, enumDict[s[i:i+2]], s[i])
  return finalDict

f = open("inputs/D14.txt","r").read().split("\n")
s = f[0]
rs = {}
for l in f[2:]:
  if l == "": continue
  spl = l.split(" -> ")
  rs[spl[0]] = spl[1]
freqs1 = makeEnumDictLong(10, rs, s)
print(max(freqs1.values()) - min(freqs1.values()))
freqs2 = makeEnumDictLong(40, rs, s)
print(max(freqs2.values()) - min(freqs2.values()))
freqs3 = makeEnumDictLong(100000, rs, s)
print(max(freqs2.values()) - min(freqs3.values()))

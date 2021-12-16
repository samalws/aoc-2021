def minDict(d,e):
  m = 1000000
  mi = None
  for k,_ in d.items():
    v = e[k[0]][k[1]]
    if v < m:
      mi = k
      m = v
  return mi

def neighbors(x,y,n):
  l = []
  if x > 0:   l += [(x-1,y)]
  if y > 0:   l += [(x,y-1)]
  if x < n-1: l += [(x+1,y)]
  if y < n-1: l += [(x,y+1)]
  return l

def dijkstra(arr):
  cloneArr = list(map(lambda r: list(map(lambda x: 0, r)), arr))
  n = len(arr)
  done = {}
  touched = {}
  touched[(0,0)] = True

  while len(touched) > 0:
    (x,y) = minDict(touched,cloneArr)
    for (x2,y2) in neighbors(x,y,n):
      if (x2,y2) not in done and ((x2,y2) not in touched or cloneArr[x2][y2] > cloneArr[x][y] + arr[x2][y2]):
        cloneArr[x2][y2] = cloneArr[x][y] + arr[x2][y2]
        touched[(x2,y2)] = True
    touched.pop((x,y))
    done[(x,y)] = True

  return cloneArr[n-1][n-1]


def naive(arr):
  arr[0][0] = 0
  n = len(arr)
  for x in range(n):
    for y in range(n):
      if x == 0 and y == 0: continue
      options = []
      if x > 0:
        options += [arr[x-1][y]]
      if y > 0:
        options += [arr[x][y-1]]
      arr[x][y] += min(options)
  return arr[n-1][n-1]

def parse(t):
  r = []
  for l in t.split("\n"):
    if l == "": continue
    x = len(r)
    r += [[]]
    for c in l:
      r[x] += [int(c)]
  return r

def cloneList(l):
  ll = []
  for x in l:
    ll += [x]
  return ll

def mod(r):
  n = len(r)
  rr = list(map(cloneList, list(map(lambda row: row*5, r))*5))
  for x in range(n*5):
    for y in range(n*5):
      tmp = rr[x][y]
      tmp += (x // n) + (y // n)
      if tmp > 9: tmp -= 9
      if tmp > 9: tmp -= 9
      rr[x][y] = tmp
  return rr

f = open("inputs/D15.txt","r").read()
p = parse(f)
print(dijkstra(p))
f = open("inputs/D15.txt","r").read()
p = parse(f)
pp = mod(p)
print(dijkstra(pp))

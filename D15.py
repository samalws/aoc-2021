def needful(arr):
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
print(needful(p))
f = open("inputs/D15.txt","r").read()
p = parse(f)
pp = mod(p)
print(needful(pp))

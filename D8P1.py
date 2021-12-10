f = open("inputs/D8.txt")
t = f.read()
t = t.split("\n")[:-1]
t = list(map(lambda s: s.split(" | "), t))
t = map(lambda l: l[1], t)
t = map(lambda s: s.split(" "), t)
x = 0
for q in t:
  for p in q:
    if len(p) in [2,3,4,7]:
      x += 1
print(x)

f = open("inputs/D8.txt")
t = f.read()
tt = t.split("\n")[:-1]
ttt = list(map(lambda s: s.split(" | "), tt))
tttt = map(lambda l: l[1], ttt)
ttttt = map(lambda s: s.split(" "), tttt)
x = 0
for i in range(len(ttttt)):
  q = ttttt[i]
  for j in range(len(q)):
    if len(q[j]) in [2,3,4,7]:
      x += 1
print(x)

l = eval("["+open("inputs/D6.txt", "r").read()+"]")
ll = [0,0,0,0,0,0,0,0,0]
for x in l:
  ll[x] += 1
for i in range(80):
  x = ll[0]
  ll = ll[1:] + [x]
  ll[-3] += x
print(sum(ll))

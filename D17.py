# durgasoft

square = [29,73,-248,-194]
def sign(x):
  if x > 0: return 1
  if x < 0: return -1
  return 0
def sim(vx,vy,x=0,y=0):
  while True:
    if y < square[2]: return False
    if x > square[1]: return False
    if x >= square[0] and x <= square[1] and y >= square[2] and y <= square[3]: return True
    x += vx
    y += vy
    vx -= sign(vx)
    vy -= 1

t = 0
for vx in range(1000):
  for vy in range(square[2]-10,-square[2]+10):
    if sim(vx,vy):
      t += 1
print(t)

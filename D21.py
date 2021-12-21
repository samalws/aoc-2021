def rollDie(die):
  die += 1
  return (die, die % 100)

def threeRollDie(die):
  v = 0
  for i in range(3):
    (roll, die) = rollDie(die)
    v += roll
  return (v, die)

def doPlayer(p,s,die):
  (roll, die) = threeRollDie(die)
  p = ((p + roll - 1) % 10) + 1
  s += p
  return (p,s,die)

def simGame(p1,p2):
  s1 = 0
  s2 = 0
  die = 0
  dieTot = 0
  while True:
    (p1,s1,die) = doPlayer(p1,s1,die)
    dieTot += 3
    if s1 >= 1000: return s2*dieTot
    (p2,s2,die) = doPlayer(p2,s2,die)
    dieTot += 3
    if s2 >= 1000: return s1*dieTot

def simGame2(p1,s1,p2,s2,d):
  if s1 >= 21:
    return (1,0)
  elif s2 >= 21:
    return (0,1)

  if (p1,s1,p2,s2) in d:
    return d[(p1,s1,p2,s2)]

  (w1, w2) = (0,0)
  for (roll, amt) in [(3,1),(4,3),(5,6),(6,7),(7,6),(8,3),(9,1)]:
    newPos = ((p1+roll-1)%10)+1
    (b,a) = simGame2(p2,s2,newPos,s1+newPos,d)
    w1 += a*amt
    w2 += b*amt

  d[(p1,s1,p2,s2)] = (w1,w2)
  return (w1,w2)

print(simGame(6,7))
print(simGame2(6,0,7,0,{}))

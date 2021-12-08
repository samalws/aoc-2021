#![allow(non_snake_case)]

use std::fs;

fn encodeDigit(d: u8) -> Vec<u8> {
  (match d {
    0 => vec![1,2,3,5,6,7],
    1 => vec![3,6],
    2 => vec![1,3,4,5,7],
    3 => vec![1,3,4,6,7],
    4 => vec![2,3,4,6],
    5 => vec![1,2,4,6,7],
    6 => vec![1,2,4,5,6,7],
    7 => vec![1,3,6],
    8 => vec![1,2,3,4,5,6,7],
    9 => vec![1,2,3,4,6,7],
    _ => panic!("wtf u doing"),
  }).iter().map(|n| n-1).collect()
}

fn digsForLength(d: u8) -> Vec<(u8, Vec<u8>)> {
  (0..=9).map(|n| (n, encodeDigit(n))).filter(|v| v.1.len() as u8 == d).collect()
}

fn checkDigitList(a: Vec<u8>, b: Vec<(u8, Vec<u8>)>) -> Option<u8> {
  for r in b {
    if a.iter().map(|n| r.1.contains(n)).fold(true, |a, b| a && b) {
      return Some(r.0);
    }
  }
  return None;
}

fn mapDigit(s: &String, v: &String) -> Option<u8> {
  let mut digitList: Vec<u8> = Vec::new();
  for c in v.chars() {
    match s.find(c) {
      Some(n) => { digitList.push(n as u8); },
      None => {},
    }
  }
  checkDigitList(digitList.clone(), digsForLength(v.len() as u8))
}

fn checkDigit(s: &String, v: &String) -> bool {
  mapDigit(s, v).is_some()
}

fn checkDigits(s: &String, v: &Vec<String>) -> bool {
  v.iter().map(|x| checkDigit(s, x)).fold(true, |a, b| a && b)
}

fn backtrack(s: &String, v: &Vec<String>) -> String {
  match s.find("_") {
    None => { return s.clone(); },
    Some(pos) => {
      for c in "abcdefg".to_string().chars() {
        if s.find(c).is_none() {
          let mut ss = s.clone();
          ss.replace_range(pos..pos+1,&c.to_string());
          if checkDigits(&ss, v) {
            let sss = backtrack(&ss, v);
            if sss != "_______" {
              return sss;
            }
          }
        }
      }
    }
  }
  return "_______".to_string();
}

fn convDigits(v: &Vec<u8>) -> u32 {
  v.iter().fold(0, |n,m| n*10 + *m as u32)
}

fn num1478(v: &Vec<u8>) -> u32 {
  v.iter().fold(0, |m, n| match n {
    1 | 4 | 7 | 8 => m + 1,
    _ => m,
  })
}

fn readFile() -> Vec<(Vec<String>, Vec<String>)> {
  fs::read_to_string("inputs/D8.txt").unwrap().split("\n").filter(|l| l.len() != 0)
    .map(|l| {
      let ll: Vec<Vec<String>> = l.split(" | ").map(|s| s.split(" ").map(|ss| ss.to_string()).collect()).collect();
      (ll[0].clone(), ll[1].clone())
    }).collect()
}

fn main() {
  let blank = "_______".to_string();
  let vals: (u32,u32) = readFile().iter().map(|line| {
    let s = backtrack(&blank, &line.0);
    let vv = line.1.iter().map(|v| mapDigit(&s, v).unwrap()).collect();
    (num1478(&vv),convDigits(&vv))
  }).fold((0,0), |(n1,n2), (m1,m2)| (n1+m1,n2+m2));
  println!("{}, {}",vals.0, vals.1);
}

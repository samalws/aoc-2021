#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>

#define max(a,b) (a > b) ? a : b
#define min(a,b) (a < b) ? a : b

typedef struct {
  int rowSize;
  int colSize;
  int rows;
  int cols;
  bool* marks;
} paper;

typedef struct {
  paper* p;
  int* xFolds;
  int* yFolds;
  int numXFolds;
  int numYFolds;
} fileContents;

bool* getIndex(paper* p, int x, int y) {
  return p->marks + x + (y*p->cols);
}

void foldPaperX(paper* p, int foldX) {
  for (int x = 0; x < foldX; x++) {
    int xFlip = foldX + (foldX - x);
    if (xFlip < 0) continue;
    for (int y = 0; y < p->cols; y++) {
      bool* i = getIndex(p,x,y);
      bool* j = getIndex(p,foldX,y);
      *i = *i || *j;
      *j = false;
    }
  }
  p->rows = foldX;
}

fileContents readFile() {
  FILE* f = fopen("inputs/D13.txt","r");
  char* text = malloc(10000);
  int result = fread(text, sizeof(char), 10000, f);

  fileContents retVal;

  retVal.p = malloc(sizeof(paper));
  retVal.p->marks = malloc(sizeof(bool)*10000*10000);
  retVal.p->rowSize = 10000;
  retVal.p->colSize = 10000;
  retVal.p->rows = 0;
  retVal.p->cols = 0;

  retVal.xFolds = malloc(sizeof(int)*100);
  retVal.yFolds = malloc(sizeof(int)*100);
  retVal.numXFolds = 0;
  retVal.numYFolds = 0;

  // char* fstPart = strtok(text, "\n\n");
  // char* sndPart = strtok(NULL, "\n\n");
  //   printf("%s\n", fstPart);
  char* fstPart = text;
  char* sndPart = text;

  for (char* token = strtok(fstPart, ","); token != NULL; token = strtok(NULL, ",")) {
    if (strlen(token) == 0) break;
    if (*token == '\n') break;
    printf("0 %s\n", token);
    int x = atoi(token);
    token = strtok(NULL, "\n");
    int y = atoi(token);
    *(getIndex(retVal.p, x, y)) = true;
    retVal.p->cols = max(retVal.p->cols, x+1);
    retVal.p->rows = max(retVal.p->rows, y+1);
  }

  int ignoreBefore = strlen("fold along x=");
  int letterIndex = strlen("fold along ");
  for (char* token = strtok(NULL, "\n"); token != NULL; token = strtok(NULL, "\n")) {
    printf("a %s\n", token);
    if (token[letterIndex] == 'x') {
      retVal.xFolds[retVal.numXFolds] = atoi(token + ignoreBefore);
      retVal.numXFolds++;
    } else {
      retVal.yFolds[retVal.numYFolds] = atoi(token + ignoreBefore);
      retVal.numYFolds++;
    }
  }

  return retVal;
}

int numOnes(paper* p) {
  int tot = 0;
  for (int x = 0; x < p->cols; x++)
    for (int y = 0; y < p->rows; y++)
      if (*getIndex(p,x,y))
        tot++;
  return tot;
}

int main() {
  fileContents f = readFile();
  printf("b %d\n", numOnes(f.p));
  foldPaperX(f.p, f.xFolds[0]);
  printf("b %d\n", numOnes(f.p));
}

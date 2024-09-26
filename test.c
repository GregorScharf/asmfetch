#include <fcntl.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/sysinfo.h>
#include <sys/utsname.h>
#include <syscall.h>
#include <unistd.h>

unsigned long my_strlen(const char *str) {
  unsigned long n = 0;
  while (str[n] != 0) {
    n++;
  }
  return n;
}

unsigned long my_pow(unsigned long base, unsigned long expo) {
  unsigned long ori = base;
  for (int i = 0; i < expo; i++) {
    base = ori * base;
  }
  return base / 10;
}

unsigned long strToInt(const char *str) {
  long len = my_strlen(str);
  unsigned long num = 0;
  long expo = 0;
  for (long i = 0; i < len; i++) {
    if (str[i] < 48 || str[i] > 57) {
      printf("you're dumb \"%c\" is not a number", str[i]);
      return -1;
    }
  }

  for (long i = len - 1; i >= 0; i--) {

    num += (str[i] - 48) * my_pow(10, expo);
    expo++;
  }

  return num;
}

int main() {

  printf("%lu \n", strToInt("12334"));
  return 0;
}

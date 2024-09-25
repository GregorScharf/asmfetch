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

unsigned long strToInt(const char *str) {
  long len = my_strlen(str);
  unsigned long num = 0;
  long iter = 0;
  for (long i = 0; i < len; i++) {
    if (str[i] < 48 || str[i] > 57) {
      printf("you're dumb \"%c\" is not a number", str[i]);
      return -1;
    }
  }

  for (long i = len - 1; i >= 0; i--) {

    num += (str[i] - 48) * pow(10, iter);
    iter++;
  }

  return num;
}

int main() {

  printf("%lu \n", strToInt("12334"));
  return 0;
}

#include <fcntl.h>
#include <linux/sysinfo.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <sys/sysinfo.h>
#include <sys/utsname.h>
#include <syscall.h>
#include <unistd.h>

#define BUFFER_SIZE 19
char *intToStr(unsigned long x) {
  char *str = (char *)malloc(BUFFER_SIZE);
  memset(str, ' ', BUFFER_SIZE);
  int i = BUFFER_SIZE - 1;

  do {
    str[i] = (x % 10) + 48;
    i--;
    x /= 10;
  } while (x != 0);
  return str;
};

unsigned long strToInt(const char *str) {
  long len = strlen(str);
  long num = 0;
  for (int i = 0; i < len; i++) {
    if (str[i] < 48 || str[i] > 57) {
      printf("you're dumb \"%c\" is not a number", str[i]);
      return -1;
    }
  }

  int iter = 0;
  for (int i = len - 1; i >= 0; i--) {

    num += (str[i] - 48) * pow(10, iter);
    iter++;
  }

  return num;
}

int main() {

  printf("%lu \n", sizeof(struct sysinfo));
  return 0;
}

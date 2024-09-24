#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
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

int main() {
  char *p = intToStr(12);
  return 0;
}

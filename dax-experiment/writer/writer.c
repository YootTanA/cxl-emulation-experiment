#include <fcntl.h>
#include <stdio.h>
#include <string.h>
#include <sys/mman.h>
#include <unistd.h>

int main() {
  /* DAX mapping requires a 2MiB alignment */
  size_t page_size = 2 * 1024 * 1024;

  int fd = open("/dev/dax0.0", O_RDWR);
  if (fd == -1) {
    perror("open() failed");
    return 1;
  }

  void *dax_addr =
      mmap(NULL, page_size, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
  if (dax_addr == MAP_FAILED) {
    perror("mmap() failed");
    close(fd);
    return 1;
  }

  FILE *fptr;
  char filename[100] = "<filename>";

  fptr = fopen(filename, "r");
  if (fptr == NULL) {
    printf("Cannot open file %s\n", filename);
    return -1;
  }

  int c = 0;
  while ((c = fgetc(fptr)) != EOF) {
    putchar(c);
  }

  munmap(dax_addr, page_size);
  close(fd);
  return 0;
}

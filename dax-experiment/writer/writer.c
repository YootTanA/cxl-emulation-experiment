#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <unistd.h>

int main() {
  const char *filename = "your_file_name";
  struct stat file_stat;
  char *file_content;

  int file_fd = open(filename, O_RDONLY);
  if (file_fd == -1) {
    printf("Error opening file %s\n", filename);
    return -1;
  }

  if (fstat(file_fd, &file_stat) == -1) {
    printf("Error getting file size");
    close(file_fd);
  }
  size_t file_size = file_stat.st_size;

  int dax_fd = open("/dev/dax0.0", O_RDWR);
  if (dax_fd == -1) {
    perror("open() failed");
    return 1;
  }

  void *dax_addr =
      mmap(NULL, file_size, PROT_READ | PROT_WRITE, MAP_SHARED, dax_fd, 0);
  if (dax_addr == MAP_FAILED) {
    perror("mmap() failed");
    close(file_fd);
    close(dax_fd);
    return -1;
  }

  char *buffer = malloc(file_size);
  if (!buffer) {
    printf("Error allocating buffer");
    munmap(dax_addr, file_size);
    close(file_fd);
    close(dax_fd);
    return -1;
  }

  if (read(file_fd, buffer, file_size) != file_size) {
    printf("Error reading input file");
    free(buffer);
    munmap(dax_addr, file_size);
    close(file_fd);
    close(dax_fd);
    return -1;
  }

  memcpy(dax_addr, buffer, file_size);
  if (msync(dax_addr, file_size, MS_SYNC) == -1) {
    printf("Error syncing memory");
  }

  free(buffer);
  munmap(dax_addr, file_size);
  close(file_fd);
  close(dax_fd);
  return 0;
}

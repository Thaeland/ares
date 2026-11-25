// A private stdio child, not a daemon. No arguments, socket, or exec string.
#ifdef __APPLE__
#include <util.h>
#else
#include <pty.h>
#endif
#include <cerrno>
#include <csignal>
#include <cstdint>
#include <cstdlib>
#include <sys/ioctl.h>
#include <sys/poll.h>
#include <sys/wait.h>
#include <unistd.h>

static bool transfer(int fd, void* ptr, size_t n, bool reading) {
  auto* p = static_cast<unsigned char*>(ptr);
  while (n) {
    ssize_t k = reading ? read(fd, p, n) : write(fd, p, n);
    if (k < 0 && errno == EINTR) continue;
    if (k <= 0) return false;
    p += k; n -= k;
  }
  return true;
}

int main() {
  int master;
  winsize size{24, 80, 0, 0};
  const pid_t child = forkpty(&master, nullptr, nullptr, &size);
  if (child == -1) return 1;
  if (!child) {
    execl("/bin/sh", "sh", "-i", static_cast<char*>(nullptr));
    _exit(127);
  }
  signal(SIGPIPE, SIG_IGN);
  unsigned char buf[65536];
  pollfd fds[] = {{0, POLLIN, 0}, {master, POLLIN, 0}};
  while (true) {
    if (poll(fds, 2, -1) < 0) { if (errno == EINTR) continue; break; }
    if (fds[1].revents) {
      const ssize_t k = read(master, buf, sizeof buf);
      if (k <= 0 || !transfer(1, buf, k, false)) break;
    }
    if (!fds[0].revents) continue;
    // Five-byte header: data (0, uint32 big-endian length) or resize
    // (1, two uint16 big-endian dimensions). EOF is an explicit close.
    unsigned char h[5];
    if (!transfer(0, h, sizeof h, true)) break;
    if (h[0] == 1) {
      size.ws_col = (h[1] << 8) | h[2]; size.ws_row = (h[3] << 8) | h[4];
      if (!size.ws_col || !size.ws_row || ioctl(master,TIOCSWINSZ,&size)<0) break;
    } else if (h[0] == 0) {
      const uint32_t n = (uint32_t(h[1])<<24)|(uint32_t(h[2])<<16)|(uint32_t(h[3])<<8)|h[4];
      if (n>sizeof buf || !transfer(0,buf,n,true) || !transfer(master,buf,n,false)) break;
    } else break;
  }
  const auto foreground = tcgetpgrp(master);
  if (foreground > 0 && foreground != getpgrp()) kill(-foreground, SIGHUP);
  close(master);
  kill(child, SIGKILL); // unreaped child PID cannot be recycled
  int status=0;
  while (waitpid(child,&status,0)<0 && errno==EINTR) {}
  return WIFEXITED(status) ? WEXITSTATUS(status) : 1;
}

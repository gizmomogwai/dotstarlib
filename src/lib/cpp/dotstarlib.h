#pragma once

#include <cstdint>
#include <string>
#include <sstream>

class Exception {
public:
  Exception(const std::string& msg) :fMsg(msg) {
  }
  Exception(const std::string& msg, const int error) {
    std::ostringstream stringStream;
    stringStream << msg;
    stringStream << error;
    fMsg = stringStream.str();
  }
private:
std::string fMsg;
};

#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <linux/spi/spidev.h>

class Spi {
public:
  Spi() {
    const char* SPI_DEV = "/dev/spidev0.0";
    fFile = open(SPI_DEV, O_RDWR);
    if (fFile < 0) {
      throw new Exception("cannot open '" SPI_DEV "'");
    }
    uint8_t mode = SPI_MODE_0 | SPI_NO_CS;
    int res = ioctl(fFile, SPI_IOC_WR_MODE, &mode);
    if (res != 0) {
      throw new Exception("ioctl SPI_IOC_WR_MODE failed with error: ", res);
    }

    res = ioctl(fFile, SPI_IOC_WR_MAX_SPEED_HZ, BITRATE);
    if (res != 0) {
      throw new Exception("ioctl SPI_IOC_WR_MAX_SPEED_HZ failed with error: ", res);
    }
  }

  void write(uint32_t* pixels, uint32_t nrOfPixels) {
    xfer[0].speed_hz = BITRATE;
    xfer[1].speed_hz = BITRATE;
    xfer[2].speed_hz = BITRATE;
    xfer[1].tx_buf = pixels;
    xfer[1].len = nrOfPixels*4;
    xfer[2].len = (nrOfPixels + 15) / 16;
    int res = ioctl(fFile, SPI_IOC_MESSAGE(3), xfer);
    if (res != 0) {
      throw new Exception("ioctl SPI_IOC_MESSAGE(3) failed with error: ", res);
    }
  }

private:
  const int BITRATE = 8000000;
  int fFile;
  static struct spi_ioc_transfer fXfer[3] = {
    { .tx_buf        = 0,
      .rx_buf        = 0,
      .len           = 4,
      .delay_usecs   = 0,
      .bits_per_word = 8,
      .cs_change     = 0 },
    { .rx_buf        = 0,
      .delay_usecs   = 0,
      .bits_per_word = 8,
      .cs_change     = 0 },
    { .tx_buf        = 0,
      .rx_buf        = 0,
      .delay_usecs   = 0,
      .bits_per_word = 8,
      .cs_change     = 0 }
  };
};




class DotStarStrip {
public:
  DotStarStrip(const uint32_t nrOfPixels) : fNrOfPixels(nrOfPixels), fSpi() {
    fPixels = new uint32_t[fNrOfPixels];
  }
  void setPixel(const uint32_t idx, const uint32_t color) {
    assert(idx < fNrOfPixels);

    fPixels[idx] = color;
  }

  void refresh() {
  }
private:
  uint32_t fNrOfPixels;
  uint32_t* fPixels;
  Spi fSpi;
};



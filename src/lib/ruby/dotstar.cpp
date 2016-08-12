#include "rice/Class.hpp"
#include "rice/Constructor.hpp"

using namespace Rice;

#include "../cpp/dotstarlib.h"

extern "C" void Init_dotstar() {
  Class dotStarStrip = define_class<DotStarStrip>("DotStarStrip")
    .define_constructor(Constructor<DotStarStrip, int>())
    .define_method("refresh", &DotStarStrip::refresh)
    .define_method("set_pixel", &DotStarStrip::setPixel)
    .define_method("size", &DotStarStrip::size)
    ;
}

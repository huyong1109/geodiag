#include "VertCoord.h"

namespace geodiag_cmor {

VertCoord::VertCoord() {
    type = INVALID_VERT_COORD;
}

VertCoord::~VertCoord() {

}

void VertCoord::init(VertCoordType type) {
    this->type = type;
}

}

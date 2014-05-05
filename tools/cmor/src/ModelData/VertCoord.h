#ifndef __Geodiag_cmor_VertCoord__
#define __Geodiag_cmor_VertCoord__

#include "geodiag_cmor_commons.h"

namespace geodiag_cmor {

enum VertCoordType {
    INVALID_VERT_COORD, CLASSIC_PRESSURE_SIGMA, HYBRID_PRESSURE_SIGMA
};

class VertCoord {
protected:
    VertCoordType type;
public:
    VertCoord();
    virtual ~VertCoord();

    void init(VertCoordType type);
};

}

#endif // __Geodiag_cmor_VertCoord__

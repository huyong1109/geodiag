#ifndef __Geodiag_cmor_ModelData__
#define __Geodiag_cmor_ModelData__

#include "geodiag_cmor_commons.h"
#include "VertCoord.h"

namespace geodiag_cmor {

class ModelData {
protected:
    string modelName;
    VertCoord vertCoord;
public:
    ModelData();
    virtual ~ModelData();

    void init(const string &configFilePath);
};

}

#endif // __Geodiag_cmor_ModelData__

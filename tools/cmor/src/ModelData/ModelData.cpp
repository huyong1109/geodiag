#include "ModelData.h"

namespace geodiag_cmor {

ModelData::ModelData() {
}

ModelData::~ModelData() {
}

void ModelData::init(const string &configFilePath) {
    VertCoordType vertCoordType;
    vertCoord.init(vertCoordType);
}

}

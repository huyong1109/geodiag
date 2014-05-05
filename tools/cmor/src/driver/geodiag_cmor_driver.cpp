#include "geodiag_cmor.h"

using geodiag_cmor::ModelData;

int main(int argc, const char *argv[])
{
    ModelData modelData;

    modelData.init("model.config");

    return 0;
}

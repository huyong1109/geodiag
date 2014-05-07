#include "geodiag_cmor.h"

using geomtk::ConfigManager;
using geodiag_cmor::ModelData;

int main(int argc, const char *argv[])
{
    ConfigManager configManager;
    ModelData modelData;

    modelData.init("model.config");

    return 0;
}

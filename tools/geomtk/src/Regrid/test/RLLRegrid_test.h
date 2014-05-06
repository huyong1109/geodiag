#ifndef __RLLRegrid_test__
#define __RLLRegrid_test__

#include "RLLRegrid.h"

using namespace geomtk;

class RLLRegridTest : public ::testing::Test {
protected:
    SphereDomain *domain;
    RLLMesh *mesh;
    RLLRegrid *regrid;
    RLLVelocityField v;
    TimeLevelIndex<2> timeIdx;

    virtual void SetUp() {
        domain = new SphereDomain(2);
        mesh = new RLLMesh(*domain);
        regrid = new RLLRegrid(*mesh);

        domain->setRadius(1.0);

        int numLon = 5;
        vec fullLon(numLon), halfLon(numLon);
        double dlon = 2.0*M_PI/numLon;
        for (int i = 0; i < numLon; ++i) {
            fullLon[i] = i*dlon;
            halfLon[i] = i*dlon+dlon*0.5;
        }
        mesh->setGridCoords(0, numLon, fullLon, halfLon);
        int numLat = 5;
        vec fullLat(numLat), halfLat(numLat-1);
        double dlat = M_PI/(numLat-1);
        for (int j = 0; j < numLat; ++j) {
            fullLat[j] = j*dlat-M_PI_2;
        }
        for (int j = 0; j < numLat-1; ++j) {
            halfLat[j] = dlat*0.5+j*dlat-M_PI_2;
        }
        mesh->setGridCoords(1, numLat, fullLat, halfLat);
    }

    virtual void TearDown() {
        delete regrid;
        delete mesh;
        delete domain;
    }
};

//     \      -      |      +      |      +      |      +      |      +      |      +      \      -
// -0.4*PI          0.0         0.4*PI        0.8*PI        1.2*PI        1.6*PI        2.0*PI
//        -0.2*PI        0.2*PI        0.6*PI        1.0*PI        1.4*PI        1.8*PI        2.2*PI
//     |      +      |      +      |      +      |      +      |
// -0.5*PI      -0.25*PI          0.0        0.25*PI        0.5*PI
//      -0.375*PI     -0.125*PI      0.125*PI      0.375*PI

TEST_F(RLLRegridTest, Run) {
    v.create(*mesh, true);
    for (int j = 0; j < mesh->getNumGrid(1, RLLStagger::GridType::FULL); ++j) {
        for (int i = 0; i < mesh->getNumGrid(0, RLLStagger::GridType::HALF); ++i) {
            v(0)(timeIdx, i, j) = 5.0;
        }
    }
    for (int j = 0; j < mesh->getNumGrid(1, RLLStagger::GridType::HALF); ++j) {
        for (int i = 0; i < mesh->getNumGrid(0, RLLStagger::GridType::FULL); ++i) {
            v(1)(timeIdx, i, j) = 5.0;
        }
    }
    v.applyBndCond(timeIdx);

    SphereCoord x(2);

    x.setCoord(1.9*M_PI, 0.2*M_PI);

    SphereVelocity z(2);
    regrid->run(BILINEAR, timeIdx, v, x, z);
    ASSERT_EQ(5.0, z(0));
    ASSERT_EQ(5.0, z(1));

    // When 'moveOnPole' is true, the interpolated transformed velocity is
    // transformed back.
    z(0) = 0.0;
    z(1) = 0.0;
    x.setCoord(0.1*M_PI, 0.26*M_PI);
    RLLMeshIndex idx(2);
    idx.locate(*mesh, x);
    idx.setMoveOnPole(true);
    regrid->run(BILINEAR, timeIdx, v, x, z, &idx);
    ASSERT_EQ(0.0, z(0));
    ASSERT_EQ(0.0, z(1));

    // When 'moveOnPole' is false, the interpolated transformed velocity is
    // not transformed back.
    z(0) = 0.0;
    z(1) = 0.0;
    x.setCoord(0.1*M_PI, 0.26*M_PI);
    idx.reset();
    idx.locate(*mesh, x);
    regrid->run(BILINEAR, timeIdx, v, x, z, &idx);
    ASSERT_NE(0.0, z(0));
    ASSERT_NE(0.0, z(1));
}

#endif

#ifndef __RLLMeshIndex_test__
#define __RLLMeshIndex_test__

#include "RLLMeshIndex.h"

using namespace geomtk;

class RLLMeshIndexTest : public ::testing::Test {
protected:
    SphereDomain *domain;
    RLLMesh *mesh;
    RLLMeshIndex *index;

    virtual void SetUp() {
        domain = new SphereDomain(2);
        mesh = new RLLMesh(*domain);
        index = new RLLMeshIndex(domain->getNumDim());

        mesh->setPoleRadius(0.1*M_PI);

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
        delete index;
        delete mesh;
        delete domain;
    }
};

TEST_F(RLLMeshIndexTest, AssignmentOperator) {
    RLLMeshIndex a(3), b(3);

    a.onPole = true;
    a.inPolarCap = true;
    a.pole = NORTH_POLE;
    a.moveOnPole = true;

    b = a;

    ASSERT_EQ(a.onPole, b.onPole);
    ASSERT_EQ(a.inPolarCap, b.inPolarCap);
    ASSERT_EQ(a.pole, b.pole);
    ASSERT_EQ(a.moveOnPole, b.moveOnPole);
}

TEST_F(RLLMeshIndexTest, Basic) {
    RLLMeshIndex a(2);

    a.setMoveOnPole(true);
    ASSERT_EQ(true, a.isMoveOnPole());
}

//     \      -      |      +      |      +      |      +      |      +      |      +      \      -
// -0.4*PI          0.0         0.4*PI        0.8*PI        1.2*PI        1.6*PI        2.0*PI
//        -0.2*PI        0.2*PI        0.6*PI        1.0*PI        1.4*PI        1.8*PI        2.2*PI
//     |      +      |      +      |      +      |      +      |
// -0.5*PI      -0.25*PI          0.0        0.25*PI        0.5*PI
//      -0.375*PI     -0.125*PI      0.125*PI      0.375*PI

TEST_F(RLLMeshIndexTest, Locate) {
    SphereCoord x(domain->getNumDim());

    x(0) =  0.9*M_PI;
    x(1) = -0.11*M_PI;
    index->locate(*mesh, x);
    ASSERT_EQ(2, (*index)(0, StructuredStagger::GridType::FULL));
    ASSERT_EQ(1, (*index)(1, StructuredStagger::GridType::FULL));
    ASSERT_EQ(1, (*index)(0, StructuredStagger::GridType::HALF));
    ASSERT_EQ(1, (*index)(1, StructuredStagger::GridType::HALF));
    ASSERT_EQ(NOT_POLE, index->getPole());
    ASSERT_FALSE(index->isInPolarCap());
    ASSERT_FALSE(index->isOnPole());

    x(0) = 0.14*M_PI;
    index->reset();
    index->locate(*mesh, x);
    ASSERT_EQ(0, (*index)(0, StructuredStagger::GridType::FULL));
    ASSERT_EQ(-1, (*index)(0, StructuredStagger::GridType::HALF));

    x(0) = 1.9*M_PI;
    index->reset();
    index->locate(*mesh, x);
    ASSERT_EQ(4, (*index)(0, StructuredStagger::GridType::FULL));
    ASSERT_EQ(4, (*index)(0, StructuredStagger::GridType::HALF));

    x(1) = -0.2*M_PI;
    index->reset();
    index->locate(*mesh, x);
    ASSERT_EQ(1, (*index)(1, StructuredStagger::GridType::FULL));
    ASSERT_EQ(0, (*index)(1, StructuredStagger::GridType::HALF));
    ASSERT_EQ(NOT_POLE, index->getPole());
    ASSERT_FALSE(index->isInPolarCap());
    ASSERT_FALSE(index->isOnPole());

    x(1) = -0.39*M_PI;
    index->reset();
    index->locate(*mesh, x);
    ASSERT_EQ(0, (*index)(1, StructuredStagger::GridType::FULL));
    ASSERT_EQ(-1, (*index)(1, StructuredStagger::GridType::HALF));
    ASSERT_EQ(SOUTH_POLE, index->getPole());
    ASSERT_TRUE(index->isInPolarCap());
    ASSERT_FALSE(index->isOnPole());

    x(1) = 0.41*M_PI;
    index->reset();
    index->locate(*mesh, x);
    ASSERT_EQ(3, (*index)(1, StructuredStagger::GridType::FULL));
    ASSERT_EQ(3, (*index)(1, StructuredStagger::GridType::HALF));
    ASSERT_EQ(NORTH_POLE, index->getPole());
    ASSERT_TRUE(index->isInPolarCap());
    ASSERT_TRUE(index->isOnPole());
}

#endif

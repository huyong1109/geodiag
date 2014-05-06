#ifndef __RLLMeshIndex__
#define __RLLMeshIndex__

#include "StructuredMeshIndex.h"
#include "RLLMesh.h"
#include "SphereDomain.h"

namespace geomtk {

class RLLMeshIndex : public StructuredMeshIndex {
public:
    typedef RLLStagger::GridType GridType;
    typedef RLLStagger::Location Location;
protected:
    Pole pole;
    bool inPolarCap;
    bool onPole;
    bool moveOnPole;
public:
    RLLMeshIndex(int numDim);
    virtual ~RLLMeshIndex();

    virtual void reset();

    virtual RLLMeshIndex& operator=(const RLLMeshIndex &other);

    /**
     *  Toggle 'moveOnPole' boolean.
     */
    void setMoveOnPole(bool moveOnPole) { this->moveOnPole = moveOnPole; }

    Pole getPole() const { return pole; }
    bool isInPolarCap() const { return inPolarCap; }
    bool isOnPole() const { return onPole; }
    bool isMoveOnPole() const { return moveOnPole; }

    /**
     *  Inherit StructuredMeshIndex::locate(SpaceCoord) and add Pole judgement.
     *
     *  @param mesh the mesh that should be RLLMesh.
     *  @param x    the coordinate that should be a spherical coordinate.
     *
     *  @return None.
     */
    virtual void locate(const Mesh &mesh, const SpaceCoord &x);

    virtual void print() const;
};

}

#endif
